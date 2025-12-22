import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { QuoteResponse } from './dto/responses/quote-response.dto';
import { SuccessResponse } from '../auth/dto/responses/success-response.dto';

@Injectable()
export class QuotesService {
  constructor(private readonly prisma: PrismaService) {}

  async getRandomQuote(): Promise<QuoteResponse> {
    const count = await this.prisma.quotes.count();

    const randomIndex = Math.floor(Math.random() * count);

    const quote = await this.prisma.quotes.findFirst({
      skip: randomIndex,
    });

    return {
      id: quote!.id,
      text: quote!.text,
      author: quote!.author,
      category: quote!.category,
      createdAt: quote!.created_at.toISOString(),
    };
  }

  async addFavorite(userId: string, id: string): Promise<SuccessResponse> {
    const exists = await this.prisma.user_favorite_quotes.findUnique({
      where: {
        user_id_quote_id: {
          user_id: userId,
          quote_id: id,
        },
      },
    });

    if (!exists) {
      await this.prisma.user_favorite_quotes.create({
        data: {
          user_id: userId,
          quote_id: id,
          favorited_at: new Date(),
        },
      });
    }

    return {
      message: 'Quote successfully added to favorites',
    };
  }

  async getFavorites(userId: string): Promise<QuoteResponse[]> {
    const favorites = await this.prisma.user_favorite_quotes.findMany({
      where: { user_id: userId },
      include: {
        quotes: true,
      },
    });

    if (!favorites || favorites.length === 0) {
      throw new NotFoundException('No favorite quotes found for this user.');
    }
    return favorites.map((fav) => ({
      id: fav.quotes.id,
      text: fav.quotes.text,
      author: fav.quotes.author,
      category: fav.quotes.author,
      createdAt: fav.quotes.created_at.toISOString(),
    }));
  }

  async deleteFavorite(userId: string, id: string): Promise<SuccessResponse> {
    const result = await this.prisma.user_favorite_quotes.deleteMany({
      where: {
        quote_id: id,
        user_id: userId,
      },
    });

    if (result.count === 0) {
      throw new NotFoundException('Favorite quote not found for this user.');
    }

    return {
      message: 'Favorite quote removed successfully',
    };
  }
}
