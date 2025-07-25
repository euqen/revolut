import * as dotenv from 'dotenv'

dotenv.config() 

export default {
    port: process.env.PORT || 3003,
    db: {
        dialect: process.env.DB_DIALECT || 'sqlite',
        storage: process.env.DB_STORAGE || 'appdb.sqlite',
    }
};