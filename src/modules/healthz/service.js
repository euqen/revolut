import { setTimeout } from "timers/promises";

let isGracefullShutdownStarted = false;

async function startGracefullShutdown({ failureThreshold, periodSeconds } = {}) {
    isGracefullShutdownStarted = true;

    if (Number.isFinite(failureThreshold) && Number.isFinite(periodSeconds)) {
        const timeout = failureThreshold * periodSeconds * 1000;

        console.info(
            `Waiting ${timeout}ms to make sure that the Kubernetes is getting notified via readinessProbe fail`
        );
        
        await setTimeout(timeout);
    }
}

async function isShuttingDown() {
    return isGracefullShutdownStarted;
}

export default {
    startGracefullShutdown,
    isShuttingDown,
};