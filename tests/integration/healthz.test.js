import request from 'supertest';
import express from 'express';
import routes from '../../src/routes.js';
import migrate from '../../migrate.js';

const app = express();
app.use(express.json());
app.use(routes);

describe('Healthz Module Integration Tests', () => {
  beforeAll(async () => {
    await migrate();
  });

  describe('GET /healthz/liveness', () => {
    it('should return 200 with OK message', async () => {
      const response = await request(app)
        .get('/healthz/liveness')
        .expect(200);

      expect(response.body.message).toBe('OK');
    });
  });

  describe('GET /healthz/readiness', () => {
    it('should return 200 when service is healthy', async () => {
      const response = await request(app)
        .get('/healthz/readiness')
        .expect(200);

      expect(response.body.message).toBe('OK');
    });
  });
}); 