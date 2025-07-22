import { Router } from "express";
import controller from "./controller.js";

const router = new Router();

router.get('/liveness', controller.livenessCheck);
router.get('/readiness', controller.readinessCheck);

export default router;
