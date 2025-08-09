import { Request, Response, NextFunction } from "express";
import asyncHandler from "express-async-handler";
import Token from "./token.model";
import User from "../auth.model";

const validateToken = asyncHandler(async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    if (!req.body || Object.keys(req.body).length === 0) {
        res.status(400).json({ status: false, message: "Lütfen bir token doğrulamak için gerekli alanları doldurun" });
        return;
    }

    const { token } = req.body;
    if (!token) {
        res.status(400).json({ status: false, message: "Token alanı gereklidir" });
        return;
    }

    const tokenData = await Token.findOne({ token });
    if (!tokenData) {
        res.status(401).json({ status: false, message: "Geçersiz veya süresi dolmuş token" });
        return;
    }

    const user = await User.findOne({ id: tokenData.userId }).select('-password');

    res.status(200).json({ status: true, user: user });
});

export { validateToken };