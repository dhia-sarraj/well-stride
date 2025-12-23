import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { gender_enum } from 'generated/prisma/enums';

export class ProfileResponse {
  @ApiProperty({
    description: 'User ID',
    type: 'string',
    example: '4eef7ap8-af58-4cbe-93bc-3bb802f4866f',
  })
  userId: string;

  @ApiPropertyOptional({
    description: 'User Photo',
    type: 'string',
  })
  username: string;

  @ApiPropertyOptional({
    description: 'User Photo',
    type: 'string',
    nullable: true,
  })
  photoUrl: string | null;

  @ApiPropertyOptional({
    description: 'User Age',
    type: 'number',
    example: 20,
    nullable: true,
  })
  age: number | null;

  @ApiPropertyOptional({
    description: 'User Gender',
    enum: gender_enum,
    example: gender_enum.Male,
    nullable: true,
  })
  gender: gender_enum | null;

  @ApiPropertyOptional({
    description: 'User Height in cm',
    type: 'number',
    example: 180,
    nullable: true,
  })
  height: number | null;

  @ApiPropertyOptional({
    description: 'User Weight in kg',
    type: 'number',
    example: 70,
    nullable: true,
  })
  weight: number | null;

  @ApiProperty({
    description: 'Profile created at',
    type: 'string',
    example: '2025-12-31 00:00:00.113+01',
  })
  createdAt: Date;
}
