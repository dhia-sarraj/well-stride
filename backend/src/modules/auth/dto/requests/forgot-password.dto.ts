import { ApiProperty } from '@nestjs/swagger';
import { IsEmail } from 'class-validator';

export class ForgotPasswordDto {
  @ApiProperty({
    description: 'Email',
    required: true,
    type: 'string',
    example: 'youremail@example.com',
  })
  @IsEmail()
  email: string;
}
