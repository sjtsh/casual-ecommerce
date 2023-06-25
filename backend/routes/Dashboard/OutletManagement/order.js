const router = require("express").Router()
const { default: mongoose } = require("mongoose")
const { User } = require("../../../models/user")
const { SubCategory } = require("../../../models/category")
const WL = require("../../../middleware/withLength")
const { Shop } = require("../../../models/shop")
const { Staff } = require("../../../models/admin")
const { Grants } = require("../../../enums/grant")
const {verifyToken, comprehendRole, authorityWithParam} = require("../../../controllers/verifyToken")
const DR = require("../../../enums/dashboardRole")
const SG = require("../../../middleware/ShopGrants")
const { Product } = require("../../../models/product")
const { Order, RequestedShop } = require("../../../models/order")
const DH = require("../../../middleware/dashboard_helper")

// const reqSerialization2 = [...reqSerialization1]
// //  "feedback.deliveredBy.id", "feedback.deliveredBy.user", "feedback.deliveredBy.lastActive", "feedback.deliveredBy.deactivated", "feedback.deliveredBy.shop", "feedback.deliveredBy.available", "feedback.deliveredBy.avgRating", "feedback.deliveredBy.raterCount", "feedback.deliveredBy.ratingStar",
// const reqSerialization3 = [...reqSerialization1, "feedback.deliveredBy.name", "feedback.deliveredBy._id", "feedback.deliveredBy.phone" ]

//  sku fullfilled, bill
router.get("/shop/:id", verifyToken(Grants.dashboardAdmin), comprehendRole(DR.OutletsRoles.read), authorityWithParam("id"), async(req,res,next)=>{
    try{
        var shop = mongoose.Types.ObjectId(req.params.id)
        var results = await WL.handleQueriesWithCount(Order, req, [ 
            {$lookup: {as: "request", from: "requestedshops", localField: "_id", foreignField: "order", pipeline:[
                {$match: {shop: shop, feedback: {$ne: null}}}, 
                ...DH.generalReqQuery()
            ]}},  
            {$lookup: {as: "requestDummy", from: "requestedshops", localField: "_id", foreignField: "order", pipeline:[
                {$match: {shop: shop}},  
                ...DH.generalReqQuery()
            ]}},
            {$project:{"_id": 1, "id": 1, "createdAt": 1, "user": 1, "request": {$cond: [{$ne: ["$request", []]}, {$first: "$request"}, {$first: "$requestDummy"},]}, "total": 1, "status": 1, "deactivated": 1, "itemsAll": 1}},  
            {$sort: {createdAt: -1}},
            {$lookup: {as: "user", from: "users", localField: "user", foreignField: "_id", pipeline: [{$project: {name: 1,  phone: 1}}]}},
            {$unwind: "$user"},    
            {$project:{"_id": 1, "id": 1, "createdAt": 1, "user": 1, "request": 1, "total": 1, "status": 1, "deactivated": 1, count: { $size: "$itemsAll" }}},   
        ], 
        {pre: [
            {$match: {shop: shop}},
        ]})
        return res.status(200).json(results)
    }
    catch(e) {next(e)}
})

//
//items -> id, name, order qty, delivery qty, rate, confirmed rate, amount, delivered amt, image, margin
//product total delivery charge grand total, margin

//DONE -> id, status, createdAt, username, phone, address, outlet name, area, phone location, packed by mobile, order accepted AT, delivery assigned, delivered by, name phone, mobile started at, confirmed at, delivery feedf


//order detail of single order
router.get("/:id", verifyToken(Grants.dashboardAdmin), comprehendRole(DR.OutletsRoles.read), async(req,res,next)=>{
// router.get("/:id", async(req,res,next)=>{
    try{
        var request = (await RequestedShop.aggregate([{$match: {_id: mongoose.Types.ObjectId(req.params.id)}}]))[0]
        if(!request){
            var requests = await RequestedShop.aggregate([{$match: {order: mongoose.Types.ObjectId(req.params.id), deactivated: {$ne: true}}},])
            req.params.id = requests[0]._id.toString()
        }
        request = await RequestedShop.aggregate([
            {$match: {_id: mongoose.Types.ObjectId(req.params.id)}}, 
            ...SG.filterQueryGet(req, "shop"),
            ...DH.generalReqQueryDetail(),
            {$lookup: {as: "order", from: "orders", localField: "order", foreignField: "_id", pipeline: orderSerialization}},
            {$unwind: "$order"},
            {$project: {_id: 1, order: 1, shop: 1, itemsAble: 1, status: 1, packedBy: {$cond: [{$ne: ["$feedback", {}]}, "$packedBy", null]},feedback :1 }},
        ])
        if(!request.length) return res.status(401).json({ "message": "The required role has not been granted" })
        return res.status(200).json(request[0])
    }
    catch(e) {next(e)}
})

const orderSerialization = [
    {$lookup: {as: "user", from: "users", localField: "user", foreignField: "_id", pipeline: [{$project: {name: 1, phone: 1 }}]}},
    {$unwind: "$user"},    
    {$project: {id: 1, user: 1, location: 1, status: 1, address: 1,itemsAll: 1, remarks: 1, }},
    {$unwind: "$itemsAll"},
    {$lookup: {as: "itemsAll.product", from: "products", localField: "itemsAll.product", foreignField: "_id", pipeline:[{$project: {id: 1, name: 1, image: 1, margin:1}}]}},
    {$unwind: "$itemsAll.product"},
    {$group: {
        _id: "$_id",
        id: {$last: "$id"},
        user: {$last: "$user"},
        location: {$last: "$location"},
        status: {$last: "$status"},
        address: {$last: "$address"},
        remarks: {$last: "$remarks"},
        createdAt: {$last: "$createdAt"},
        itemsAll: {$push: "$itemsAll"},
    }},]
module.exports = router