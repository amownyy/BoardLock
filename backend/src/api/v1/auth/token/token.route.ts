import express from 'express';
import { validateToken } from './token.controller';

const router = express.Router();

router.post<{}, {}>('/validate', validateToken);

export default router;