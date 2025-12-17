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
    description: 'User Photo',
    type: 'string',
  })
  @IsOptional()
  @IsString()
  photoUrl?: string;

  @ApiProperty({
    description: 'User Age',
    type: 'number',
  })
  @IsOptional()
  @IsInt()
  @Min(10)
  @Max(130)
  age?: number;

  @ApiProperty({
    description: 'User Gender',
    enum: gender_enum,
  })
  @IsOptional()
  @IsEnum(gender_enum)
  gender?: gender_enum;

  @ApiProperty({
    description: 'User Height in cm',
    type: 'number',
  })
  @IsOptional()
  @IsNumber()
  height?: number;

  @ApiProperty({
    description: 'User Weight in kg',
    type: 'number',
  })
  @IsOptional()
  @IsNumber()
  weight?: number;
}
