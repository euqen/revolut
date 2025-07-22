function upsertUsername(req, res) {
    const { username } = req.params;
    const { dateOfBirth } = req.body;

    res.status(204).send();
}

function getHelloBirthdayMessage(req, res) {
    const { username } = req.params;
    res.status(204).send();
}