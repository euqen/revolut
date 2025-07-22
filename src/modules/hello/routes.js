import express from "express";
import { upsertUsername, getHelloBirthdayMessage } from "./controller.js";

const router = express.Router();

router.put("/:username", upsertUsername);
router.get("/:username", getHelloBirthdayMessage);

export default router;