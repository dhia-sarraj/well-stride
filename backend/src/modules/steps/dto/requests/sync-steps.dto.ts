import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsDateString,
  IsEnum,
  IsInt,
  IsNumber,
  IsOptional,
  Min,
} from 'class-validator';
import { step_source_enum } from 'generated/prisma/enums';

export class SyncStepsDto {
  @ApiProperty({
    description: 'Date for the daily summary (YYYY-MM-DD)',
    example: '2025-01-31',
  })
  @IsDateString()
  date: string;

  @ApiProperty({
    description: 'Total step count for the day',
    example: 8432,
  })
  @IsInt()
  @Min(0)
  stepCount: number;

  @ApiPropertyOptional({
    description: 'Daily goal (steps) for that day',
    example: 10000,
  })
  @IsOptional()
  @IsInt()
  @Min(1000)
  goal?: number;

  @ApiPropertyOptional({
    description: 'Distance in meters for the day',
    example: 6200,
  })
  @IsOptional()
  @IsNumber()
  distanceMeters?: number;

  @ApiPropertyOptional({
    description: 'Active minutes for the day',
    example: 52,
  })
  @IsOptional()
  @IsInt()
  activeMinutes?: number;

  @ApiPropertyOptional({
    description: 'Stairs climbed',
    example: 12,
  })
  @IsOptional()
  @IsInt()
  stairsClimbed?: number;

  @ApiPropertyOptional({
    description: 'Estimated calories for the day',
    example: 310,
  })
  @IsOptional()
  @IsInt()
  caloriesEstimated?: number;

  @ApiPropertyOptional({
    description: 'Source of the data',
    enum: step_source_enum,
    example: step_source_enum.Googlefit,
  })
  @IsOptional()
  @IsEnum(step_source_enum)
  source?: step_source_enum;
}
