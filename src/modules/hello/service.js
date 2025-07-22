import { DateTime, Interval } from "luxon";
import repository from "./repository.js";

async function getHelloBirthdayMessage(username) {
    const user = await repository.getUserByUsername(username);

    if (!user) {
        return null;
    }

    const today = DateTime.now().startOf('day');
    const birthDate = DateTime.fromISO(user.dateOfBirth);
    let nextBirthday = birthDate.set({ year: today.year });
    
    if (nextBirthday < today.startOf('day')) {
        nextBirthday = nextBirthday.plus({ years: 1 });
    }

    const interval = Interval.fromDateTimes(today, nextBirthday);
    const diffInDays = interval.length('days');

    if (diffInDays === 0) {
        return `Hello, ${username}! Happy birthday!`;
    }

    return `Hello, ${username}! Your birthday is in ${diffInDays} day(s)!`;
}

export default {
    getHelloBirthdayMessage,
}
