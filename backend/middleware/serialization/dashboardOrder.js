
const DH = require("../../middleware/dashboard_helper")
const WL = require("../../middleware/withLength")


const serializationFunc = () => {
    var projector = WL.serializerProject(["_id", "id", "createdAt", "user", "request", "total", "status", "deactivated",])
    projector.set("count",  { $size: "$itemsAll" })
    return [
        {$lookup: {as: "request", from: "requestedshops", localField: "_id", foreignField: "order", pipeline:[
            {$match: {feedback: {$ne: null}}},
            ...DH.generalReqQuery()
        ]}},
        {$lookup: {as: "user", from: "users", localField: "user", foreignField: "_id", pipeline: [{$project: {name: 1}}]}},
        {$unwind: "$user"}, 
        {$project: projector},   
    ]
}

exports.serialization = serializationFunc()