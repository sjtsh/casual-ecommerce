const router = require("express").Router()
const {ProductSuggestion} = require("../../models/productSuggestion")
const fs = require("fs");
const {verifyToken} = require("../../controllers/verifyToken");




router.get("/product",async(req,res,next)=>{
    try{
        var products=await ProductSuggestion.find().populate([{path:"user",select:"name"}]);
        return res.status(200).json(products)
    }
    catch(e)
{    next(e)}
})


module.exports = router