const mongoose = require("mongoose")
const {User, Address, Device} =require ("../../models/user")
const router = require("express").Router();
const {verifyToken} =require("../../controllers/verifyToken")
const CryptoJS = require("crypto-js")
const {search}=require("../../middleware/search")
const G = require("../../enums/grant")

router.put("/:type", verifyToken([G.Grants.user]),   async (req, res, next)=>{
    var addToSet={}
    if(req.params.type=="product")
        addToSet={"favourites.products":req.body.id}
        else if(req.params.type=="category")
        addToSet={"favourites.categories":req.body.id}
    try{
        var favourite = await User.findByIdAndUpdate(req.user.id,{
            $addToSet:addToSet
        })
        if(favourite)return res.status(200).json(favourite)
        return res.status(400).json(favourite)
    }
    catch(e){
        next(e)
    }
})

router.delete("/:type", verifyToken([G.Grants.user]),  async (req, res, next)=>{
    var pull={}
    if(req.params.type=="product")
        pull={"favourites.products":req.body.id}
        else if(req.params.type=="category")
        pull={"favourites.categories":req.body.id}
    try{
        var favourite = await User.findByIdAndUpdate(req.user.id,{
            $pull: pull
        })
        if(favourite) return res.status(200).json(favourite)
        return res.status(400).json(favourite)
    }
    catch(e){
        next(e)
    }

})
module.exports = router