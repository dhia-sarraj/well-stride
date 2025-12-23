import { ApiPropertyOptional } from '@nestjs/swagger';
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
  @ApiPropertyOptional({
    description: 'Username',
    type: 'string',
  })
  @IsString()
  username: string;

  @ApiPropertyOptional({
    description: 'User Photo',
    type: 'string',
  })
  @IsOptional()
  @IsString()
  photoUrl?: string;

  @ApiPropertyOptional({
    description: 'User Age',
    type: 'number',
    example: 20,
  })
  @IsOptional()
  @IsInt()
  @Min(10)
  @Max(130)
  age?: number;

  @ApiPropertyOptional({
    description: 'User Gender',
    enum: gender_enum,
    example: gender_enum.Male,
  })
  @IsOptional()
  @IsEnum(gender_enum)
  gender?: gender_enum;

  @ApiPropertyOptional({
    description: 'User Height in cm',
    type: 'number',
    example: 180,
  })
  @IsOptional()
  @IsNumber()
  height?: number;

  @ApiPropertyOptional({
    description: 'User Weight in kg',
    type: 'number',
    example: 70,
  })
  @IsOptional()
  @IsNumber()
  weight?: number;
}
