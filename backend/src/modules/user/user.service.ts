import { Injectable, InternalServerErrorException } from '@nestjs/common';
import { PrismaService } from 'src/modules/prisma/prisma.service';

@Injectable()
export class UserService {
  constructor(private prisma: PrismaService) {}

  async remove(userId: string) {
    try {
      await this.prisma.users.delete({
        where: { id: userId },
      });

      return { message: 'User deleted' };
    } catch (error) {
      throw new InternalServerErrorException('Server error');
    }
  }
}
