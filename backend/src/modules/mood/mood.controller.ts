import { Body, Controller, Get, Post, Query, UseGuards } from '@nestjs/common';
import { MoodService } from './mood.service';
import {
  ApiBearerAuth,
  ApiOperation,
  ApiResponse,
  ApiTags,
} from '@nestjs/swagger';
import { GetUser } from '../auth/decorators/get-user.decorator';
import { User } from '../user/entities/user.entity';
import { AuthGuard } from '@nestjs/passport';
import { MoodResponseDto } from './dto/responses/mood-response.dto';
import { MoodRequestDto } from './dto/requests/mood-request.dto';
import { GetMoodsQueryDto } from './dto/requests/get-moods-query.dto';

@ApiTags('Moods')
@Controller('api/moods')
export class MoodController {
  constructor(private readonly moodService: MoodService) {}

  // POST: /moods/
  @Post()
  @ApiBearerAuth()
  @UseGuards(AuthGuard('jwt'))
  @ApiOperation({
    summary: 'ADD A MOOD RECORD',
  })
  @ApiResponse({
    status: 200,
    description: 'Successfully added a mood record',
    type: MoodResponseDto,
  })
  @ApiResponse({
    status: 500,
    description: 'Internal Server Error',
  })
  async addMood(@GetUser() user: User, @Body() dto: MoodRequestDto) {
    return await this.moodService.addMood(user.id, dto);
  }

  // GET: /moods?from= &to=
  @Get()
  @ApiBearerAuth()
  @UseGuards(AuthGuard('jwt'))
  @ApiOperation({
    summary: 'GET MOOD LOGS',
    description:
      'Returns mood logs for the authenticated user within a date range.',
  })
  @ApiResponse({
    status: 200,
    description: 'List of mood logs',
    type: MoodResponseDto,
  })
  @ApiResponse({
    status: 500,
    description: 'Internal Server Error',
  })
  async getMoods(@GetUser() user: User, @Query() query: GetMoodsQueryDto) {
    return this.moodService.getMoods(user.id, query);
  }
}
