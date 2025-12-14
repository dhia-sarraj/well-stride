import { ApiProperty } from '@nestjs/swagger';
import { IsString } from 'class-validator';

export class changePasswordDto {
  @ApiProperty({
    description: 'User Current Password',
    required: true,
    type: 'string',
    example: 'Password123',
  })
  @IsString()
  currentPassword: string;

  @ApiProperty({
    description: 'User New Password',
    required: true,
    type: 'string',
    example: 'DorAte9875',
  })
  @IsString()
  newPassword: string;
}
