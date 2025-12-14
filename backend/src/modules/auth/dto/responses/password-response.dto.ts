import { ApiProperty } from '@nestjs/swagger';

export class PasswordResponse {
  @ApiProperty({
    description: 'Success',
  })
  message: string;
}
