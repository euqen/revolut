import { jest } from '@jest/globals';

global.console = {
  ...console,
  log: jest.fn(),
  debug: jest.fn(),
  info: jest.fn(),
  warn: jest.fn(),
  error: jest.fn(),
};

jest.setTimeout(10000);

// Fix for circular reference issues with Sequelize in Jest
process.env.NODE_ENV = 'test'; 