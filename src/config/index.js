export default {
    port: process.env.PORT || 3003,
    db: {
        dialect: process.env.DB_DIALECT || 'mysql',
        host: process.env.DB_HOST,
        port: process.env.DB_PORT,
        username: process.env.DB_USER,
        password: process.env.DB_PASSWORD,
        database: process.env.DB_NAME,
    }
};