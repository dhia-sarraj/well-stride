import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { step_source_enum } from 'generated/prisma/enums';

export class StepSummaryResponse {
  @ApiProperty({
    description: 'Record ID',
    type: 'string',
  })
  id: string;

  @ApiProperty({
    description: 'Date for the daily summary (YYYY-MM-DD)',
    example: '2025-01-31',
  })
  date: string;

  @ApiProperty({
    description: 'Total step count for the day',
    example: 8432,
  })
  stepCount: number;

  @ApiPropertyOptional({
    description: 'Daily goal (steps) for that day',
    example: 10000,
  })
  goal: number;

  @ApiPropertyOptional({
    description: 'Distance in meters for the day',
    example: 6200,
    nullable: true,
  })
  distanceMeters: number | null;

  @ApiPropertyOptional({
    description: 'Active minutes for the day',
    example: 52,
    nullable: true,
  })
  activeMinutes: number | null;

  @ApiPropertyOptional({
    description: 'Stairs climbed',
    example: 12,
    nullable: true,
  })
  stairsClimbed: number | null;

  @ApiPropertyOptional({
    description: 'Estimated calories for the day',
    example: 310,
    nullable: true,
  })
  caloriesEstimated: number | null;

  @ApiProperty({
    description: 'Source of the data',
    enum: step_source_enum,
    example: step_source_enum.Googlefit,
  })
  source: step_source_enum;

  @ApiProperty({
    description: 'Time of last sync',
    example: '2025-12-31T23:59:59.575Z',
  })
  syncedAt: Date;

  @ApiProperty({
    description: 'Date of creation',
    example: '2025-12-31T23:59:59.575Z',
  })
  createdAt: Date;
}
