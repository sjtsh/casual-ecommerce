const router = require("express").Router()
const { Product } = require("../../models/product")
const fs = require("fs");
const {verifyToken} = require("../../controllers/verifyToken");
const { Order,RequestedShop } = require("../../models/order");
const { Shop } = require("../../models/shop");
const { default: mongoose } = require("mongoose");
const {trending, getNearestShop}=require("../../middleware/nearbyShop")
const {search}=require("../../middleware/search")
const G = require("../../enums/grant")

//TODO: router.get("/subcategory", verifyToken([G.Grants.user]), async(req,res,next)=>{
router.get("/subcategory", async (req, res, next) => {
    try {
        var skip = 0
        var limit = 10
        if(req.query.skip) skip = parseInt(req.query.skip)
        if(req.query.limit) limit = parseInt(req.query.limit)
        var shop = await getNearestShop(req)
        if(!shop) return res.status(200).json([])
        var subcategories = await Product.aggregate([
            {$match: {shop: shop._id, verificationAdmin: 2, deactivated: {$ne: true}}},
            {$group: {_id: "$category"}}, 
            {$sort: {_id: -1}},
            {$skip: skip},
            {$limit: limit},
            {$lookup: {as: "_id", from:"subcategories", localField:"_id", foreignField:"_id"}},
            {$unwind:"$_id"},
            {$project: {_id: "$_id._id", category: "$_id.category", name: "$_id.name", image: "$_id.image"}},
            {$lookup: {as: "products", from: "products", localField: "_id", foreignField: "category", pipeline: [
                {$match: {shop: shop._id, verificationAdmin: 2, deactivated: {$ne: true}}},
                {$project: {name: 1, price: 1, image: 1, unit: 1, sku: 1, return: 1, limit: 1,category:1, master: 1}}
            ]}},
        ])
        for(var i in subcategories){
            var length = subcategories[i].products.length
            const finalCount = 12
            if(length > finalCount){
                var set = new Set()
                var newPossibleList = []
                while(newPossibleList.length != finalCount ){
                    var possibleIndex = Math.floor(Math.random() * length)
                    if(!set.has(possibleIndex)){
                        set.add(possibleIndex)
                        newPossibleList.push(subcategories[i].products[possibleIndex])
                    }
                }
                subcategories[i].products = newPossibleList
            }
        }
        return res.status(200).json(subcategories)
    }
    catch (e) { next(e) }
})

// router.get("/trending", verifyToken([G.Grants.user]),   async (req, res, next) => {
router.get("/trending", async (req, res, next) => {
    try {
        var skip = 0
        var limit = 10
        if(req.query.skip) skip = parseFloat(req.query.skip)
        if(req.query.limit) limit = parseFloat(req.query.limit)
        var shop = await getNearestShop(req)
        if(!shop) return res.status(200).json([])
        var date = new Date()
        date.setDate(date.getDate() - 3)
        var products = await RequestedShop.aggregate([ 
            {$match: {deactivated: {$ne: true}, createdAt: {$gte: date}}},
            {$unwind: "$feedback.itemsAllocated" },
            {$group:{ _id:"$feedback.itemsAllocated.product", soloCount:{$sum: "$feedback.itemsAllocated.item_count"}}},
            {$lookup:{foreignField: "_id", localField: "_id", as: "_id", from: "products",}},
            {$unwind:"$_id"},
            {$group:{ _id:"$_id.master", count: {$sum: "$soloCount"}}},
            {$sort:{count: -1}},
            {$lookup:{foreignField: "master", localField: "_id", as: "product", from: "products", pipeline:[
                {$match: {shop: shop._id, verificationAdmin: 2, deactivated: {$ne: true}}},  
                {$project: {name: 1, price: 1, image: 1, unit: 1, sku: 1, limit: 1, category: 1, master: 1}}
            ]}},
            {$unwind: "$product"},
            {$skip: skip},
            {$limit: limit},
        ])
       return res.status(200).json(products)
    }
    catch (e) { next(e) }
})

router.get("/:categoryId", async (req, res, next) => {
    try {
        var shop = await getNearestShop(req)
        if(!shop) return res.status(200).json([])
        var skip = 0
        var limit = 10
        if(req.query.skip) skip = parseInt(req.query.skip)
        if(req.query.limit) limit = parseInt(req.query.limit)
        var products = await Product.aggregate([
            {$match: {shop: shop._id, verificationAdmin: 2, deactivated: {$ne: true}, category: mongoose.Types.ObjectId(req.params.categoryId)}},
            {$skip: skip},
            {$limit: limit},
            {$project: {name: 1, price: 1, image: 1, unit: 1, sku: 1, return: 1, limit: 1,category:1, master: 1}}
        ])
        return res.status(200).json(products)
    }
    catch (e) {
        next(e)
    }
})

module.exports = router