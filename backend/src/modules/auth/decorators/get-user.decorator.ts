import {
  createParamDecorator,
  InternalServerErrorException,
} from '@nestjs/common';
import { ExecutionContextHost } from '@nestjs/core/helpers/execution-context-host';

export const GetUser = createParamDecorator(
  (data, ctx: ExecutionContextHost) => {
    const req = ctx.switchToHttp().getRequest();
    const user = req.user;

    if (!user) throw new InternalServerErrorException('Missed user');

    if (data) {
      if (Array.isArray(data)) {
        let userData = {};
        data.forEach((param) => {
          userData[param] = user[param];
        });
        return userData;
      }
      return user[data];
    }

    return user;
  },
);
