import express from "express"
import cookieParser from "cookie-parser"

const app = express();

app.use(express.json({limit:"16kb"}))
app.use(express.urlencoded({extended:true, limit:"16kb"}))
app.use(cookieParser())

import userRoute from "./routes/user.routes.js"
app.use("/api/v1/users", userRoute)

export {app}