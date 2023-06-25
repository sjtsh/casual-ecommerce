const router = require("express").Router()
const { default: mongoose } = require("mongoose");

const { Order, SingularOrderFeedback, RequestedShop } = require("../../models/order");
const { User } = require("../../models/user");
const { Shop } = require("../../models/shop");
const { notify } = require("../../urls");
const { sendNotification } = require("../../controllers/pushNotification");
const e = require("express");
const { env } = require("process");
const { Grants } = require("../../enums/grant");
const { Staff } = require("../../models/admin");
const { Console } = require("console");


exports.pipeline = (shop, staff)=>{ 
    return [{
        $match: {
            status: 2,
            shop: mongoose.Types.ObjectId(shop.toString()),
            deactivated: {$ne: true}, 
            feedback: {$ne: null},
            "feedback.deliveredBy": null,
            "feedback.deliveryRejections":  {$ne: mongoose.Types.ObjectId(staff.toString())},
        }
    }]
}

exports.getPersonalRequestedShop = async(requestedShop, reqBy) => {
    var r = await serializeRequestedShop(requestedShop)
    if(reqBy && r && r.feedback){
        if(r.feedback.deliveryRejections) r.feedback.deliveryRejections =  r.feedback.deliveryRejections.includes(reqBy)
        else r.feedback.deliveryRejections = false

        if(r.feedback.deliveryMisses) r.feedback.deliveryMisses =  r.feedback.deliveryMisses.includes(reqBy)
        else r.feedback.deliveryMisses = false
    }
    return r
}

exports.standardOrRequestQuery = (id)=>{ 
    return [
        {staff: mongoose.Types.ObjectId(id.toString())}, 
        { "feedback.deliveredBy": mongoose.Types.ObjectId(id.toString())}, 
        { "feedback.deliveryRejections": mongoose.Types.ObjectId(id.toString())}, 
        { "feedback.deliveryMisses": mongoose.Types.ObjectId(id.toString())}
    ]
}

exports.getPersonalOrder = async(orderID, id) => {
    return (await orderWithRequestLookup(orderID, [{ $match: {deactivated: {$ne: true}, $or: this.standardOrRequestQuery(id)}}], id))
}

exports.getPersonalOrderForDeliveryNew = async(orderID, pipeline) => {
    return (await orderWithRequestLookup(orderID, pipeline))
}


exports.getOrderByShop = async(orderID, shopID) => {
    try{
        var pipelineParams =  [ { $match: { shop: mongoose.Types.ObjectId(shopID.toString()) } }]
        return (await orderWithRequestLookup(orderID, pipelineParams))
    }catch(e){ console.log(e) }
}

const shopWithNoFeedback = async (id)=>{
    var req = await RequestedShop.aggregate(
        [
            { $match: { _id: id} },
            ...populateProduct("itemsAble"),
            {$group: generateGroup(["feedback", "order", "shop", "status", "distance", "selectAt"], ["itemsAble"])},
        ])
    return req[0]
}

const serializeRequestedShop = async (requestedShop) =>{
    try{
        if (!requestedShop.feedback) return (await shopWithNoFeedback(requestedShop._id))

        var requestKeyList = ["order", "shop", "status", "distance", "itemsAble", "selectAt"]
        var feedbackKeyList = ["deliveryTime", "deliveryCharge", "rating", "deliveredBy", "deliveryRejections", "deliveryMisses"]

        var allocatedKeyList = ["itemsAllocated", ...feedbackKeyList]
        var itemsKeyList = ["items", ...feedbackKeyList]

        //-----------------------------------------------------------
        var groupingItems = generateGroup(requestKeyList)
        groupingItems["items"] = { $addToSet: "$feedback.items" }
        groupingItems["feedback"] =  { $last:  projectFromFeedback(allocatedKeyList) }

        //-----------------------------------------------------------
        var projectingItems = generateProject(requestKeyList)
        var feedbackProject = projectFromFeedback(allocatedKeyList)
        feedbackProject["items"] = "$items"
        projectingItems["feedback"] = feedbackProject

        //-----------------------------------------------------------
        var allQueries =[
            { $match: { _id: requestedShop._id } },
            ...populateProduct("feedback.items"),
            {$group: groupingItems},
        ]
        
        if(requestedShop.feedback.deliveredBy){
            allQueries = [
                ...allQueries,
                {$lookup: {as: "feedback.deliveredBy", from: "staffs", localField: "feedback.deliveredBy", foreignField:"_id", pipeline:[
                    {$lookup: {as: "user", from: "users", localField: "user", foreignField:"_id", pipeline:[{$project: {id: 1, name: 1, phone: 1}}]}},
                    {$unwind: "$user"}, {$project: {name: "$user.name", phone: "$user.phone"}}
                ]}},
                {$unwind: "$feedback.deliveredBy"}
            ]
        }
        
        //-----------------------------------------------------------
        if (requestedShop.feedback.itemsAllocated.length == 0) {
            allQueries = [
                ...allQueries,
                ...populateProduct("itemsAble"),
                {$group: groupWithItemsAbleToSet()},
                {$project: projectingItems }
            ]
        } else {
            //-----------------------------------------------------------
            var groupingAllocated = generateGroup(["order", "distance", "shop", "status", "itemsAble", "selectAt"], [])
            groupingAllocated["itemsAllocated"] =  { $addToSet: "$feedback.itemsAllocated" }
            groupingAllocated["feedback"] = { $last: projectFromFeedback(itemsKeyList) }
            
            //-----------------------------------------------------------
            var projectingAllocated = generateProject(requestKeyList)
            var feedbackProject2 = projectFromFeedback(itemsKeyList)
            feedbackProject2["itemsAllocated"] = "$itemsAllocated"
            projectingAllocated["feedback"] = feedbackProject2 

            //-----------------------------------------------------------

            allQueries = [
                ...allQueries,
                { $project: projectingItems },
                ...populateProduct("feedback.itemsAllocated"),
                { $group: groupingAllocated },
                ...populateProduct("itemsAble"),
                {$group: groupWithItemsAbleToSet()},
                {$project: projectingAllocated },
            ]
        }
        var orders = await RequestedShop.aggregate(allQueries)
        if (orders.length) return orders[0]
    }catch(e){ console.log(e) }
}

const orderWithRequestLookup = async (orderID, pipeline, reqBy)=>{
    var orders = await Order.aggregate(
        [
            ...getOrderSerialization(orderID),
            {$lookup: { foreignField: "order", localField: "_id", as: "requestedShop", from: "requestedshops", pipeline: pipeline}, },
        ]
    )
    if (orders.length) {
        if (orders[0].requestedShop.length) {
            var r = await this.getPersonalRequestedShop(orders[0].requestedShop[0])
            orders[0].requestedShop = r
            return orders[0]
        }
    }
}

const getOrderSerialization = (orderID)=>{
    var grouping = generateGroup(["location", "address", "status", "id", "total", "createdAt", "updatedAt", "selectedFeedback", "verificationOTP", "waitTime", "remarks", "shop", "values"])
    grouping["items"] = { $addToSet: '$itemsAll' }
    return [
        { $match: { _id: mongoose.Types.ObjectId(orderID.toString()) } },
        {$lookup: {from: "shops", as: "shop", localField: "shop", foreignField: "_id", pipeline:[{$project: {id: 1, name: 1, phone: 1, address: 1, img: 1, location: 1}}]}},
        {$unwind: "$shop"},
        ...populateProduct("itemsAll"),
        { $group: grouping},
    ]
}

const groupWithItemsAbleToSet = ()=>{
    return generateGroup(["feedback", "itemsAllocated", "items", "order", "shop", "status", "distance", "selectAt"], ["itemsAble"])
}

const populateProduct = (key)=>{
    return [
        { $unwind: "$" + key },
        {
            $lookup: {
                foreignField: "_id",
                localField: key + ".product",
                as: key + ".product",
                from: "products",
                pipeline: [{ $project: { name: 1, _id: 1, price: 1, category: 1, sku: 1, image: 1, unit: 1,return: 1, barcode: 1} }]
            },
        },
        { $unwind: "$" + key + ".product" },
    ]
}
const generateGroup = (last_keys, set_keys) => {
    var groupMap = { _id: '$_id'}
    for(var i in last_keys){
        groupMap[last_keys[i]] = {"$last": "$" + last_keys[i]}
    }
    for(var i in set_keys){
        groupMap[set_keys[i]] = {"$addToSet": "$" + set_keys[i]}
    }
    return groupMap
}

const generateProject = (keys) => {
    var projectMap = {_id: '$_id'}
    for(var i in keys){
        projectMap[keys[i]] = "$" + keys[i]
    }
    return projectMap
}

const projectFromFeedback = (keys) => {
    var feedbackMap = {}
    for(var i in keys){
        feedbackMap[keys[i]] = "$feedback." + keys[i]
    }
    return feedbackMap
}
