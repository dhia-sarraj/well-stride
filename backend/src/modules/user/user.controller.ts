import { Controller, Param, Delete, UseGuards } from '@nestjs/common';
import { UserService } from './user.service';
import {
  ApiBearerAuth,
  ApiOkResponse,
  ApiOperation,
  ApiResponse,
  ApiTags,
} from '@nestjs/swagger';
import { users as UserModel } from '../../../generated/prisma/client';
import { User } from './entities/user.entity';
import { AuthGuard } from '@nestjs/passport';
import { GetUser } from '../auth/decorators/get-user.decorator';

@ApiBearerAuth()
@ApiTags('Users')
@Controller('api/users')
export class UserController {
  constructor(private readonly userService: UserService) {}

  @Delete(':id')
  @ApiOperation({
    summary: 'DELETE USER BY ID',
    description:
      'Private endpoint to delete a user by ID. The authenticated user can only delete their own account.',
  })
  @ApiOkResponse({
    content: { 'application/json': { example: { message: 'User deleted' } } },
  })
  @ApiResponse({ status: 400, description: 'Bad Request' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 500, description: 'Server error' })
  @UseGuards(AuthGuard('jwt'))
  remove(@Param('id') id: UserModel['id'], @GetUser() user: User) {
    return this.userService.remove(id, user);
  }
}
