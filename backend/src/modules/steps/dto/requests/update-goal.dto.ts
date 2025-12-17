import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsInt, Min } from 'class-validator';

export class UpdateGoalDto {
  @ApiPropertyOptional({
    description: 'Daily goal (steps) for that day',
    example: 10000,
  })
  @IsInt()
  @Min(1000)
  goal: number;
}
