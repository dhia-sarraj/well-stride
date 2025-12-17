import {
  Body,
  Controller,
  Get,
  Patch,
  Post,
  UseGuards,
} from '@nestjs/common';
import { ProfileService } from './profile.service';
import {
  ApiBearerAuth,
  ApiOperation,
  ApiResponse,
  ApiTags,
} from '@nestjs/swagger';
import { ProfileResponse } from './dto/responses/profile-response.dto';
import { CreateProfileDto } from './dto/requests/create-profile.dto';
import { CreatedProfileResponse } from './dto/responses/create-profile-response.dto';
import { AuthGuard } from '@nestjs/passport';
import { GetUser } from '../auth/decorators/get-user.decorator';
import { User } from '../user/entities/user.entity';
import { EditProfileDTO } from './dto/requests/edit-profile.dto';

@ApiTags('Profile')
@Controller('api/profile')
export class ProfileController {
  constructor(private readonly profileService: ProfileService) {}

  // POST: /profile/me
  @ApiBearerAuth()
  @Post('/me')
  @ApiOperation({
    summary: 'CREATE USER PROFILE',
    description: 'Private endpoint to create a user profile',
  })
  @ApiResponse({
    status: 201,
    description: 'Profile successfully created',
    type: CreatedProfileResponse,
  })
  @ApiResponse({
    status: 500,
    description: 'Internal Server Error',
  })
  @UseGuards(AuthGuard('jwt'))
  async create(@GetUser() user: User, @Body() dto: CreateProfileDto) {
    return await this.profileService.createProfile(user.id, dto);
  }

  // GET: /profile/me
  @ApiBearerAuth()
  @Get('me')
  @ApiOperation({
    summary: 'GET USER PROFILE',
    description: 'Private endpoint to find a user profile.',
  })
  @ApiResponse({
    status: 200,
    description: 'Profile successfully retrieved',
    type: ProfileResponse,
  })
  @ApiResponse({
    status: 500,
    description: 'Internal Server Error',
  })
  @UseGuards(AuthGuard('jwt'))
  async getProfile(@GetUser() user: User) {
    return await this.profileService.getProfile(user.id);
  }

  // PATCH: /profile/me
  @ApiBearerAuth()
  @Patch('me')
  @ApiOperation({
    summary: 'EDIT USER PROFILE',
    description: 'Private endpoint to edit a user profile',
  })
  @ApiResponse({
    status: 200,
    description: 'Profile successfully edited',
    type: ProfileResponse,
  })
  @ApiResponse({
    status: 500,
    description: 'Internal Server Error',
  })
  @UseGuards(AuthGuard('jwt'))
  async editProfile(@GetUser() user: User, @Body() dto: EditProfileDTO) {
    return await this.profileService.editProfile(user.id, dto);
  }
}
