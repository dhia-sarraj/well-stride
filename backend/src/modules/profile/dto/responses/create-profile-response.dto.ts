import { ApiProperty } from '@nestjs/swagger';

export class CreatedProfileResponse {
  @ApiProperty({
    description: 'Success',
    type: 'string',
  })
  message: string;
}
