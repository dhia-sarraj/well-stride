import { Injectable, InternalServerErrorException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { ProfileResponse } from './dto/responses/profile-response.dto';
import { CreateProfileDto } from './dto/requests/create-profile.dto';
import { CreatedProfileResponse } from './dto/responses/create-profile-response.dto';
import { EditProfileDTO } from './dto/requests/edit-profile.dto';

@Injectable()
export class ProfileService {
  constructor(private prisma: PrismaService) {}

  async createProfile(
    userId: string,
    dto: CreateProfileDto,
  ): Promise<CreatedProfileResponse> {
    try {
      await this.prisma.user_profiles.create({
        data: {
          user_id: userId,
          photo_url: dto.photoUrl,
          age: dto.age,
          gender: dto.gender,
          height_cm: dto.height,
          weight_kg: dto.weight,
          created_at: new Date(),
        },
      });
    } catch (error) {
      throw new InternalServerErrorException('Internal Server Error');
    }

    return {
      message: 'Profile Successfuly Created',
    };
  }

  async getProfile(userId: string): Promise<ProfileResponse> {
    let profile;
    try {
      profile = this.prisma.user_profiles.findUniqueOrThrow({
        where: { user_id: userId },
      });
    } catch (error) {
      throw new InternalServerErrorException('Internal Server Error');
    }

    return profile;
  }

  async editProfile(
    userId: string,
    dto: EditProfileDTO,
  ): Promise<ProfileResponse> {
    let profile;
    try {
      profile = this.prisma.user_profiles.update({
        where: { user_id: userId },
        data: {
          photo_url: dto.photoUrl,
          age: dto.age,
          gender: dto.gender,
          height_cm: dto.height,
          weight_kg: dto.weight,
        },
      });
    } catch (error) {
      throw new InternalServerErrorException('Internal Server Error');
    }
    return profile;
  }
}
