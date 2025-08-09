import express from "express";
import { createSchool, getSchools, getSchool } from "./school.controller";

const router = express.Router();

router.put<{}, {}, {}>("/create", createSchool);
router.get<{}, {}, {}>("/", getSchools);
router.get<{}, {}, {}>("/:schoolId", getSchool);

export default router;