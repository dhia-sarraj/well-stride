import { ApiProperty } from '@nestjs/swagger';
import {
  IsEnum,
  IsInt,
  IsNumber,
  IsOptional,
  IsString,
  Max,
  Min,
} from 'class-validator';
import { gender_enum } from 'generated/prisma/enums';

export class CreateProfileDto {
  @ApiProperty({
    description: 'Username',
    type: 'string',
  })
  @IsString()
  username: string;

  @ApiProperty({
    description: 'User Photo',
    type: 'string',
  })
  @IsOptional()
  @IsString()
  photoUrl?: string;

  @ApiProperty({
    description: 'User Age',
    type: 'number',
    example: 20,
    required: true,
  })
  @IsInt()
  @Min(10)
  @Max(130)
  age: number;

  @ApiProperty({
    description: 'User Gender',
    enum: gender_enum,
    example: gender_enum.Male,
    required: true,
  })
  @IsEnum(gender_enum)
  gender: gender_enum;

  @ApiProperty({
    description: 'User Height in cm',
    type: 'number',
    example: 180,
    required: true,
  })
  @IsNumber()
  height: number;

  @ApiProperty({
    description: 'User Weight in kg',
    type: 'number',
    example: 70,
    required: true,
  })
  @IsNumber()
  weight: number;

  @ApiProperty({
    description: 'User steps target',
    type: 'number',
    example: 15000,
    required: true,
    default: 10000,
  })
  @IsNumber()
  goal: number;
}
