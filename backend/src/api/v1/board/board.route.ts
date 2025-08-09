import express from "express";
import { createBoard, getBoards, getBoardByName, lockBoard, unLockBoard, activateBoard, shutDownBoard, restartBoard } from "./board.controller";

const router = express.Router();

router.put<{}, {}, {}>("/create", createBoard);
router.get<{}, {}, {}>("/:schoolId", getBoards);
router.get<{}, {}, {}>("/:schoolId/:name", getBoardByName);
router.post<{}, {}, {}>("/:schoolId/:name/lock", lockBoard);
router.post<{}, {}, {}>("/:schoolId/:name/unlock", unLockBoard);
router.post<{}, {}, {}>("/:schoolId/:name/activate", activateBoard);
router.post<{}, {}, {}>("/:schoolId/:name/shutdown", shutDownBoard);
router.post<{}, {}, {}>("/:schoolId/:name/restart", restartBoard);

export default router;