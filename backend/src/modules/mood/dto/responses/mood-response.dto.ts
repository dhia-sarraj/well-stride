import { ApiProperty } from '@nestjs/swagger';
import { mood_reason_enum } from 'generated/prisma/enums';

export class MoodResponseDto {
  @ApiProperty({
    description: 'Mood with an emoji',
    type: 'string',
  })
  emoji: string;

  @ApiProperty({
    description: 'Why the user is feeling like that',
    enum: mood_reason_enum,
  })
  reason: mood_reason_enum;

  @ApiProperty({
    description: 'Optional Note',
    type: 'string',
  })
  note: string | null;

  @ApiProperty({
    description: 'Steps recorded at the time user entered his mood',
    type: 'number',
  })
  stepsAtTime: number | null;

  @ApiProperty({
    description: 'Date when the user was created',
    type: 'string',
    format: 'date-time',
  })
  createdAt: Date;
}
