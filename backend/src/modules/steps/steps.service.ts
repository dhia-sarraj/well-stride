import {
  BadRequestException,
  Injectable,
  InternalServerErrorException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { SyncStepsDto } from './dto/requests/sync-steps.dto';
import { StepSummaryResponse } from './dto/responses/steps-summary-response.dto';
import { GetStepsQueryDto } from './dto/requests/get-steps-query.dto';

@Injectable()
export class StepsService {
  constructor(private readonly prisma: PrismaService) {}

  private isDateOnly(s: string) {
    return /^\d{4}-\d{2}-\d{2}$/.test(s);
  }

  private startOfDayUTC(yyyyMmDd: string) {
    return new Date(`${yyyyMmDd}T00:00:00.000Z`);
  }

  private endOfDayUTC(yyyyMmDd: string) {
    return new Date(`${yyyyMmDd}T23:59:59.999Z`);
  }

  /**
   * Normalizes the from/to params into Date objects.
   * - date-only (YYYY-MM-DD) is treated as UTC day
   * - ISO datetimes are used as-is
   * - defaults to last 7 days if omitted
   */
  private parseDateRange(from?: string, to?: string) {
    const now = new Date();

    let toDate: Date;
    if (to) {
      toDate = this.isDateOnly(to) ? this.endOfDayUTC(to) : new Date(to);
    } else {
      toDate = now;
    }

    let fromDate: Date;
    if (from) {
      fromDate = this.isDateOnly(from)
        ? this.startOfDayUTC(from)
        : new Date(from);
    } else {
      // default: include toDate and 6 previous days => 7 days total
      const d = new Date(toDate);
      d.setUTCDate(d.getUTCDate() - 6);
      fromDate = new Date(
        Date.UTC(
          d.getUTCFullYear(),
          d.getUTCMonth(),
          d.getUTCDate(),
          0,
          0,
          0,
          0,
        ),
      );
    }

    return { fromDate, toDate };
  }

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

  async getSteps(
    userId: string,
    query: GetStepsQueryDto,
  ): Promise<StepSummaryResponse[]> {
    const { fromDate, toDate } = this.parseDateRange(query.from, query.to);

    try {
      const rows = await this.prisma.step_summaries.findMany({
        where: {
          user_id: userId,
          created_at: {
            gte: fromDate,
            lte: toDate,
          },
        },
        orderBy: { created_at: 'asc' },
        select: {
          id: true,
          date: true,
          step_count: true,
          goal: true,
          distance_meters: true,
          active_minutes: true,
          stairs_climbed: true,
          calories_estimated: true,
          source: true,
          synced_at: true,
          created_at: true,
        },
      });

      return rows.map((r) => ({
        id: r.id,
        date: r.date.toISOString().split('T')[0],
        stepCount: r.step_count,
        goal: r.goal,
        distanceMeters: r.distance_meters?.toNumber() ?? null,
        activeMinutes: r.active_minutes,
        stairsClimbed: r.stairs_climbed,
        caloriesEstimated: r.calories_estimated,
        source: r.source,
        syncedAt: r.synced_at,
        createdAt: r.created_at,
      }));
    } catch (error) {
      throw new InternalServerErrorException('Failed to fetch mood logs');
    }
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
