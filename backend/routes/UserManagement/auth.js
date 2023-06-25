const router = require("express").Router();
const CryptoJS = require("crypto-js");
const jwt = require("jsonwebtoken");
const fs = require("fs");
const { User, Address, Device } = require("../../models/user")
const { Shop } = require("../../models/shop")
const admin = require("../../controllers/firebaseAdmin");
const {verifyToken} =require("../../controllers/verifyToken");
const { Mongoose, default: mongoose } = require("mongoose");
const { Category } = require("../../models/category");


router.get("/refresh", verifyToken(), async(req, res, next)=>{
    try{
        const accessToken = jwt.sign({id: req.user.id, grant: req.user.grant},process.env.JWT_SEC, {expiresIn: "24h"});
        return res.status(200).json({"x-access-token": accessToken})
    }catch(E){
        next(E)
    }
})


router.get("/deletesanim", async(req,res,next)=>{
    try{
        var user = await User.findOne({phone: "9808405273"})
        if(!user) return res.status(200).json({"message":"User not found"})
        await User.findByIdAndDelete(user._id)
        return res.status(200).json({"message":"Success"})
    }catch(e){next(e)}
})

router.get("/user", async(req,res,next)=>{
    try{
        if(req.query.phone && req.query.code){
            var user = await User.findOne({phone:req.query.phone, countryCode:req.query.code})
            if(user) return res.status(200).json({"newUser":false})
            return res.status(200).json({"newUser":true})
        }
        return res.status(400).json({"message":"Phone not found"})
    }catch(e){next(e)}
})

router.get("/shop/forgot/:phone",async(req,res,next)=>{
    try{
        if(req.params.phone)
        {
            var user= await Shop.findOne({phone:req.params.phone})
            if(user)
            return res.status(200).json({"newUser":false})
            return res.status(200).json({"newUser":true})
        }
    }
    catch(e)
    {
        next(e)
    }
})

router.get("/shop",async(req,res,next)=>{
    try{
            var shop= await Shop.findOne({phone:req.query.phone})
            if(shop){
                return res.status(421).json({ "message": "Phone already in use" })
            }
            if(req.query.pan){
                shop = await Shop.findOne({ pan: req.query.pan })
                if (shop) {
                    return res.status(421).json({ "message": "Pan already in use" })
                }
            }
            return res.status(200).json({"newUser":true})
        
    }
    catch(e)
    {
        next(e)
    }
})

router.put("/password/:type",async(req,res,next)=>{
    try{
       
        const record = await admin.auth().getUser(req.body.uid)
        if(!record){
            return res.status(400).json({"message":"Invalid user"})
        }
        if(!record.phoneNumber.includes(req.body.phone)){
            return res.status(400).json({"message":"Invalid user"})
        }
        if(req.params.type=="user")
        {            
            const hashedPassword = CryptoJS.AES.encrypt(
                req.body.password,
                process.env.PASS_SEC
            ).toString();
            var user = await User.findOne({phone:req.body.phone})
            if(!user) return res.status(400).json("User not found")
            const decryptedPassword = CryptoJS.AES.decrypt(
                user.password.toString(),
                process.env.PASS_SEC
            );
            const OriginalPassword = decryptedPassword.toString(CryptoJS.enc.Utf8);
            if(OriginalPassword == req.body.password){
                return res.status(400).json("Password cannot be same as the old password")
            }
            user.password = hashedPassword;
            await user.save()
            if(user){
                return res.status(200).json("successful")
            }
           return res.status(400).json("User not found")
        }
        else if(req.params.type=="shop")
        {
            const hashedPassword = CryptoJS.AES.encrypt(
                req.body.password,
                process.env.PASS_SEC
            ).toString();
            var shop = await Shop.findOne({phone:req.body.phone})
            if(!shop) return res.status(400).json("Shop not found")
            const decryptedPassword = CryptoJS.AES.decrypt(
                shop.password.toString(),
                process.env.PASS_SEC
            );
            const OriginalPassword = decryptedPassword.toString(CryptoJS.enc.Utf8);
            if(OriginalPassword == req.body.password){
                return res.status(400).json("Password cannot be same as the old password")
            }
            shop.password = hashedPassword;
            await shop.save()
            if(shop){
                return res.status(200).json("successful")
            }
           return res.status(400).json("Shop not found")
        }
        else
        return res.status(400).json("type not defined")
    }
    catch(e)
    {
        
        next(e)
    }
})

module.exports = router