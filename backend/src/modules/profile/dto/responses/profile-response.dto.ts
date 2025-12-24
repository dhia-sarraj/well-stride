import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { gender_enum } from 'generated/prisma/enums';

export class ProfileResponse {
  @ApiProperty({
    description: 'User ID',
    type: 'string',
    example: '4eef7ap8-af58-4cbe-93bc-3bb802f4866f',
  })
  userId: string;

  @ApiProperty({
    description: 'Username',
    type: 'string',
  })
  username: string;

  @ApiPropertyOptional({
    description: 'User Photo',
    type: 'string',
    nullable: true,
  })
  photoUrl: string | null;

  @ApiProperty({
    description: 'User Age',
    type: 'number',
    example: 20,
  })
  age: number;

  @ApiProperty({
    description: 'User Gender',
    enum: gender_enum,
    example: gender_enum.Male,
  })
  gender: gender_enum;

  @ApiProperty({
    description: 'User Height in cm',
    type: 'number',
    example: 180,
  })
  height: number;

  @ApiProperty({
    description: 'User Weight in kg',
    type: 'number',
    example: 70,
  })
  weight: number;

  @ApiProperty({
    description: 'User steps target',
    type: 'number',
  })
  goal: number;

  @ApiProperty({
    description: 'Profile created at',
    type: 'string',
    example: '2025-12-31 00:00:00.113+01',
  })
  createdAt: Date;
}
