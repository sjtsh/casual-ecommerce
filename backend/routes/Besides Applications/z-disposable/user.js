const mongoose = require("mongoose")
const {User, Address, Device} =require ("../../models/user")
const router = require("express").Router();
const {verifyToken} =require("../../controllers/verifyToken")
const CryptoJS = require("crypto-js")
const {search}=require("../../middleware/search")


router.get("/", async (req, res, next)=>{
    try{
    var user = await User.find()
    return res.status(200).json(user)
}
catch(e){next(e)}
})

 
router.post("/notify/:id", verifyToken(), async (req, res, next) => {
    try{
        var user = await User.findOne(req.user.id)
        for(var i in user.devices){
            if(user.devices[i].deviceId == req.params.id){
                user.devices[i].notify = !user.devices[i].notify
            }
        }
        await user.save()
        return res.status(200).json( req.user.devices[i].notify.toString())
    }
    catch(e){
        next(e)
    }
 })

module.exports = router