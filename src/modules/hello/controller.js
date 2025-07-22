import repository from "./repository.js";
import service from "./service.js";

export async function upsertUsername(req, res) {
    const { username } = req.params;
    const { dateOfBirth } = req.body;

    const user = { username, dateOfBirth };

    await repository.upsertUsername(user);

    res.status(204).send();
}

export async function getHelloBirthdayMessage(req, res) {
    const { username } = req.params;

    const helloBirthdayMessage = await service.getHelloBirthdayMessage(username);

    if (!helloBirthdayMessage) {
        res.status(404).send({ message: `username ${username} is not found` });
        return;
    }

    res.status(200).send({ message: helloBirthdayMessage });
}