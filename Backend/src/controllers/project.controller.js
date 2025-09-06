import { ApiError } from "../utils/ApiError.js";
import { asyncHandler } from "../utils/asyncHandler.js";
import { User } from "../models/user.models.js";
import { Project } from "../models/project.models.js";

const createProject = asyncHandler(async (req, res) => {

    const {name, description, deadline, priority, status} = req.body
    console.log(name);
    
    const tempUser = await User.findById(req.user._id)
    console.log(tempUser);
    
    if(tempUser?.role != 'manager'){
        throw new ApiError(401, "Only manager can create projects")
    }

    const project = await Project.create({
        name,
        description,
        deadline,
        priority,
        status,
        owner: tempUser._id,
        members: tempUser._id
    })

    const createdProject = await Project.findById(project._id)

    if(!createProject){
        throw new ApiError(500, "Failed to create project")
    }

    return res.status(201)
    .json({
        message: "Project created successfully",
        data: createdProject
    })

})

export {createProject}