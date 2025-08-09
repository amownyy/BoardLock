import { Request, Response, NextFunction } from "express";
import asyncHandler from "express-async-handler";
import Board from "./board.model";

const createBoard = asyncHandler(async (req: Request, res: Response) => {
    const apiKey = req.headers['x-api-key'] as string;
    if (!apiKey || apiKey
        !== process.env.API_KEY) {
        res.status(401).json({
            status: false,
            message: "Geçersiz API anahtarı"
        });
        return;
    }
    const { schoolId, name } = req.body;
    if (!schoolId || !name) {
        res.status(400).json({
            status: false,
            message: "Okul ID ve Tahta adı gereklidir"
        });
        return;
    }
    const existingBoard = await Board.find
        ({ schoolId, name });
    if (existingBoard.length > 0) {
        res.status(400).json({
            status: false,
            message: "Bu okul için bu isimde bir tahta zaten var"
        });
        return;
    }
    const newBoard = new Board({
        schoolId,
        name,
        status: "Kilitli",
    });
    await newBoard.save();
    res.status(201).json({
        status: true,
        data: newBoard
    });
});

const getBoards = asyncHandler(async (req: Request, res: Response) => {
    if (!req.params.schoolId) {
        res.status(400).json({
            status: false,
            message: "Tahtaların listelenmesi için Okul ID gereklidir"
        });
        return;
    }
    const schoolId = req.params.schoolId;
    const boards = await Board.find({ schoolId });
    res.status(200).json({
        status: true,
        data: boards
    });
});

const getBoardByName = asyncHandler(async (req: Request, res: Response) => {
    if (!req.params.schoolId || !req.params.name) {
        res.status(400).json({
            status: false,
            message: "Tahta adı ve Okul ID gereklidir"
        });
        return;
    }
    const { schoolId, name } = req.params;
    const board = await Board.findOne({ schoolId, name });
    if (!board) {
        res.status(404).json({
            status: false,
            message: "Tahta bulunamadı"
        });
        return;
    }
    res.status(200).json({
        status: true,
        data: board
    });
});

const lockBoard = asyncHandler(async (req: Request, res: Response) => {
    if (!req.params.schoolId || !req.params.name) {
        res.status(400).json({
            status: false,
            message: "Tahta adı ve Okul ID gereklidir"
        });
        return;
    }
    const { schoolId, name } = req.params;
    const board = await Board.findOne(
        { schoolId, name }
    );
    if (!board) {
        res.status(404).json({
            status: false,
            message: "Tahta bulunamadı"
        });
        return;
    }
    await Board.findByIdAndUpdate(
        board._id,
        { status: "Kilitli" },
        { new: true }
    );
    res.status(200).json({
        status: true,
        message: "Tahta başarıyla kilitlendi"
    });
});

const unLockBoard = asyncHandler(async (req: Request, res: Response) => {
    if (!req.params.schoolId || !req.params.name) {
        res.status(400).json({
            status: false,
            message: "Tahta adı ve Okul ID gereklidir"
        });
        return;
    }
    const { schoolId, name } = req.params;
    const board = await Board.findOne(
        { schoolId, name }
    );
    if (!board) {
        res.status(404).json({
            status: false,
            message: "Tahta bulunamadı"
        });
        return;
    }
    await Board.findByIdAndUpdate(
        board._id,
        { status: "Aktif" },
        { new: true }
    );
    res.status(200).json({
        status: true,
        message: "Tahta başarıyla kilidi açıldı"
    });
});

const activateBoard = asyncHandler(async (req: Request, res: Response) => {
    if (!req.params.schoolId || !req.params.name) {
        res.status(400).json({
            status: false,
            message: "Tahta adı ve Okul ID gereklidir"
        });
        return;
    }
    const { schoolId, name } = req.params;
    const board = await Board.findOne(
        { schoolId, name }
    );
    if (!board) {
        res.status(404).json({
            status: false,
            message: "Tahta bulunamadı"
        });
        return;
    }
    await Board.findByIdAndUpdate(
        board._id,
        { status: "Aktif" },
        { new: true }
    );
    res.status(200).json({
        status: true,
        message: "Tahta başarıyla aktif edildi"
    });
});

const shutDownBoard = asyncHandler(async (req: Request, res: Response) => {
    if (!req.params.schoolId || !req.params.name) {
        res.status(400).json({
            status: false,
            message: "Tahta adı ve Okul ID gereklidir"
        });
        return;
    }
    const { schoolId, name } = req.params;
    const board = await Board.findOne(
        { schoolId, name }
    );
    if (!board) {
        res.status(404).json({
            status: false,
            message: "Tahta bulunamadı"
        });
        return;
    }
    await Board.findByIdAndUpdate(
        board._id,
        { status: "Kapalı" },
        { new: true }
    );
    res.status(200).json({
        status: true,
        message: "Tahta başarıyla kapatıldı"
    });
});

const restartBoard = asyncHandler(async (req: Request, res: Response) => {
    if (!req.params.schoolId || !req.params.name) {
        res.status(400).json({
            status: false,
            message: "Tahta adı ve Okul ID gereklidir"
        });
        return;
    }
    const { schoolId, name } = req.params;
    const board = await Board.findOne(
        { schoolId, name }
    );
    if (!board) {
        res.status(404).json({
            status: false,
            message: "Tahta bulunamadı"
        });
        return;
    }
    await Board.findByIdAndUpdate(
        board._id,
        { status: "Yeniden Başlatılıyor" },
        { new: true }
    );
    res.status(200).json({
        status: true,
        message: "Tahta başarıyla yeniden başlatıldı"
    });
});

export { createBoard, getBoards, getBoardByName, lockBoard, unLockBoard, activateBoard, shutDownBoard, restartBoard };