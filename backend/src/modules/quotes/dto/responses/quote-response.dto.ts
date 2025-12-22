import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { step_source_enum } from 'generated/prisma/enums';

export class QuoteResponse {
  @ApiProperty({
    description: 'Record ID',
    type: 'string',
  })
  id: string;

  @ApiProperty({
    description: 'Quote text',
    example: 'Small steps every day lead to big change.',
  })
  text: string;

  @ApiProperty({
    description: 'Author of the quote',
    example: 'Unknown',
    nullable: true,
  })
  author: string | null;

  @ApiPropertyOptional({
    description: 'Quote category',
    example: 'Motivation',
    nullable: true,
  })
  category: string | null;

  @ApiProperty({
    description: 'Creation timestamp',
    example: '2025-01-31T00:00:00.000Z',
  })
  createdAt: string;
}
