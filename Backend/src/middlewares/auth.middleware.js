import jwt from "jsonwebtoken"
import { ApiError } from "../utils/ApiError.js";
import { User } from "../models/user.models.js";

export const validateJWT = async (req, res, next) => {
    try {
        const accessToken = req.cookies?.accessToken || req.header("Authorization")?.replace("Bearer ", "");
                
        if(!accessToken){
            throw new ApiError(401, "No access token found")
        }
        
        const decodedToken = await jwt.verify(accessToken, process.env.ACCESS_TOKEN_SECRET)
    
        const userId = decodedToken?._id;
    
        const user = await User.findById(userId).select("-password -refreshToken");
    
        if(!user){
            throw new ApiError(401, "Invalid Access Token")
        }
    
        req.user = user
    
        next()      
    } catch (error) {
        throw new ApiError(401, error?.message|| "Unauthorized Request")
    }
    
}