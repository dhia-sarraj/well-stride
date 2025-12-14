import { ApiProperty } from '@nestjs/swagger';
import {
  IsEmail,
  IsEnum,
  IsString,
  MaxLength,
  MinLength,
  NotContains,
} from 'class-validator';
import { user_provider as Provider } from 'generated/prisma/enums';

export class RegisterUserDto {
  @ApiProperty({
    description: 'Username',
    required: true,
    type: 'string',
    example: 'Your Name',
  })
  @IsString()
  @MinLength(3)
  username: string;

  @ApiProperty({
    description: 'Email',
    required: true,
    type: 'string',
    example: 'youremail@example.com',
  })
  @IsEmail()
  email: string;

  @ApiProperty({
    description: 'Password: Min 6 characters',
    required: true,
    type: 'string',
    example: 'Password123',
  })
  @IsString()
  @MinLength(6)
  @MaxLength(16)
  @NotContains(' ', { message: "The password shouldn't contain spaces" })
  password: string;

  @ApiProperty({
    description: 'Confirm Password, it must be the same as the password',
    required: true,
    type: 'string',
    example: 'Password123',
  })
  @IsString()
  passwordConf: string;

  @ApiProperty({
    description: 'Authentication Provider',
    required: true,
    enum: Provider,
    example: Provider.Email,
  })
  @IsEnum(Provider, { message: 'Provider must be Email or Google' })
  provider: Provider;
}
