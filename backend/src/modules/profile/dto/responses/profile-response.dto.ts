import { ApiProperty } from '@nestjs/swagger';
import { gender_enum } from 'generated/prisma/enums';

export class ProfileResponse {
  @ApiProperty({
    description: 'User ID',
    type: 'string',
  })
  userId: string;

  @ApiProperty({
    description: 'User Photo',
    type: 'string',
  })
  photoUrl?: string;

  @ApiProperty({
    description: 'User Age',
    type: 'number',
  })
  age?: number;

  @ApiProperty({
    description: 'User Gender',
    enum: gender_enum,
  })
  gender?: gender_enum;

  @ApiProperty({
    description: 'User Height in cm',
    type: 'number',
  })
  height?: number;

  @ApiProperty({
    description: 'User Weight in kg',
    type: 'number',
  })
  weight?: number;

  @ApiProperty({
    description: 'Profile created at',
    type: 'string',
  })
  createdAt: Date;
}
