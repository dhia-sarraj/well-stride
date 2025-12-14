import {
  Injectable,
  InternalServerErrorException,
  UnauthorizedException,
} from '@nestjs/common';
import { PrismaService } from 'src/modules/prisma/prisma.service';
import { User } from './entities/user.entity';

@Injectable()
export class UserService {
  constructor(private prisma: PrismaService) {}

  async remove(id: string, user: User) {
    if (id !== user.id) throw new UnauthorizedException('Unauthorized');

    try {
      await this.prisma.users.delete({
        where: { id },
      });

      return { message: 'User deleted' };
    } catch (error) {
      throw new InternalServerErrorException('Server error');
    }
  }
}
