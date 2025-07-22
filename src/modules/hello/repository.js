import User from "./model.js";

async function upsertUsername(user) {
    await User.upsert(user);
}

async function getUserByUsername(username) {
    const user = await User.findOne({ where: { username } });

    return user;
}

export default {
    upsertUsername,
    getUserByUsername,
}