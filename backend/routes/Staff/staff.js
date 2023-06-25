const { Shop} = require("../../models/shop")
const router = require("express").Router();
const {verifyToken, comprehendRole} = require("../../controllers/verifyToken")
const OR = require("../../enums/outletRole")
const G = require("../../enums/grant");
const { Staff } = require("../../models/admin");
const login = require("../../middleware/login");
const { User } = require("../../models/user");
const V = require('../../middleware/values')


router.put("/img",  verifyToken([G.Grants.staff]), async (req, res, next) => {
    try{
        if(!req.body.img) return res.status(400).json("Could not find the image url")
        var updatedShop = await Shop.findByIdAndUpdate(req.user.id, { img: [req.body.img] })
        if (updatedShop)
            return res.status(200).json(true)
        else
            return res.status(400).json(false)
        }
    catch(e){next(e)}
})

router.get("/connection", async(req, res, next) => {
    try {
        return res.status(200).json("true")
    } catch (e) { next(e) }
})

router.get("/info", verifyToken([G.Grants.staff]), async (req, res, next) => {
    try {
        var staff = await Staff.findById(req.user.id)        

        if(!staff || staff == null) return res.status(410).json({ "message": "Please log in again" })
        if(staff.deactivated) return res.status(410).json({ "message": "Your account was deactivated" })
        if(!staff.devices.length) return res.status(410).json({ "message": "Please log in again" })
        
        var user = await User.findById(staff.user).select( {_id: 1, name: 1,phone: 1, id: 1})
        var detail = await Staff.findById(staff._id).select({ available: 1,avgRating: 1,raterCount: 1,ratingStar: 1, id: 1, _id: 1, shop: 1, role: 1, support: 1})
        var shops = []
        for(var i in detail.shop){
            shops.push(await Shop.findById(detail.shop[i]).select( {_id:1,name:1,phone: 1,location: 1,available: 1,id: 1,img:1, address: 1,timing: 1}))
        }
        detail.shop = shops
        if(detail.shop.deactivated == true) return res.status(410).json({"message": "The shop has been 1 deactivated"})
        return res.status(200).json({"user": user, "detail": detail})
    } catch (e) { 
        next(e)
    }
})

router.delete("/logout/:deviceId", verifyToken([G.Grants.staff]), async (req, res, next) => {
    try{
        var user = await Shop.findOne({_id: req.user.id})
        if(!user) return res.status(200).json("unsuccessful")
        var newSetOfDevices = user.devices.filter((dev)=>{
            return dev.deviceId != req.params.deviceId
        })
        user.devices = newSetOfDevices
        await user.save()
        return res.status(200).json("success")
    }
    catch(e){next(e)}
})

module.exports = router