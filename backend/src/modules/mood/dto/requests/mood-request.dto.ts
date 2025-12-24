import { ApiProperty } from '@nestjs/swagger';
import { IsEnum, IsOptional, IsString } from 'class-validator';
import { mood_enum, mood_reason_enum } from 'generated/prisma/enums';

export class MoodRequestDto {
  @ApiProperty({
    description: 'Mood with an emoji',
    enum: mood_enum,
    required: true,
  })
  @IsEnum(mood_enum)
  emoji: mood_enum;

  @ApiProperty({
    description: 'Why the user is feeling like that',
    enum: mood_reason_enum,
    required: true,
  })
  @IsEnum(mood_reason_enum)
  reason: mood_reason_enum;

  @ApiProperty({
    description: 'Optional Note',
    type: 'string',
    required: false,
  })
  @IsOptional()
  @IsString()
  note?: string;
}
