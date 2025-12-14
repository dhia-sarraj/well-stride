import { ApiProperty } from '@nestjs/swagger';
import { User } from 'src/modules/user/entities/user.entity';

export class LoginResponse {
  @ApiProperty({
    description: 'User Data',
    type: () => User,
  })
  user: User;

  @ApiProperty({
    description: 'Access Token',
    type: 'string',
    example:
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
  })
  accessToken: string;

  @ApiProperty({
    description: 'Refresh Token',
    type: 'string',
    example:
      '5f1c3a9bd87f4f2e1abcc13d9b7f1e0b1d4f...',
  })
  refreshToken: string;
}
