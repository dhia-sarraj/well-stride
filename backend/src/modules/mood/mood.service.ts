import { Injectable, InternalServerErrorException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { MoodRequestDto } from './dto/requests/mood-request.dto';
import { MoodResponseDto } from './dto/responses/mood-response.dto';
import { GetMoodsQueryDto } from './dto/requests/get-moods-query.dto';

@Injectable()
export class MoodService {
  constructor(private prisma: PrismaService) {}

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

  async addMood(userId: string, dto: MoodRequestDto): Promise<MoodResponseDto> {
    const stepsRecord = await this.prisma.step_summaries.findUnique({
      where: {
        user_id_date: {
          user_id: userId,
          date: new Date(),
        },
      },
      select: {
        step_count: true,
      },
    });

    let record;
    try {
      record = await this.prisma.mood_entries.create({
        data: {
          user_id: userId,
          emoji: dto.emoji,
          reason: dto.reason,
          note: dto.note,
          steps_at_time: stepsRecord?.step_count,
          created_at: new Date(),
        },
      });
    } catch (error) {
      throw new InternalServerErrorException('Internal Server Error');
    }

    return {
      emoji: record.emoji,
      reason: record.reason,
      note: record.note,
      stepsAtTime: record.steps_at_time,
      createdAt: record.created_at,
    };
  }

  async getMoods(
    userId: string,
    query: GetMoodsQueryDto,
  ): Promise<MoodResponseDto[]> {
    const { fromDate, toDate } = this.parseDateRange(query.from, query.to);

    try {
      const rows = await this.prisma.mood_entries.findMany({
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
          emoji: true,
          reason: true,
          note: true,
          steps_at_time: true,
          created_at: true,
        },
      });

      return rows.map((r) => ({
        id: r.id,
        emoji: r.emoji,
        reason: r.reason,
        note: r.note,
        stepsAtTime: r.steps_at_time,
        createdAt: r.created_at,
      }));
    } catch (error) {
      throw new InternalServerErrorException('Failed to fetch mood logs');
    }
  }
}
