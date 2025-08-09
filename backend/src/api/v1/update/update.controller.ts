import { Request, Response, NextFunction } from "express";
import asyncHandler from "express-async-handler";
import Update from "./update.model";

const createUpdate = asyncHandler(async (req: Request, res: Response) => {
    const apiKey = req.headers['x-api-key'] as string;
    if (!apiKey || apiKey !== process.env.API_KEY) {
        res.status(401).json({
            status: false,
            message: "Geçersiz API anahtarı"
        });
        return;
    }
    const { version, url } = req.body;
    if (!version || !url) {
        res.status(400).json({
            status: false,
            message: "Version ve URL gereklidir"
        });
        return;
    }
    const newUpdate = new Update({
        version,
        url
    });
    await newUpdate.save();
    res.status(201).json({
        status: true,
        data: newUpdate
    });
});

const getUpdates = asyncHandler(async (req: Request, res: Response) => {
    const updates = await Update.find().select('-__v').select('-createdAt').select('-_id');
    if (!updates || updates.length === 0) {
        res.status(404).json({
            status: false,
            message: "Güncelleme bulunamadı"
        });
        return;
    }
    res.status(200).json({
        status: true,
        data: updates
    });
});

const getLatestUpdate = asyncHandler(async (req: Request, res: Response) => {
    const latestUpdate = await Update.findOne().sort({ createdAt: -1 }).select('-__v').select('-createdAt').select('-_id');
    if (!latestUpdate) {
        res.status(404).json({
            status: false,
            message: "En son güncelleme bulunamadı"
        });
        return;
    }
    res.status(200).json({
        status: true,
        data: latestUpdate
    });
});

export { createUpdate, getUpdates, getLatestUpdate };