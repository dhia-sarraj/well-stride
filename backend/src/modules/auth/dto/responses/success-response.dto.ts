import { ApiProperty } from '@nestjs/swagger';

export class SuccessResponse {
  @ApiProperty({
    description: 'Operation succeeded',
  })
  message: string;
}
