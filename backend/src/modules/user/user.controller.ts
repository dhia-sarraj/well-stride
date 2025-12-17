import { Controller, Delete, UseGuards } from '@nestjs/common';
import { UserService } from './user.service';
import {
  ApiBearerAuth,
  ApiOkResponse,
  ApiOperation,
  ApiResponse,
  ApiTags,
} from '@nestjs/swagger';
import { User } from './entities/user.entity';
import { AuthGuard } from '@nestjs/passport';
import { GetUser } from '../auth/decorators/get-user.decorator';

@ApiBearerAuth()
@ApiTags('Users')
@Controller('api/users')
export class UserController {
  constructor(private readonly userService: UserService) {}

  @Delete('me')
  @ApiOperation({
    summary: 'DELETE CURRENT USER',
    description: 'Delete the authenticated user account',
  })
  @ApiOkResponse({
    content: { 'application/json': { example: { message: 'User deleted' } } },
  })
  @ApiResponse({ status: 400, description: 'Bad Request' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 500, description: 'Server error' })
  @UseGuards(AuthGuard('jwt'))
  remove(@GetUser() user: User) {
    return this.userService.remove(user.id);
  }
}
