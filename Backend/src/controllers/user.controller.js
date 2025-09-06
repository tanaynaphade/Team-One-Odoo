import { asyncHandler } from "../utils/asyncHandler.js";
import { ApiError } from "../utils/ApiError.js";
import {User} from "../models/user.models.js"

const generateAccessAndRefreshToken = async (userId) => {
    try {
        const user = await User.findById(userId)

        if(!user){
            throw new ApiError(400, "User not found")
        }

        const accessToken = await user.generateAccessToken()
        const refreshToken = await user.generateRefreshToken();

        user.refreshToken = refreshToken
        
        user.save({validateBeforeSave: false})

        return {accessToken, refreshToken}

    } catch (error) {
        console.log(error);
        
    }
}

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

const loginUser = asyncHandler(async (req, res) => {
    const {email, password} = req.body

    if(!email && !password){
        throw new ApiError(400, "All fields are required")
    }

    const user = await User.findOne({email});

    if(!user){
        throw new ApiError(400, "No user found")
    }

    const isPassValid = await user.isPasswordCorrect(password)

    if(!isPassValid){
        throw new ApiError(401, "Incorrect Password")
    }

    const loggedinuser = await User.findById(user._id).select("-password -refreshToken")

    const {accessToken, refreshToken} = await generateAccessAndRefreshToken(user._id)

    const options = {
            httpOnly: true,
            secure: true
    }

    return res
        .status(200)
        .cookie("accessToken", accessToken, options)
        .cookie("refreshToken", refreshToken, options)
        .json({
            message: "User logged in",
            data: loggedinuser
    })
})
export {registerUser, loginUser}