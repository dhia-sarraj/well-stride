import { Module } from '@nestjs/common';
import { MoodService } from './mood.service';
import { MoodController } from './mood.controller';
import { PrismaModule } from '../prisma/prisma.module';

@Module({
  controllers: [MoodController],
  providers: [MoodService],
  imports: [PrismaModule],
})
export class MoodModule {}
