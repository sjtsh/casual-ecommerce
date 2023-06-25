const mongoose = require("mongoose")
const {User, Address, Device} =require ("../../models/user")
const router = require("express").Router();
const {verifyToken} =require("../../controllers/verifyToken")
const CryptoJS = require("crypto-js")
const {search}=require("../../middleware/search")
const G = require("../../enums/grant");
const { getByPhone, getById, getUserById } = require("../../middleware/login");
const jwt = require("jsonwebtoken");
const V = require("../../middleware/values")

const login = require("../../middleware/login")
const AS = require("../../sockets/adminSocket")
router.delete("/:id",  verifyToken([G.Grants.user]),  async (req, res, next)=>{
    try{
     var user = await User.findByIdAndDelete(req.params.id)
     return res.status(200).json(user)
    }catch(e){next(e)}
})

router.get("/auth",  verifyToken([G.Grants.user,G.Grants.superAdmin,G.Grants.dashboardAdmin]),  async (req, res, next)=>{
    try{
        var user = await getUserById(req.user.id, req.grant)
        var userSerialized = await getByPhone(user.phone, user.countryCode, req.grant)
 
        if(!userSerialized) return res.status(200).json({"message": "Could not find the user"})
        if(userSerialized.user){
            delete userSerialized.user.password
            delete userSerialized.user.devices
        }
        if(userSerialized.detail){
            delete userSerialized.detail.password
            delete userSerialized.detail.devices
        }
        const accessToken = jwt.sign({id: req.user.id, grant: req.grant},process.env.JWT_SEC, {expiresIn: "24h"})
        
        var key="detail"
        if(req.grant===G.Grants.dashboardAdmin) key="adminDetail"
        var loginDataDocument
        if (req.grant === G.Grants.user) loginDataDocument =  {...userSerialized._doc, accessToken}
        else loginDataDocument =  { ...userSerialized.user._doc, accessToken, [key]:userSerialized.detail }
        return res.status(200).json(loginDataDocument)
    }catch(e){ next(e) }
})

router.post("/",  async (req, res, next) => {
    try{
        // if(V.getFromKey("signUp")) return res.status(400).json({"message": "New account is currently under maintainance"})
        if(!req.body.countryCode)return res.status(400).json({"message": "Please update your app!"})
        var user = await User.findOne({phone: req.body.phone, code: req.body.countryCode})
        if(user) return res.status(400).json({"message": "Phone already in use"})
        req.body.password = CryptoJS.AES.encrypt(
            req.body.password,
            process.env.PASS_SEC
        ).toString()
        var user = User(req.body)
        if(req.body.device){
            var device = req.body.device
            var found = false
            for(var i in user.devices){
                if(user.devices[i].deviceId == device.deviceId){
                    user.devices[i].fcmToken = device.fcmToken
                    found = true
                }
            }
            if(found == false){
                user.devices.push(Device(req.body.device))
            }
        }
        await user.save()
        AS.createCustomerById(user._id)
        return await tokenGeneration(req.body.phone, req.body.countryCode, req.body.device, res)
    //  const {devices, password, ...others} = user._doc
    //  return res.status(201).json(others)
    }
    catch(e)
    {
     next(e)
    }
 })

 const tokenGeneration = async (phone, code, device, res)=>{
    var loginData = await login.getByPhone(phone, code, G.Grants.user)
    var loginDetailId =  loginData.detail._id

    const accessToken = jwt.sign({id: loginDetailId, grant: G.Grants.user}, process.env.JWT_SEC, {expiresIn: "24h"})
    const refreshToken = jwt.sign({id: loginDetailId, grant: G.Grants.user}, process.env.JWT_SEC, {expiresIn: "30d"})
    if (device && G.Grants.user && loginDetailId && device.deviceId){
        await login.removeOtherUsersEngagedInDevice(device, G.Grants.user)
        var user = await login.getById( loginDetailId, G.Grants.user)
        await login.engageUserWithDevice(device, user)
    }else  return res.status(400).json({"message": "Device cannot be registered!"})

    if (!loginData) return res.status(403).json({ "error": "Unauthorized token" })
    delete loginData.user.password
    delete loginData.user.devices
    loginData = loginData.detail._doc

    return res.status(201).json({ ...loginData, accessToken, refreshToken })

 }


router.get("/logout/:deviceId", verifyToken([G.Grants.user]),   async(req, res, next) => {
    try {
        var user = await User.findById(req.user.id)
        if(user){
            for(var i in user.devices){
                if(user.devices[i].deviceId == req.params.deviceId){
                    user.devices[i].notify = false;
                }
            }
            await user.save()
        }
        return res.status(200).json("success")
    } catch (e) {
        next(e)
    }
})

router.put("/password", verifyToken([G.Grants.user]), async (req, res, next) => {
    try {
        var loginData = await User.findById(req.user.id)
        if (!loginData) return res.status(400).json({"message": "User not found!"})
        const myP = loginData.password
        const hashedPassword = CryptoJS.AES.decrypt(myP.toString(),process.env.PASS_SEC);
        const OriginalPassword = hashedPassword.toString(CryptoJS.enc.Utf8);
        if (OriginalPassword !== req.body.currentPassword)  return res.status(400).json({"message": "Current password is incorrect!"})
        if(req.body.currentPassword == req.body.newPassword)  return res.status(400).json({"message": "New password cannot match old password!"})
        req.body.newPassword = CryptoJS.AES.encrypt(req.body.newPassword,process.env.PASS_SEC)
        loginData.password = req.body.newPassword
        await loginData.save()
        return res.status(200).json({"message":"success"})
    } catch (err) {
        console.log(err)
        return res.status(500).json(err);
    }
})

router.put("/phone", verifyToken([G.Grants.user]), async (req, res, next) => {
    try {
        var loginData = await User.findById(req.user.id)
        if (!loginData) return res.status(400).json({"message": "User not found!"})
        if (!req.body.countryCode) return res.status(400).json({"message": "Please update the application!"})
        const myP = loginData.password
        const hashedPassword = CryptoJS.AES.decrypt(myP.toString(),process.env.PASS_SEC)
        const OriginalPassword = hashedPassword.toString(CryptoJS.enc.Utf8)
        if (OriginalPassword !== req.body.password)  return res.status(400).json({"message": "Current password is incorrect!"})
        
        var otherUser = await User.aggregate([{$match: {phone: req.body.phone, countryCode: req.body.countryCode}}])
        if(otherUser.length)  return res.status(400).json({"message": "The number is being used in a different account"})
        loginData.phone = req.body.phone
        loginData.countryCode = req.body.countryCode
        await loginData.save()
        return res.status(200).json({"message":"Phone number changed successfully"})
    } catch (err) {
        console.log(err)
        return res.status(500).json(err);
    }
})
module.exports = router