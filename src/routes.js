import express from "express";
import helloModuleRoutes from "./modules/hello/routes.js";

const router = express.Router();

router.use("/hello", helloModuleRoutes);

export default router;