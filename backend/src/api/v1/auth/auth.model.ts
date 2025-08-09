import { Schema, model } from "mongoose";

const UserSchema = new Schema({
    id: {
        type: String,
        required: true,
        unique: true,
    },
    name: {
        type: String,
        required: true,
    },
    surname: {
        type: String,
        required: true,
    },
    email: {
        type: String,
        required: true,
    },
    phone: {
        type: String,
        required: true,
    },
    password: {
        type: String,
        required: true,
    },
    schoolId: {
        type: Number,
        required: true,
    },
    role: {
        type: String,
        enum: ["Müdür", "Müdür Yardımcısı", "Öğretmen"],
        default: "Öğretmen",
    },
    createdAt: {
        type: Date,
        default: Date.now,
    },
});

const User = model("User", UserSchema);

export default User;