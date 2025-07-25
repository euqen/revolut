#!/usr/bin/env node

import { Umzug, SequelizeStorage } from 'umzug'
import sequelize from '../src/db/index.js'

(async () => {
  try {
    const umzug = new Umzug({
      migrations: {glob: 'src/migrations/*.js'},
      context: sequelize.getQueryInterface(),
      storage: new SequelizeStorage({ sequelize }),
    });

    await umzug.up();

    console.log("Migrations completed");
  } catch (error) {
    console.error('Migration failed:', error);
    process.exit(1);
  }
})();