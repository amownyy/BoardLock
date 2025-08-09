import { Schema, model } from "mongoose";

const SchoolSchema = new Schema({
    id: {
        type: Number,
        required: true,
        unique: true,
    },
    name: {
        type: String,
        required: true,
    },
    status: {
        type: String,
        enum: ["Ödendi", "Ödenmedi"],
        default: "Ödenmedi",
    },
    createdAt: {
        type: Date,
        default: Date.now,
    }
});

const School = model("School", SchoolSchema);

export default School;