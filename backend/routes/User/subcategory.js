
const { Category, SubCategory } = require("../../models/category")
const router = require("express").Router();
const {verifyToken} = require("../../controllers/verifyToken")
const {getSubCategory, getNearestShop}=require("../../middleware/nearbyShop")
const G = require("../../enums/grant");
const { Product } = require("../../models/product");
const { Shop } = require("../../models/shop");
const { default: mongoose } = require("mongoose");

router.get("/", verifyToken([G.Grants.user]),  async (req, res, next) => {
    try {
        var shop = await getNearestShop(req)
        if(!shop) return res.status(200).json([])
        var products = await SubCategory.aggregate([
            {$match: {deactivated:{$ne: true}}},
            {$lookup:{as: "products", from: "products", localField: "_id", foreignField:"category", pipeline:[
                {$match: {shop: shop._id, verificationAdmin: 2, deactivated: {$ne: true}, category: mongoose.Types.ObjectId(req.params.categoryId)}},
                {$project: {name: 1, price: 1, image: 1, unit: 1, sku: 1, return: 1, limit: 1, master: 1}},
                {$group: {_id: "_id"}}
            ]}},
            {$unwind: "$products"},
            {$project: {products: 0}}
        ])
        return res.status(200).json(products)
    }
    catch (e) {
        next(e)
    }
})

module.exports = router