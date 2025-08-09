import { Request, Response, NextFunction } from "express";
import asyncHandler from "express-async-handler";
import School from "./school.model";

const createSchool = asyncHandler(async (req: Request, res: Response) => {
    const apiKey = req.headers['x-api-key'] as string;
    if (!apiKey || apiKey !== process.env.API_KEY) {
        res.status(401).json({
            status: false,
            message: "Geçersiz API anahtarı"
        });
        return;
    }
    const { id, name, } = req.body;
    if (!id || !name) {
        res.status(400).json({
            status: false,
            message: "Id ve Okul adı gereklidir"
        });
        return;
    }
    const existingSchool = await School.findOne({ id });
    if (existingSchool) {
        res.status(400).json({
            status: false,
            message: "Bu ID'ye sahip bir okul zaten var"
        });
        return;
    }
    const newSchool = new School({
        id,
        name,
        status: "Ödenmedi",
    });
    await newSchool.save();
    res.status(201).json({
        status: true,
        data: newSchool
    });
});

const getSchools = asyncHandler(async (req: Request, res: Response) => {
    const schools = await School.find().select('-__v').select('-createdAt').select('-status').select('-_id');
    if (!schools || schools.length === 0) {
        res.status(404).json({
            status: false,
            message: "Okul bulunamadı"
        });
        return;
    }
    res.status(200).json({
        status: true,
        data: schools
    });
});

const getSchool = asyncHandler(async (req: Request, res: Response) => {
    const schoolId = req.params.schoolId;
    if (!schoolId) {
        res.status(400).json({
            status: false,
            message: "Okul ID gereklidir"
        });
        return;
    }
    // school
    const school = await School.findOne({ id: schoolId });
    if (!school) {
        res.status(404).json({
            status: false,
            message: "Okul bulunamadı"
        });
        return;
    }
    res.status(200).json({
        status: true,
        data: school
    });
});

export { createSchool, getSchools, getSchool };