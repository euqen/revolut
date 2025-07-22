import express from "express";
import { upsertUsername, getHelloBirthdayMessage } from "./controller.js";
import { validateUpsertUsername } from "./validator.js";

const router = express.Router();

router.put("/:username", validateUpsertUsername, upsertUsername);
router.get("/:username", getHelloBirthdayMessage);

export default router;