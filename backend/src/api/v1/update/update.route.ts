import express from "express";
import { createUpdate, getUpdates, getLatestUpdate } from "./update.controller";

const router = express.Router();

router.put<{}, {}, {}>("/create", createUpdate);
router.get<{}, {}, {}>("/", getUpdates);
router.get<{}, {}, {}>("/latest", getLatestUpdate);

export default router;