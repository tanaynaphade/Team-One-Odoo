import dotenv from "dotenv"
dotenv.config()
import connectToDB from "./db/db.js"
import {app} from "./app.js"


connectToDB()
.then(()=>{
    app.listen(process.env.PORT || 8000, () =>{
        console.log(`Server is running on port ${process.env.PORT}`);
        
    })
})
