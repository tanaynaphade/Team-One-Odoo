import {Router} from "express";
import { validateJWT } from "../middlewares/auth.middleware.js";
import { createProject } from "../controllers/project.controller.js";

const router = Router();

router.route("/createproject").post(validateJWT, createProject)

export default router