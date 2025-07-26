import * as dotenv from 'dotenv'

dotenv.config() 

export default {
    port: process.env.PORT || 3003,
    db: {
        dialect: process.env.DB_DIALECT || 'sqlite',
        host: process.env.DB_HOST || 'localhost',
        port: process.env.DB_PORT || 3306,
        user: process.env.DB_USER || 'root',
        password: process.env.DB_PASSWORD || '',
        database: process.env.DB_NAME || 'revolut-hello-app-db',
    }
};