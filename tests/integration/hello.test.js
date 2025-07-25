import request from 'supertest';
import express from 'express';
import routes from '../../src/routes.js';
import migrate from '../../migrate.js';
import User from '../../src/modules/hello/model.js';

// Create test app
const app = express();
app.use(express.json());
app.use(routes);

describe('Hello Module Integration Tests', () => {
  beforeAll(async () => {
    await migrate();
    await User.sync();
  });

  beforeEach(async () => {
    try {
      await User.destroy({ where: {} });
    } catch (error) {
    }
  });

  describe('PUT /hello/:username', () => {
    it('should create a new user successfully', async () => {
      const username = 'eugene';
      const dateOfBirth = '1995-08-22';

      const response = await request(app)
        .put(`/hello/${username}`)
        .send({ dateOfBirth })
        .expect(204);

      expect(response.status).toBe(204);
      
      const users = await User.findAll({ where: { username } });
      expect(users).toHaveLength(1);
      expect(users[0].username).toBe(username);
      expect(users[0].dateOfBirth).toBe(dateOfBirth);
    });

    it('should update existing user successfully', async () => {
      const username = 'eugene';
      const initialDateOfBirth = '1995-08-22';
      const updatedDateOfBirth = '1995-08-29';

      await request(app)
        .put(`/hello/${username}`)
        .send({ dateOfBirth: initialDateOfBirth })
        .expect(204);

      const response = await request(app)
        .put(`/hello/${username}`)
        .send({ dateOfBirth: updatedDateOfBirth })
        .expect(204);

      expect(response.status).toBe(204);
      
      const users = await User.findAll({ where: { username } });
      expect(users).toHaveLength(1);
      expect(users[0].username).toBe(username);
      expect(users[0].dateOfBirth).toBe(updatedDateOfBirth);
    });

    it('should return 400 for invalid username format', async () => {
      const username = 'john123';
      const dateOfBirth = '1990-01-01';

      const response = await request(app)
        .put(`/hello/${username}`)
        .send({ dateOfBirth })
        .expect(400);

      expect(response.body.errors).toHaveLength(1);
      expect(response.body.errors[0].field).toBe('username');
    });

    it('should return 400 for invalid date format', async () => {
      const username = 'john';
      const dateOfBirth = 'invalid-date';

      const response = await request(app)
        .put(`/hello/${username}`)
        .send({ dateOfBirth })
        .expect(400);

      expect(response.body.errors).toHaveLength(1);
      expect(response.body.errors[0].field).toBe('dateOfBirth');
    });

    it('should return 400 for future date', async () => {
      const username = 'john';
      const futureDate = new Date();
      futureDate.setFullYear(futureDate.getFullYear() + 1);
      const dateOfBirth = futureDate.toISOString().split('T')[0];

      const response = await request(app)
        .put(`/hello/${username}`)
        .send({ dateOfBirth })
        .expect(400);

      expect(response.body.errors).toHaveLength(1);
      expect(response.body.errors[0].field).toBe('body.dateOfBirth');
      expect(response.body.errors[0].message).toBe('Date of birth cannot be in the future');
    });

    it('should return 400 for missing dateOfBirth', async () => {
      const username = 'john';

      const response = await request(app)
        .put(`/hello/${username}`)
        .send({})
        .expect(400);

      expect(response.body.errors).toHaveLength(1);
      expect(response.body.errors[0].field).toBe('dateOfBirth');
    });
  });

  describe('GET /hello/:username', () => {
    it('should return birthday message for existing user', async () => {
      const username = 'john';
      const dateOfBirth = '1990-01-01';
      
      await request(app)
        .put(`/hello/${username}`)
        .send({ dateOfBirth })
        .expect(204);

      const response = await request(app)
        .get(`/hello/${username}`)
        .expect(200);

      expect(response.body.message).toMatch(/Hello, john!/);
      expect(response.body.message).toMatch(/Your birthday is in \d+ day\(s\)!/);
    });

    it('should return 404 for non-existent user', async () => {
      const username = 'nonexistent';

      const response = await request(app)
        .get(`/hello/${username}`)
        .expect(404);

      expect(response.body.message).toBe(`username ${username} is not found`);
    });

    it('should return happy birthday message when birthday is today', async () => {
      const username = 'john';
      const today = new Date().toISOString().split('T')[0];
      
      await request(app)
        .put(`/hello/${username}`)
        .send({ dateOfBirth: today })
        .expect(204);

      const response = await request(app)
        .get(`/hello/${username}`)
        .expect(200);

      expect(response.body.message).toBe(`Hello, ${username}! Happy birthday!`);
    });

    it('should handle leap year birthdays correctly', async () => {
      const username = 'leapuser';
      const dateOfBirth = '2000-02-29';
      
      await request(app)
        .put(`/hello/${username}`)
        .send({ dateOfBirth })
        .expect(204);

      const response = await request(app)
        .get(`/hello/${username}`)
        .expect(200);

      expect(response.body.message).toMatch(/Hello, leapuser!/);
    });
  });
}); 