import { Request, Response, NextFunction } from "express";
import asyncHandler from "express-async-handler";
import User from "./auth.model";
import Token from "./token/token.model";

const registerUser = asyncHandler(async (req: Request, res: Response) => {
    const apiKey = req.headers['x-api-key'] as string;
    if (!apiKey || apiKey
        !== process.env.API_KEY) {
        res.status(401).json({
            status: false,
            message: "Geçersiz API anahtarı"
        });
        return;
    }
    if (!req.body || Object.keys(req.body).length === 0) {
        res.status(400).json({ status: false, message: "Lütfen bir kullanıcı oluşturmak için gerekli alanları doldurun" });
        return;
    }
    if (!req.body.name || !req.body.surname || !req.body.email || !req.body.phone || !req.body.password || !req.body.schoolId || !req.body.role) {
        res.status(400).json({ status: false, message: "Bazı alanlar eksik" });
        return;
    }
    const { name, surname, email, phone, password, schoolId, role } = req.body;

    const crypto = require('crypto');

    const id = crypto.randomUUID();

    const hashedPassword = crypto.createHash('sha256').update(password).digest('hex');

    const user = await User.create({ id, name, surname, email, phone, password: hashedPassword, schoolId, role });

    res.status(201).json({
        status: true,
        data: user
    });
});

const loginUser = asyncHandler(async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    const { phone, password } = req.body;
    const crypto = require('crypto');
    const hashedPassword = crypto.createHash('sha256').update(password).digest('hex');

    const user = await User.findOne({ phone });

    if (!user) {
        res.status(401).json({ status: false, message: "Kullanıcı bulunamadı" });
        return;
    }

    if (user.password !== hashedPassword) {
        res.status(401).json({ status: false, message: "Yanlış şifre" });
        return;
    }

    const token = crypto.randomBytes(16).toString('hex');
    const creationIP = req.ip;

    const existingToken = await Token.findOne({ userId: user.id });
    if (existingToken) {
        await Token.deleteOne({ userId: user.id });
    }
    
    await Token.create({ userId: user.id, token, creationIP });

    res.status(200).json({ status: true, token: token, user: user})
});

export { registerUser, loginUser };