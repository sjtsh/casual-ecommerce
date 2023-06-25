const router = require("express").Router()
const CryptoJS = require("crypto-js")
const jwt = require("jsonwebtoken")
const { User} = require("../../models/user")
const { DashboardAdmin , Staff, SuperAdmin} = require("../../models/admin")
const { Shop } = require("../../models/shop")
const G = require("../../enums/grant")
const DR = require("../../enums/dashboardRole")
const login = require("../../middleware/login")

router.post("/login/:grant", async (req, res, next) => {
    try {
        var grant = req.params.grant.toLowerCase()
        if (!grant || !req.body.phone) return res.status(400).json({"message": "Parameters not defined!"})
        if (!req.body.countryCode) return res.status(400).json({"message": "Please update your application!"})
        var loginData = await login.getByPhone(req.body.phone, req.body.countryCode, grant)
        if (!loginData) return res.status(400).json({"message": "User not found!"})
        if (loginData.deactivated == true) return res.status(400).json({"message": "The account has been deactivated!"})
        if (grant === G.Grants.staff && loginData.detail.shop.deactivated == true) return res.status(400).json({"message": "The shop has been deactivated"})
        if (grant === G.Grants.user) loginData = await loginData.user.populate([{path:"favourites.products"},{path:"favourites.categories"}])
        var myP
        if (grant === G.Grants.user) myP = loginData.password
        else myP = loginData.user.password
        const hashedPassword = CryptoJS.AES.decrypt(myP.toString(),process.env.PASS_SEC)
        const OriginalPassword = hashedPassword.toString(CryptoJS.enc.Utf8);
        if (OriginalPassword !== req.body.password) return res.status(400).json({"message": "Incorrect Password!"})
        var loginDetailId 
        if (grant === G.Grants.user) loginDetailId =  loginData._id
        else loginDetailId =  loginData.detail._id

        const accessToken = jwt.sign({id: loginDetailId, grant: grant},process.env.JWT_SEC, {expiresIn: "24h"})
        const refreshToken = jwt.sign({id: loginDetailId, grant: grant},process.env.JWT_SEC, {expiresIn: "30d"})
        
        if (req.body.device && grant && loginDetailId && req.body.device.deviceId){
            await login.removeOtherUsersEngagedInDevice(req.body.device, grant)
            var user = await login.getById( loginDetailId,grant)
            await login.engageUserWithDevice(req.body.device, user)
        }else  return res.status(400).json({"message": "Device cannot be registered!"})

        if (!loginData) return res.status(403).json({ "error": "Unauthorized token" })
        if(loginData.user){
            delete loginData.user.password
            delete loginData.user.devices
        }
        if(loginData.detail){
            delete loginData.detail.password
            delete loginData.detail.devices
        }
        if(loginData.shop){
            delete loginData.shop.password
            delete loginData.shop.devices
        }
        var key="detail"
        if(grant===G.Grants.dashboardAdmin) key="adminDetail"
        var loginDataDocument
        if (grant === G.Grants.user) loginDataDocument =  loginData._doc
        else loginDataDocument =  loginData.user._doc

        if(grant!==G.Grants.staff) loginData = {...loginDataDocument, [key]:loginData.detail}
        return res.status(200).json({ ...loginData, accessToken, refreshToken })
    } catch (err) {
        next(err)
        return res.status(500).json(err);
    }
})





module.exports = router