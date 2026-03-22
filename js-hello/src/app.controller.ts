import { Controller, Get, Post, Body } from '@nestjs/common';
import { ApiOperation, ApiResponse } from '@nestjs/swagger';
import { AppService } from './app.service';

@Controller()
export class AppController {
  constructor(private readonly appService: AppService) {}

  @Get()
  @ApiOperation({ summary: 'Get loan service log entry' })
  @ApiResponse({ status: 200, description: 'Sample structured JSON log for a loan application request' })
  getLoanLog() {
    return this.appService.getLoanLog();
  }

  @Post()
  @ApiOperation({ summary: 'Receive loan service webhook' })
  @ApiResponse({ status: 200, description: 'Sample structured JSON log for a webhook event' })
  postLoanLog(@Body() payload: any) {
    return this.appService.postLoanLog(payload);
  }

  @Get('health')
  @ApiOperation({ summary: 'Health check' })
  @ApiResponse({ status: 200, description: 'Service is healthy' })
  getHealth() {
    return { status: 'ok' };
  }
}
