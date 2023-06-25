const router = require("express").Router()
const {ProductSuggestion} = require("../../models/productSuggestion")
const fs = require("fs");
const {verifyToken} = require("../../controllers/verifyToken")
const G = require("../../enums/grant")
const AS = require("../../sockets/adminSocket")

router.post("/", verifyToken([G.Grants.user]),  verifyToken(),async (req, res, next) => {
    try{
        req.body.user=req.user.id
        req.body.isShop = req.user.isShop
        var suggestion = ProductSuggestion(req.body)
        await suggestion.save()
        AS.createSuggestionById(suggestion._id)
        return res.status(201).json(suggestion)
    }
    catch(e){
        next(e)
    }
})

module.exports = router