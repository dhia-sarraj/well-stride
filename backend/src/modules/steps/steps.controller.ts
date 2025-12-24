import {
  Body,
  Controller,
  Get,
  Param,
  Patch,
  Post,
  Query,
  UseGuards,
} from '@nestjs/common';
import { StepsService } from './steps.service';
import {
  ApiBearerAuth,
  ApiOperation,
  ApiResponse,
  ApiTags,
} from '@nestjs/swagger';
import { GetUser } from '../auth/decorators/get-user.decorator';
import { User } from '../user/entities/user.entity';
import { SyncStepsDto } from './dto/requests/sync-steps.dto';
import { AuthGuard } from '@nestjs/passport';
import { StepSummaryResponse } from './dto/responses/steps-summary-response.dto';
import { UpdateGoalDto } from './dto/requests/update-goal.dto';
import { GetStepsQueryDto } from './dto/requests/get-steps-query.dto';

@ApiTags('Steps')
@Controller('api/steps')
export class StepsController {
  constructor(private readonly stepsService: StepsService) {}

  // POST: /steps
  @Post()
  @UseGuards(AuthGuard('jwt'))
  @ApiBearerAuth()
  @ApiOperation({
    summary: 'SYNC STEP SUMMARY',
    description:
      'Create or update a daily step summary for the authenticated user',
  })
  @ApiResponse({
    status: 201,
    description: 'Step summary created or updated',
    type: StepSummaryResponse,
  })
  @ApiResponse({
    status: 400,
    description: 'Validation error',
  })
  @ApiResponse({
    status: 401,
    description: 'Unauthorized',
  })
  async syncSteps(@GetUser() user: User, @Body() dto: SyncStepsDto) {
    return await this.stepsService.syncSteps(user.id, dto);
  }

  // GET: /steps/today
  @Get('/today')
  @UseGuards(AuthGuard('jwt'))
  @ApiBearerAuth()
  @ApiOperation({
    summary: "GET TODAY'S STEP SUMMARY",
    description: 'Fetch the daily step summary for the authenticated user',
  })
  @ApiResponse({
    status: 200,
    description: 'Step summary for today',
    type: StepSummaryResponse,
  })
  async getToday(@GetUser() user: User) {
    return await this.stepsService.getTodaySteps(user.id);
  }

  // GET: /steps
  @Get()
  @UseGuards(AuthGuard('jwt'))
  @ApiBearerAuth()
  @ApiOperation({
    summary: 'GET STEP LOGS',
    description:
      'Returns step logs for the authenticated user within a date range.',
  })
  @ApiResponse({
    status: 200,
    description: 'List of step logs',
    type: StepSummaryResponse,
  })
  @ApiResponse({
    status: 404,
    description: 'No step summary found for the requested date',
  })
  async getSteps(@GetUser() user: User, @Query() query: GetStepsQueryDto) {
    return await this.stepsService.getSteps(user.id, query);
  }

  // PATCH: /steps/goal
  @Patch('/goal')
  @UseGuards(AuthGuard('jwt'))
  @ApiBearerAuth()
  @ApiOperation({
    summary: "UPDATE TODAY'S STEP GOAL",
  })
  @ApiResponse({
    status: 200,
    description: 'Step goal updated',
    type: StepSummaryResponse,
  })
  @ApiResponse({
    status: 400,
    description: 'Invalid Goal',
  })
  async updateGoal(@GetUser() user: User, @Body() dto: UpdateGoalDto) {
    return await this.stepsService.updateTodayGoal(user.id, dto.goal);
  }
}
