const { Shop} = require("../../models/shop")
const { Device, User, } = require("../../models/user")
const router = require("express").Router();
const XLSX = require('xlsx');
const app = require("../../urls");
const {verifyToken} = require("../../controllers/verifyToken");
const { recurseForShopExport } = require("../../middleware/shop_nearby");
const CryptoJS = require("crypto-js");
const { default: mongoose } = require("mongoose");
// import {map} from "../sockets/onConnection";
const {search}=require("../../middleware/search")

router.post("/", async (req, res, next) => {
    try{
    var shop = await Shop.findOne({ phone: req.body.phone })
    if (shop) {
        return res.status(421).json({ "message": "Phone already in use" })
    }
    if(req.body.pan){
        shop = await Shop.findOne({ pan: req.body.pan })
        if (shop) {
            return res.status(421).json({ "message": "Pan already in use" })
        }
    }
    req.body.password = CryptoJS.AES.encrypt(
        req.body.password,
        process.env.PASS_SEC
    ).toString()
    if (req.body.device) {
        var device = req.body.device
        var found = false
        for (var i in shop.devices) {
            if (shop.devices[i].deviceId == device.deviceId) {
                shop.devices[i].fcmToken = device.fcmToken
                found = true
            }
        }
        if (found == false) {
            shop.devices.push(Device(res.body.device))
        }
        await shop.save()
    }
    var shop = Shop(req.body)
    await shop.save()
   
        var shop1 = await Shop.aggregate([
            { $match: { _id: shop._id } },
            { $unwind: "$categories" },
            { $lookup: { as: "categories", from: "categories", localField: "categories", foreignField: "_id" } },
            { $unwind: "$categories" },
            {
                $group: {
                    _id: "$_id",
                    categories: { $addToSet: "$categories" },
                    img: { $last: "$img" },
                    address: { $last: "$address" },
                    name: { $last: "$name" },
                    phone: { $last: "$phone" },
                    pan: { $last: "$pan" },
                    location: { $last: "$location" },
                    available: { $last: "$available" },
                    owner: { $last: "$owner" },
                    deliveryRadius: { $last: "$deliveryRadius" },
                    createdAt: { $last: "$createdAt" },
                    updatedAt: { $last: "$updatedAt" },
                }
            }
        ])
        if (!shop1.length) {
            return res.status(403).json({ "message": "Unauthorized Request" })
        }
        return res.status(200).json(shop1[0])
    } catch (e) { next(e) }
})

router.put("/available", verifyToken(), async (req, res, next) => {
    try{
    var updatedShop = await Shop.findByIdAndUpdate(req.user.id, { available: req.body.available })
    if (updatedShop)
        return res.status(200).json(req.body.available)
    else
        return res.status(400).json(false)
    }
    catch(e){next(e)}
})


router.get("/radius/:range", verifyToken(), async (req, res, next) => {
    try{
    var shop = await Shop.findById(req.user.id)
    var range = parseFloat(req.params.range)
    if (range) {
        shop.deliveryRadius = range
    }
    await shop.save()
    return res.status(200).json("success")
}
catch(e){next(e)}
})


router.get("/n", async (req, res, next) => {
    try{
    return res.status(200).json("shop")
}
catch(e){next(e)}
})

router.get("/nearby", async (req, res, next) => {

    try {
        return res.status(200).json(await recurseForShopExport(1500, parseFloat(req.query.lat), parseFloat(req.query.lon)))
    } catch (e) {
        next(e)
    }
})


router.get("/ringtone/:status", verifyToken(), async (req, res, next) => {
    try{
    var user = await Shop.findOne({_id: req.user.id})
    if(!user){
        return res.status(421).json("Could not find you")
    }
    user.ringtone = req.params.status == "true"
    await user.save()
    return res.status(200).json("success")
}
catch(e){next(e)}
})

router.get("/getringtone", verifyToken(), async (req, res, next) => {
    try{
    var user = await Shop.findOne({_id: req.user.id})
    if(!user){
        return res.status(421).json("Could not find you")
    }
    return res.status(200).json(user.ringtone.toString())
}
catch(e){next(e)}
})


router.get("/", async (req, res, next) => {
    try{
        var shops=await Shop.aggregate([{$limit:5}]);
        return res.status(200).json(shops)
    }
    catch(e)
    {
        next(e)
    }
  
})



module.exports = router