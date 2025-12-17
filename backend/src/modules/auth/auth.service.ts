import {
  BadRequestException,
  Injectable,
  InternalServerErrorException,
  UnauthorizedException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { JwtService } from '@nestjs/jwt';
import { RegisterUserDto } from './dto/requests/register-user.dto';
import { JwtPayload } from './interfaces/jwt-payload.interface';
import { User } from '../user/entities/user.entity';
import * as bcrypt from 'bcryptjs';
import { randomBytes } from 'node:crypto';
import { LoginResponse } from './dto/responses/login-response.dto';
import { SuccessResponse } from './dto/responses/success-response.dto';

@Injectable()
export class AuthService {
  // TTL for refresh token (30 days)
  private readonly refreshTokenTTL = 30 * 24 * 60 * 60 * 1000;

  // TTL for password reset token (1 hour)
  private readonly passwordResetTTL = 60 * 60 * 1000;

  constructor(
    private prisma: PrismaService,
    private readonly jwtService: JwtService,
  ) {}

  // Access Token
  private getJwtToken(payload: JwtPayload) {
    const token = this.jwtService.sign(payload, { expiresIn: '15m' });
    return token;
  }

  // Helper method: Create and Store a refresh token
  private async createAndStoreRefreshToken(userId: string) {
    const refreshToken = randomBytes(64).toString('hex'); // Long random string
    const tokenHash = await bcrypt.hash(refreshToken, 10);
    const expiresAt = new Date(Date.now() + this.refreshTokenTTL);

    await this.prisma.refresh_tokens.create({
      data: {
        user_id: userId,
        token_hash: tokenHash,
        expires_at: expiresAt,
        created_at: new Date(),
      },
    });

    return refreshToken;
  }

  // Helper method: Find refresh token record from DB
  private async findRefreshTokenRecord(refreshToken: string) {
    const tokens = await this.prisma.refresh_tokens.findMany({
      where: { revoked: false },
    });

    for (const token of tokens) {
      const match = await bcrypt.compare(refreshToken, token.token_hash);
      if (match) {
        return token;
      }
    }
    return null;
  }

  // Helper method: create and store a reset token
  private async createAndStorePasswordToken(userId: string) {
    const token = randomBytes(32).toString('hex'); // long opaque token
    const tokenHash = await bcrypt.hash(token, 10);
    const expiresAt = new Date(Date.now() + this.passwordResetTTL);

    await this.prisma.password_reset_token.create({
      data: {
        user_id: userId,
        token_hash: tokenHash,
        expires_at: expiresAt,
      },
    });
    return token;
  }

  async register(dto: RegisterUserDto): Promise<LoginResponse> {
    // Check if password and passwordConfirmation match
    if (dto.password !== dto.passwordConf)
      throw new BadRequestException('Password do not match');

    dto.email = dto.email.toLowerCase().trim();

    // Hash the password
    const hashedPassword = await bcrypt.hash(dto.password, 10);

    try {
      const newUser = await this.prisma.users.create({
        data: {
          username: dto.username,
          email: dto.email,
          password_hash: hashedPassword,
          provider: dto.provider,
        },
        select: {
          id: true,
          username: true,
          email: true,
          email_verified: true,
          provider: true,
          created_at: true,
        },
      });

      // Create refresh token and return it raw to the client
      const refresh_token = await this.createAndStoreRefreshToken(newUser.id);

      return {
        user: newUser,
        accessToken: this.getJwtToken({ id: newUser.id }),
        refreshToken: refresh_token,
      };
    } catch (error) {
      if (error.code === 'P2002') {
        throw new BadRequestException('User already exists');
      }
      throw new InternalServerErrorException('Server Error');
    }
  }

  async login(email: string, password: string): Promise<LoginResponse> {
    let user;
    try {
      user = await this.prisma.users.findUniqueOrThrow({
        where: { email },
      });
    } catch (error) {
      throw new BadRequestException('Wrong Credentials');
    }

    // Compare the provided password with the hashed password
    const passwordMatch = await bcrypt.compare(password, user.password_hash);

    if (!passwordMatch) {
      throw new BadRequestException('Wrong Credentials');
    }

    // Update Last Login
    const updatedUser = await this.prisma.users.update({
      where: { id: user.id },
      data: { last_login: new Date() },
      select: {
        id: true,
        username: true,
        email: true,
        email_verified: true,
        provider: true,
        created_at: true,
        last_login: true,
      },
    });

    // Create and store refresh token for this session
    const refreshToken = await this.createAndStoreRefreshToken(updatedUser.id);

    return {
      user: updatedUser,
      accessToken: this.getJwtToken({
        id: updatedUser.id,
      }),
      refreshToken: refreshToken,
    };
  }

  // Exchange refresh token -> new access token (and rotate the refresh token).
  async refresh(refreshToken: string): Promise<LoginResponse> {
    if (!refreshToken) {
      throw new UnauthorizedException('Missing refresh token');
    }
    const matchedToken = await this.findRefreshTokenRecord(refreshToken);

    if (!matchedToken || matchedToken?.expires_at < new Date()) {
      throw new UnauthorizedException('Invalid or expired refresh token');
    }

    const user = await this.prisma.users.findUnique({
      where: { id: matchedToken.user_id },
      select: {
        id: true,
        username: true,
        email: true,
        email_verified: true,
        provider: true,
        created_at: true,
        last_login: true,
      },
    });

    if (!user) throw new UnauthorizedException('User not found');

    // Rotate refresh token: delete old
    await this.prisma.refresh_tokens.delete({
      where: { id: matchedToken.id },
    });

    // Create new refresh token
    const newRefreshToken = await this.createAndStoreRefreshToken(user.id);

    // Issue new access token
    const newAccessToken = this.getJwtToken({ id: user.id });

    return {
      user,
      accessToken: newAccessToken,
      refreshToken: newRefreshToken,
    };
  }

  async logout(user: User, refreshToken?: string): Promise<SuccessResponse> {
    if (refreshToken) {
      const matched = await this.findRefreshTokenRecord(refreshToken);
      if (matched) {
        await this.prisma.refresh_tokens.delete({ where: { id: matched.id } });
      } else {
        throw new BadRequestException('Invalid or expired refresh token');
      }
    } else {
      // Delete all refresh tokens related to the user
      await this.prisma.refresh_tokens.deleteMany({
        where: { user_id: user.id },
      });
    }
    return { message: 'Logged out successfully' };
  }

  async requestPasswordReset(email: string): Promise<SuccessResponse> {
    if (!email) {
      throw new BadRequestException(
        'Bad Request: The email is missing or invalid.',
      );
    }
    const user = await this.prisma.users.findUnique({ where: { email } });

    // Always respond with success message (DO NOT reveal whether user exists in response for security). But only create token/send email if user exists
    if (!user) {
      // Return generic response
      return {
        message:
          'If an account with that email exists, a reset link has been sent.',
      };
    }
    try {
      const token = await this.createAndStorePasswordToken(user.id);

      // TODO: send email

      return {
        message:
          'If an account with that email exists, a reset link has been sent.',
      };
    } catch (error) {
      throw new InternalServerErrorException('Internal Server Error.');
    }
  }

  async resetPassword(
    token: string,
    newPassword: string,
  ): Promise<SuccessResponse> {
    const userTokens = await this.prisma.password_reset_token.findMany({
      where: { used: false },
      orderBy: { created_at: 'desc' },
    });

    if (!userTokens || userTokens.length === 0) {
      throw new BadRequestException('Invalid or Expired reset token.');
    }

    // find matching token
    let matched;
    for (const t of userTokens) {
      if (t.expires_at && t.expires_at < new Date()) {
        continue;
      }
      const ok = await bcrypt.compare(token, t.token_hash);
      if (ok) {
        matched = t;
        break;
      }
    }
    if (!matched) {
      throw new BadRequestException('Invalid or Expired reset token.');
    }

    const hashed = await bcrypt.hash(newPassword, 10);

    await this.prisma.$transaction([
      this.prisma.users.update({
        where: { id: matched.user_id },
        data: {
          password_hash: hashed,
        },
      }),
      this.prisma.password_reset_token.update({
        where: { id: matched.id },
        data: { used: true },
      }),
      this.prisma.refresh_tokens.deleteMany({
        where: { user_id: matched.user_id },
      }),
    ]);

    return { message: 'Password has been reset.' };
  }

  async changePassword(
    userId: string,
    currentPassword: string,
    newPassword: string,
  ): Promise<SuccessResponse> {
    const dbUser = await this.prisma.users.findUnique({
      where: { id: userId },
    });
    if (!dbUser || !dbUser.password_hash) {
      throw new UnauthorizedException('Invalid credentials');
    }

    const match = await bcrypt.compare(currentPassword, dbUser.password_hash);
    if (!match) {
      throw new BadRequestException('Current password is incorrect');
    }

    if (currentPassword == newPassword) {
      throw new BadRequestException(
        'New password is already the current password',
      );
    }
    const hashed = await bcrypt.hash(newPassword, 10);
    await this.prisma.$transaction([
      this.prisma.users.update({
        where: { id: userId },
        data: { password_hash: hashed },
      }),
      // Invalidate refresh tokens
      this.prisma.refresh_tokens.deleteMany({ where: { user_id: userId } }),
    ]);

    return { message: 'Password changed successfully' };
  }
}
