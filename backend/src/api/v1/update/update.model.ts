import { Schema, model } from "mongoose";

const UpdateSchema = new Schema({
    version: {
        type: String,
        required: true,
    },
    url: {
        type: String,
        required: true,
    },
    createdAt: {
        type: Date,
        default: Date.now,
    }
});

const Update = model("Update", UpdateSchema);

export default Update;