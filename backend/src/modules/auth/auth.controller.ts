import { Body, Controller, Patch, Post, UseGuards } from '@nestjs/common';
import { AuthService } from './auth.service';
import {
  ApiBearerAuth,
  ApiOperation,
  ApiResponse,
  ApiTags,
} from '@nestjs/swagger';
import { RegisterUserDto } from './dto/requests/register-user.dto';
import { LoginResponse } from './dto/responses/login-response.dto';
import { LoginUserDto } from './dto/requests/login-user.dto';
import { GetUser } from './decorators/get-user.decorator';
import { AuthGuard } from '@nestjs/passport';
import { User } from '../user/entities/user.entity';
import { RefreshTokenDto } from './dto/requests/refresh-token.dto';
import { ForgotPasswordDto } from './dto/requests/forgot-password.dto';
import { ResetPasswordDto } from './dto/requests/reset-password.dto';
import { changePasswordDto } from './dto/requests/change-password.dto';
import { SuccessResponse } from './dto/responses/success-response.dto';

@ApiTags('Auth')
@Controller('api/auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  // POST: Register
  @Post('register')
  @ApiOperation({
    summary: 'REGISTER',
    description: 'Public endpoint to register a new user.',
  })
  @ApiResponse({
    status: 201,
    description: 'Register Succeeded',
    type: LoginResponse,
  })
  @ApiResponse({ status: 400, description: 'Bad request' })
  @ApiResponse({ status: 500, description: 'Server error' })
  async register(@Body() createUserDto: RegisterUserDto) {
    return await this.authService.register(createUserDto);
  }

  // POST: Login
  @Post('login')
  @ApiOperation({
    summary: 'LOGIN',
    description: 'Public endpoint to login and get an Access Token',
  })
  @ApiResponse({
    status: 200,
    description: 'Login Succeeded',
    type: LoginResponse,
  })
  @ApiResponse({ status: 400, description: 'Bad request' })
  @ApiResponse({ status: 500, description: 'Server error' })
  async login(@Body() loginUserDto: LoginUserDto) {
    return await this.authService.login(
      loginUserDto.email,
      loginUserDto.password,
    );
  }

  // POST: Refresh
  @Post('refresh')
  @ApiOperation({
    summary: 'REFRESH TOKEN',
    description:
      'Private endpoint allowed for logged in users to refresh the Access Token before it expires.',
  })
  @ApiResponse({
    status: 200,
    description: 'Request Succeeded',
    type: LoginResponse,
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async refreshToken(@Body() body: RefreshTokenDto) {
    return await this.authService.refresh(body.refreshToken);
  }

  // POST: Logout
  @Post('logout')
  @ApiOperation({
    summary: 'LOGOUT',
    description: 'Revoke the current refresh token. User must log in again.',
  })
  @ApiBearerAuth()
  @ApiResponse({
    status: 200,
    description: 'Loggout Succeeded',
    type: SuccessResponse,
  })
  @ApiResponse({
    status: 400,
    description: 'Invalid or Expired Refresh Token',
  })
  @UseGuards(AuthGuard('jwt'))
  async logout(@GetUser() user: User, @Body() body?: RefreshTokenDto) {
    return await this.authService.logout(user, body?.refreshToken);
  }

  // POST: Forget-Password
  @Post('password/forgot')
  @ApiOperation({
    summary: 'FORGOT PASSWORD',
    description:
      'Start password reset flow by sending a reset link to the user email.',
  })
  @ApiResponse({
    status: 200,
    description:
      'Password reset email sent successfully. The user (if exists) will receive an email with instructions.',
  })
  @ApiResponse({
    status: 400,
    description: 'Bad Request. The email is missing or invalid.',
  })
  @ApiResponse({
    status: 500,
    description: 'Internal Server Error.',
  })
  async forgot(@Body() body: ForgotPasswordDto) {
    return await this.authService.requestPasswordReset(body.email);
  }

  // POST: Reset-Password
  @Post('password/reset')
  @ApiOperation({
    summary: 'RESET PASSWORD',
    description: 'Resets the user password using a valid reset token.',
  })
  @ApiResponse({
    status: 200,
    description: 'Password has been successfully reset.',
    type: SuccessResponse,
  })
  @ApiResponse({
    status: 400,
    description: 'Invalid or expired reset token, or new password is invalid.',
  })
  @ApiResponse({
    status: 500,
    description: 'Internal Server Error.',
  })
  async reset(@Body() body: ResetPasswordDto) {
    return await this.authService.resetPassword(body.token, body.newPassword);
  }

  // PATCH: Change-Password
  @Patch('password/change')
  @ApiOperation({
    summary: 'CHANGE PASSWORD',
    description: 'Allows a logged-in user to change their current password.',
  })
  @ApiBearerAuth()
  @ApiResponse({
    status: 200,
    description: 'Password changed successfully.',
    type: SuccessResponse,
  })
  @ApiResponse({
    status: 400,
    description:
      'Bad Request. Current password is incorrect or new password is same as current password.',
  })
  @ApiResponse({
    status: 401,
    description: 'Unauthorized. User not authenticated or invalid credentials.',
  })
  @ApiResponse({
    status: 500,
    description: 'Internal Server Error.',
  })
  @UseGuards(AuthGuard('jwt'))
  async change(@GetUser() user: User, @Body() body: changePasswordDto) {
    return await this.authService.changePassword(
      user.id,
      body.currentPassword,
      body.newPassword,
    );
  }
}
