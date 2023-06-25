const { Category } = require("../../models/category")
const router = require("express").Router();
const {verifyToken} = require("../../controllers/verifyToken")
const { Shop } = require("../../models/shop");
const { Product } = require("../../models/product");
const {getSubCategory, trending, getNearestShop}=require("../../middleware/nearbyShop")
const G = require("../../enums/grant");
const { Banner } = require("../../models/banner");

const BR = require("../../enums/banner");
const { default: mongoose } = require("mongoose");

//TODO: router.get("/", verifyToken([G.Grants.user]), async(req,res,next)=>{
router.get("/", async (req, res, next) => {
    try{
        var shop = await getNearestShop(req)
        if(!shop) return res.status(200).json([])
        var categories = await Product.aggregate([
            {$match: {shop: shop._id, verificationAdmin: 2, deactivated: {$ne: true}}},
            {$group: {_id: "$category"}},
            {$lookup: {as: "_id", from:"subcategories", localField:"_id", foreignField:"_id", pipeline: [
                {$match: {deactivated: {$ne: true}}},
                {$lookup: {as: "banners", from:"banners", localField:"_id", foreignField:"foreign", pipeline: [
                    {$match: {deactivated: {$ne: true}}},
                    { $project: {__v: 0, deactivated: 0, createdAt: 0, updatedAt: 0}}
                ]}},
                {$project: {id: 1, category: 1, name: 1, image: 1, banners: 1}}
            ]}},
            {$unwind:"$_id"},
            {$project: {_id: "$_id._id", category: "$_id.category", name: "$_id.name", image: "$_id.image", banners: "$_id.banners"}},
            {$group: {_id: "$category", subcategories: {$push: {_id: "$_id", name: "$name", image: "$image", banners: "$banners"}}}},
            {$lookup: {as: "category", from: "categories", localField: "_id", foreignField: "_id", pipeline: [
                {$match: {deactivated: {$ne: true}}},
            ]}},
            {$unwind: "$category"},
            {$project: {name: "$category.name", id: "$category.id", image: "$category.image", subcategories: 1 }},
        ])
        return  res.status(200).json(categories)
   }
    catch(e)
    {
        console.log(e)
        next(e)
    }

})

module.exports = router