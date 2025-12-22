import {
  Controller,
  Delete,
  Get,
  Param,
  Post,
  UseGuards,
} from '@nestjs/common';
import { QuotesService } from './quotes.service';
import {
  ApiBearerAuth,
  ApiOperation,
  ApiResponse,
  ApiTags,
} from '@nestjs/swagger';
import { QuoteResponse } from './dto/responses/quote-response.dto';
import { GetUser } from '../auth/decorators/get-user.decorator';
import { User } from '../user/entities/user.entity';
import { AuthGuard } from '@nestjs/passport';

@ApiTags('Quotes')
@Controller('api/quotes')
export class QuotesController {
  constructor(private readonly quotesService: QuotesService) {}

  // GET: /quotes/random
  @Get('random')
  @ApiOperation({
    summary: 'GET A RANDOM QUOTE',
  })
  @ApiResponse({
    status: 200,
    description: 'Successfully retrieved a random quote',
    type: QuoteResponse,
  })
  @ApiResponse({
    status: 500,
    description: 'Internal Server Error',
  })
  async getRandom() {
    return await this.quotesService.getRandomQuote();
  }

  // POST: /quotes/:id/favorite
  @Post(':id/favorite')
  @ApiBearerAuth()
  @UseGuards(AuthGuard('jwt'))
  @ApiOperation({
    summary: 'ADD A QUOTE TO FAVORITES',
  })
  @ApiResponse({
    status: 200,
    description: 'Successfully added the quote',
    type: QuoteResponse,
  })
  @ApiResponse({
    status: 500,
    description: 'Internal Server Error',
  })
  async addFavorite(@GetUser() user: User, @Param('id') id: string) {
    return await this.quotesService.addFavorite(user.id, id);
  }

  // GET: /quotes/favorites
  @Get('favorites')
  @ApiBearerAuth()
  @UseGuards(AuthGuard('jwt'))
  @ApiOperation({
    summary: 'GET A RANDOM QUOTE',
  })
  @ApiResponse({
    status: 200,
    description: 'Successfully retrieved a random quote',
    type: QuoteResponse,
  })
  @ApiResponse({
    status: 404,
    description: 'No favorite quotes found for this user.',
  })
  @ApiResponse({
    status: 500,
    description: 'Internal Server Error',
  })
  async getFavorites(@GetUser() user: User) {
    return await this.quotesService.getFavorites(user.id);
  }

  // DELETE: /quotes/:id/favorite
  @Delete(':id/favorite')
  @ApiBearerAuth()
  @UseGuards(AuthGuard('jwt'))
  @ApiOperation({
    summary: 'REMOVE FAVORITE QUOTE',
    description: 'Remove a quote from user favorites',
  })
  @ApiResponse({
    status: 204,
    description: 'Favorite quote removed successfully',
  })
  @ApiResponse({
    status: 404,
    description: 'Favorite quote not found',
  })
  async deleteFavorite(@GetUser() user: User, @Param('id') id: string) {
    return await this.quotesService.deleteFavorite(user.id, id);
  }
}
