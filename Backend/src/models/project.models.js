import mongoose, { mongo } from "mongoose";

const projectSchema = new mongoose.Schema(
{
    name: {
        type: String,
        required: true
    },
    description: {
        type: String
    },
    members: [{
        type: mongoose.Schema.Types.ObjectId,
        ref: "User",
        required: true
    }],
    owner: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "user",
        required: true
    },
    deadline: {
        type: Date,
        required: true
    },
    priority: {
        type: String,
        enum: ['low', 'medium', 'high'],
        default: 'low',
        required: true
    },
    status: {
        type: String,
        enum: ['active', 'inactive', 'closed'],
        required: true
    }
},
{
    timestamps:true
})

export const Project = mongoose.model('Project', projectSchema)