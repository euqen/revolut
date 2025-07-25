import { Sequelize } from "sequelize";
import config from "../config/index.js";

const sequelize = new Sequelize({
    dialect: config.db.dialect,
    storage: config.db.storage,
});

export default sequelize;