import mongoose from "mongoose";

const connectToDB = async () => {
    try {
        console.log(process.env.MONGODB_URL);
        
        const connectionInstance = await mongoose.connect(`${process.env.MONGODB_URL}/${process.env.DB_NAME}`)
        console.log(`Connected to host: ${connectionInstance.connection.host}`);
    } catch (error) {
        console.log(`MONGO CONNECTION ERROR: ${error}`);
        process.exit(1)
    }
}

export default connectToDB;