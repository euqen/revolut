import { Sequelize } from "sequelize";
import config from "../config/index.js";

const sequelize = new Sequelize(config.db.mock ? 'sqlite:memory' : {
    dialect: config.db.dialect,
    host: config.db.host,
    username: config.db.username,
    password: config.db.password,
    database: config.db.database,
    port: config.db.port,
});

export default sequelize;