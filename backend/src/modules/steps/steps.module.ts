import { Module } from '@nestjs/common';
import { StepsService } from './steps.service';
import { StepsController } from './steps.controller';
import { PrismaModule } from '../prisma/prisma.module';

@Module({
  controllers: [StepsController],
  providers: [StepsService],
  imports: [PrismaModule],
})
export class StepsModule {}
