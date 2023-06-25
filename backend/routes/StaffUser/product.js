const router = require("express").Router()
const { Product } = require("../../models/product")
const fs = require("fs");
const {verifyToken} = require("../../controllers/verifyToken");
const { Order,RequestedShop } = require("../../models/order");
const { default: mongoose } = require("mongoose");
const {trending, getNearestShop}=require("../../middleware/nearbyShop")
const {search}=require("../../middleware/search")
const G = require("../../enums/grant")
// router.get("/search",verifyToken([G.Grants.user, G.Grants.staff]), async (req, res, next) => {

router.get("/search",async (req, res, next) => {
    try {
        if (req.query.s) {
            var shop = await getNearestShop(req)
            if(!shop) return res.status(200).json([])
            var products= await search(Product, req.query.s,[{$match: {shop: shop._id, verificationAdmin: 2, deactivated: {$ne: true}}},])
            return res.status(200).json(products)
        }
        else
            return res.status(400).json({ "message": "Invalid search query" })
    }
    catch (e) {
        console.log(e)
        next(e)
    }

})

module.exports = router