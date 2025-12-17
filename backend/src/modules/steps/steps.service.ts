import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { SyncStepsDto } from './dto/requests/sync-steps.dto';
import { StepSummaryResponse } from './dto/responses/steps-summary-response.dto';

@Injectable()
export class StepsService {
  constructor(private readonly prisma: PrismaService) {}

  async syncSteps(
    userId: string,
    dto: SyncStepsDto,
  ): Promise<StepSummaryResponse> {
    // Validate date format
    const date = dto.date;
    if (!/^\d{4}-\d{2}-\d{2}$/.test(date)) {
      throw new BadRequestException('Invalid date fromat: expected YYYY-MM-DD');
    }

    // Find existing record
    const existing = await this.prisma.step_summaries.findFirst({
      where: { user_id: userId, date: new Date(date) },
    });

    const record = existing
      ? await this.prisma.step_summaries.update({
          where: { id: existing.id },
          data: {
            step_count: dto.stepCount,
            distance_meters: dto.distanceMeters,
            active_minutes: dto.activeMinutes,
            stairs_climbed: dto.stairsClimbed,
            calories_estimated: dto.caloriesEstimated,
            synced_at: new Date(),
          },
        })
      : await this.prisma.step_summaries.create({
          data: {
            user_id: userId,
            date: new Date(date),
            step_count: dto.stepCount,
            goal: dto.goal ?? 1000,
            distance_meters: dto.distanceMeters,
            active_minutes: dto.activeMinutes,
            stairs_climbed: dto.stairsClimbed,
            calories_estimated: dto.caloriesEstimated,
            source: dto.source,
          },
        });
    return {
      id: record.id,
      date: record.date.toISOString().split('T')[0],
      stepCount: record.step_count,
      goal: record.goal,
      distanceMeters: record.distance_meters?.toNumber() ?? null,
      activeMinutes: record.active_minutes,
      stairsClimbed: record.stairs_climbed,
      caloriesEstimated: record.calories_estimated,
      source: record.source,
      syncedAt: new Date(),
      createdAt: new Date(),
    };
  }

  async getTodaySteps(userId: string): Promise<StepSummaryResponse> {
    const result = await this.prisma.step_summaries.findFirst({
      where: {
        user_id: userId,
        date: new Date(),
      },
    });

    return {
      id: result!.id,
      date: result!.date.toISOString().split('T')[0],
      stepCount: result!.step_count,
      goal: result!.goal,
      distanceMeters: result!.distance_meters?.toNumber() ?? null,
      activeMinutes: result!.active_minutes,
      stairsClimbed: result!.stairs_climbed,
      caloriesEstimated: result!.calories_estimated,
      source: result!.source,
      syncedAt: result!.synced_at,
      createdAt: result!.created_at,
    };
  }

  async getStepsByDate(
    userId: string,
    date: string,
  ): Promise<StepSummaryResponse> {
    const result = await this.prisma.step_summaries.findFirst({
      where: {
        user_id: userId,
        date: new Date(date),
      },
    });

    if (!result) {
      throw new NotFoundException(`No step summary found for date ${date}`);
    }

    return {
      id: result.id,
      date: result.date.toISOString().split('T')[0],
      stepCount: result.step_count,
      goal: result.goal,
      distanceMeters: result.distance_meters?.toNumber() ?? null,
      activeMinutes: result.active_minutes,
      stairsClimbed: result.stairs_climbed,
      caloriesEstimated: result.calories_estimated,
      source: result.source,
      syncedAt: result.synced_at,
      createdAt: result.created_at,
    };
  }
  async updateTodayGoal(
    userId: string,
    goal: number,
  ): Promise<StepSummaryResponse> {
    const result = await this.prisma.step_summaries.update({
      where: {
        user_id_date: {
          user_id: userId,
          date: new Date(),
        },
      },
      data: {
        goal: goal,
      },
    });
    return {
      id: result.id,
      date: result.date.toISOString().split('T')[0],
      stepCount: result.step_count,
      goal: result.goal,
      distanceMeters: result.distance_meters?.toNumber() ?? null,
      activeMinutes: result.active_minutes,
      stairsClimbed: result.stairs_climbed,
      caloriesEstimated: result.calories_estimated,
      source: result.source,
      syncedAt: result.synced_at,
      createdAt: result.created_at,
    };
  }
}
