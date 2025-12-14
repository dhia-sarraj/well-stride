import { ApiProperty } from '@nestjs/swagger';
import { IsString } from 'class-validator';

export class ResetPasswordDto {
  @ApiProperty({
    description: 'Reset Token',
    type: 'string',
    example: '9f1c3e7a8b4d2f6c1a0e9b7d4...',
  })
  @IsString()
  token: string;

  @ApiProperty({
    description: 'User New Password',
    required: true,
    type: 'string',
    example: 'Password123',
  })
  @IsString()
  newPassword: string;
}
