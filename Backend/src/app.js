import express from "express"
import cookieParser from "cookie-parser"
import cors from "cors"
const app = express();

app.use(cors())
app.use(express.json({limit:"16kb"}))
app.use(express.urlencoded({extended:true, limit:"16kb"}))
app.use(cookieParser())

import userRoute from "./routes/user.routes.js"
import projectRoute from "./routes/project.routes.js"

app.use("/api/v1/users", userRoute)
app.use("/api/v1/project", projectRoute)

export {app}