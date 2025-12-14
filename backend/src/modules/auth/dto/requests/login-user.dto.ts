import { ApiProperty } from '@nestjs/swagger';
import { IsEmail, IsString } from 'class-validator';

export class LoginUserDto {
  @ApiProperty({
    description: 'Email',
    required: true,
    type: 'string',
    example: 'youremail@example.com',
  })
  @IsEmail()
  email: string;

  @ApiProperty({
    description: 'User Password',
    required: true,
    type: 'string',
    example: 'Password123',
  })
  @IsString()
  password: string;
}
