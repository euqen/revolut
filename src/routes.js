import express from "express";
import helloModuleRoutes from "./hello/routes.js";

const router = express.Router();

router.use("/hello", helloModuleRoutes);

export default router;