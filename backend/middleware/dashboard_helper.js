
const { default: mongoose } = require("mongoose")

const reqSerialization = [ "staff", "shop", "feedback.items", "status"]
const reqSerializationDetail = [...reqSerialization, "feedback.billNumber", "feedback.bill", "feedback.referenceImages", "order", "selectAt", "itemsAble", "feedback.items", "feedback.startDeliveryTime", "feedback.otpDeliveryTime", "feedback.deliveryCharge", "feedback.createdAt", "feedback.deliveryAcceptedAt"]

exports.generalReqQuery = () =>{ 
    return [
        ...commonQuery(requestSerialization),
        {$lookup: {as: "shop", from: "shops", localField: "shop", foreignField: "_id", pipeline: [{$project: {name: 1, address: 1,  phone: 1}}]}},
        {$unwind: "$shop"}, 
        {$project: {deliveredBy: "$feedback.deliveredBy", packedBy: 1, shop: 1, status:1, count: {$cond: [{$ne: ["$status",4]}, 0, {$size: { $ifNull: [ "$feedback.items", [] ,] }} ]}}}// count: {$size: "$items"}
    ]
}
exports.generalReqQueryDetail = () =>{ 
    return [
        ...commonQuery(requestSerializationDetail),
        {$lookup: {as: "shop", from: "shops", localField: "shop", foreignField: "_id", pipeline: [{$project: {name: 1, location: 1, phone: 1, address: 1}}]}},
        {$unwind: "$shop"}, 
        {$project: {deliveredBy: "$feedback.deliveredBy", packedBy: 1, shop: 1, status:1, order: 1, selectAt: 1, itemsAble: 1, feedback: {referenceImages: 1, bill: 1, billNumber: 1, startDeliveryTime: 1, otpDeliveryTime: 1, deliveryCharge: 1, createdAt: 1, deliveryAcceptedAt: 1,items: 1}}},
    ]
}

const commonQuery = (serializer) =>{
    return [
        {$lookup: {as: "feedback.deliveredBy", from:"staffs", foreignField: "_id", localField:"feedback.deliveredBy"}}, 
        {$lookup: {as: "packedBy", from: "staffs", localField: "staff", foreignField: "_id"}},   
        {$project: serializer},
        {$lookup: {as: "feedback.deliveredBy", from:"users", foreignField: "_id", localField:"feedback.deliveredBy.user", pipeline: [{$project: {name: 1, _id: 1,  phone: 1}}]}},  
        {$lookup: {as: "packedBy", from:"users", foreignField: "_id", localField:"packedBy.user", pipeline: [{$project: {name: 1, _id: 1, phone: 1}}]}}, 
        {$project: serializer}, 
    ]
}

const reqProject = (reqSerialization)=>{
    var projectQ = {}
    for(var i in reqSerialization){
        projectQ[reqSerialization[i]] = 1
    }
    projectQ["feedback.deliveredBy"] = {$cond: [{$and: [{$ne: [null,"$feedback"]}, {$ne: [[], "$feedback.deliveredBy"]}]}, {$first: "$feedback.deliveredBy"}, null]}
    projectQ["packedBy"] = {$cond: [{$and: [{$ne: ["$feedback", null]}, {$ne: [[], "$packedBy"]}]}, {$first: "$packedBy"}, null]}
    return projectQ
}

const requestSerializationDetail = reqProject(reqSerializationDetail)
const requestSerialization = reqProject(reqSerialization)
