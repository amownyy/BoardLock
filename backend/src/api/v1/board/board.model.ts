import { Schema, model } from "mongoose";

const BoardSchema = new Schema({
    name: {
        type: String,
        required: true,
    },
    schoolId: {
        type: Number,
        required: true,
    },
    status: {
        type: String,
        enum: ["Aktif", "Kilitli", "Kapalı", "Yeniden Başlatılıyor"],
        default: "Kapalı",
    },
    createdAt: {
        type: Date,
        default: Date.now,
    },
});

const Board = model("Board", BoardSchema);

export default Board;