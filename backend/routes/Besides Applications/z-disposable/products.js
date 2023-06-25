const router = require("express").Router()
const { Product } = require("../../models/product")
const fs = require("fs");
const {verifyToken} = require("../../controllers/verifyToken");
const { Order,RequestedShop } = require("../../models/order");
const { default: mongoose } = require("mongoose");
const {trending}=require("../../middleware/productCat")
const {search}=require("../../middleware/search")

router.get("/temp/:categoryId", async (req, res, next) => {
    try {
        var product = await Product.aggregate([
            {
              $match: {category: mongoose.Types.ObjectId(req.params.categoryId)},
            },
            {
                $project:{
                    name:1,
                    _id:1
                }
            }
        ])
        return res.status(200).json(product)
    }
    catch (e) {
        next(e)
    }
})



router.get("/", async (req, res, next) => {
    try {
        var products = await Product.find();
        return res.status(200).json(products)
    }
    catch (e) { next(e) }
})

router.post("/", verifyToken(), async (req, res, next) => {
    try{
    var product = Product(req.body)
    await product.save()
    return res.status(200).json(product)
}
catch(e){next(e)}
})
module.exports = router