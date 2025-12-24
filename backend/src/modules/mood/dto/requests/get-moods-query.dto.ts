// src/moods/dto/get-moods.query.ts
import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsDateString, IsOptional } from 'class-validator';

export class GetMoodsQueryDto {
  @ApiPropertyOptional({
    description: 'Start date',
    example: '2025-01-01',
  })
  @IsOptional()
  @IsDateString()
  from?: string;

  @ApiPropertyOptional({
    description: 'End date',
    example: '2025-01-31',
  })
  @IsOptional()
  @IsDateString()
  to?: string;
}
