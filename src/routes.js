import express from "express";
import helloModuleRoutes from "./modules/hello/routes.js";
import healthzModuleRoutes from "./modules/healthz/routes.js";

const router = express.Router();

router.use("/hello", helloModuleRoutes);
router.use("/healthz", healthzModuleRoutes);

export default router;