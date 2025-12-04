import { Injectable } from '@nestjs/common';
import { PrismaService } from 'src/modules/prisma/prisma.service';
import { users as UserModel } from 'generated/prisma/client';

@Injectable()
export class UserService {
  constructor(private prisma: PrismaService) {}

  async remove(id: UserModel['id']): Promise<void> {
    await this.prisma.users.delete({
      where: { id },
    });
  }
}
