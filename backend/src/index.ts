import express from 'express';
import dotenv from 'dotenv';
import mongoose from 'mongoose';
import logger from 'morgan';

dotenv.config();

const port = process.env.PORT || 3000;
const app = express();

app.set("trust proxy", 1);
app.use(express.json());
app.use(logger("tiny"));

import authRoutes from "./api/v1/auth/auth.route";
import tokenRoutes from "./api/v1/auth/token/token.route";
import boardRoutes from "./api/v1/board/board.route";
import schoolRoutes from "./api/v1/school/school.route";
import updateRoutes from "./api/v1/update/update.route";

app.use("/api/v1/auth", authRoutes);
app.use("/api/v1/auth/token", tokenRoutes);
app.use("/api/v1/board", boardRoutes);
app.use("/api/v1/school", schoolRoutes);
app.use("/api/v1/update", updateRoutes);

mongoose
  .connect(process.env.MONGO_URI!)
  .then(() => {
    app.listen(port, () => {
      console.log(`Server running on port ${port}`);
    });
  })
  .catch((err) => {
    console.log("could not connect to mongo!");
    console.log(err.message);
  });