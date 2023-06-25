const router = require("express").Router()
const { Category } = require("../models/category")
const { Product } = require("../models/product")
const { SubCategory } = require("../models/category")
const { Mail } = require("../models/mail")

router.get("/", async (req, res, next) => {
    try{
        var mail = Mail(req.query)
        await mail.save()
        return res.status(200).json("success")
    }
    catch(e){
        next(e)
    }
})
module.exports = router