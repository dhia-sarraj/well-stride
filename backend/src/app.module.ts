import { Module } from '@nestjs/common';
import { AuthModule } from './modules/auth/auth.module';
import { UserModule } from './modules/user/user.module';
import { PrismaModule } from './modules/prisma/prisma.module';
import { ProfileModule } from './modules/profile/profile.module';
import { StepsModule } from './modules/steps/steps.module';

@Module({
  imports: [AuthModule, PrismaModule, UserModule, ProfileModule, StepsModule],
})
export class AppModule {}
