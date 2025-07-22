import graceful from "../../utils/graceful.js"; 

function livenessCheck(req, res) {
    res.status(200).send({ message: "OK" });
}

async function readinessCheck(req, res) {
    const isShuttingDown = await graceful.isShuttingDown();

    if (isShuttingDown) {
        res.status(500).send({ message: "Service is shutting down" });
        return;
    }

    res.status(200).send({ message: "OK" });
}

export default {
    livenessCheck,
    readinessCheck,
};
