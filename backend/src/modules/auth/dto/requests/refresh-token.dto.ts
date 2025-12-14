import { IsString } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class RefreshTokenDto {
  @ApiProperty({
    example:
      '5f1c3a9bd87f4f2e1abcc13d9b7f1e0b...',
  })
  @IsString()
  refreshToken: string;
}
