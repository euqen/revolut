import * as dotenv from 'dotenv'

dotenv.config() 

export default {
    port: process.env.PORT || 3003,
    db: {
        mock: toBoolean(process.env.MOCK_DB),
        host: process.env.MYSQL_HOST || '127.0.0.1',
        dialect: process.env.DB_DIALECT || 'mysql',
        username: process.env.MYSQL_USER || 'app_user',
        password: process.env.MYSQL_PASSWORD,
        database: process.env.MYSQL_DATABASE || 'app_db',
        port: process.env.MYSQL_PORT || 3306,
    }
};

function toBoolean(value) {
    return value === 'true';
}