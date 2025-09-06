import { asyncHandler } from "../utils/asyncHandler.js";
import { ApiError } from "../utils/ApiError.js";
import {User} from "../models/user.models.js"


const registerUser = asyncHandler(async (req, res) =>{
    console.log(req.body);
    const {firstname, lastname, email, password} = req.body
    
    if(
        [firstname, lastname, email, password].some(field => !field || field.toString().trim() === "")
    ){
        throw new ApiError(400, "All fields are required")
    }

    const existingUser = await User.findOne({email:email});

    if(existingUser){
        throw new ApiError(409, "User with username or email already exists")
    }
    const user = await User.create({
        firstName: firstname.toLowerCase(),
        lastName: lastname.toLowerCase(),
        email: email.toLowerCase(),
        password
    })

    const createdUser = await User.findById(user._id).select(
        "-password -refreshToken"
    )

    if(!createdUser){
        throw new ApiError(500, "Error while creating the user")
    }

    return res.status(201)
    .json({
        message: "User created successfully",
        data: createdUser
    })
})

export {registerUser}