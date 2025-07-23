
import { Umzug, SequelizeStorage } from 'umzug'
import sequelize from './src/db/index.js'

async function migrate() {
  const umzug = new Umzug({
      migrations: {glob: 'src/migrations/*.js'},
      context: sequelize.getQueryInterface(),
      storage: new SequelizeStorage({ sequelize }),
      logger: console,
  });

  await umzug.up();

  console.log("Migrations completed");
}

export default migrate();