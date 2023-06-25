const mongoose = require("mongoose")
const {User, Address, Device} =require ("../../models/user")
const router = require("express").Router();
const {verifyToken} =require("../../controllers/verifyToken")
const CryptoJS = require("crypto-js")
const {search}=require("../../middleware/search")
const G = require("../../enums/grant")

router.post("/", verifyToken([G.Grants.user]),  async (req, res, next) => {
    try{
        var address = Address(req.body)
        var user = await User.findOne({_id: req.user.id})
        if(user){
            user.address.push(address)
            await user.save()
            return res.status(200).json(user.address)
        }else{
            return res.status(403).json({"message":"unauthorized creds"})
        }
    }
    catch(e){
     next(e)
    }
 })

 router.put("/:id", verifyToken([G.Grants.user]),  async (req, res, next)=>{
     try{
     var user = await User.findById(req.user.id)
     for(var i in user.address){
         if(req.params.id == user.address[i]._id.toString()){
             if(req.body.fullName){
                 user.address[i].fullName = req.body.fullName
             }
             if(req.body.phone){
                 user.address[i].phone = req.body.phone
             }
             if(req.body.address){
                 user.address[i].address = req.body.address
             }
             if(req.body.fullAddress){
                 user.address[i].fullAddress = req.body.fullAddress
             }
             if(req.body.label){
                 user.address[i].label = req.body.label
             }
             if(req.body.location){
                 user.address[i].location = req.body.location
             }
         }
     }
     await user.save()
     return res.status(200).json(req.body)
 }
 catch(e){next(e)}
})

router.delete("/:address", verifyToken([G.Grants.user]),   async (req, res, next) => {
    try{
     var user = await User.findOne({_id: req.user.id})
     for(var i in user.address){
        if(user.address[i]._id.toString() == req.params.address){
            user.address.splice(i, 1)
            break
        }
     }
     await user.save()
     return res.status(200).json(user.address)
    }
    catch(e)
    {
     next(e)
    }
 })
module.exports = router