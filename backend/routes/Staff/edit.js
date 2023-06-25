
const router = require("express").Router()
const { Shop } = require("../../models/shop")
const { EditStaff } = require("../../models/edit")
const {verifyToken} = require("../../controllers/verifyToken");
const { RequestedShop } = require("../../models/order");
const G = require("../../enums/grant");
const CryptoJS = require("crypto-js");
const jwt = require("jsonwebtoken");
const { Staff } = require("../../models/admin");
const { User } = require("../../models/user");

router.put("/", verifyToken([G.Grants.staff]), async (req, res, next) => {
    try{
    var keys = Object.keys(req.body)
    var updatables = new Map()
    for(var i in keys){
        var categoryThis =  keys[i]
        var categoryValue =  req.body[keys[i]]
        var editStaff = await EditStaff.findOne({"staff": req.user.id, "category":categoryThis})
        var shouldUpdate = false
        if(editStaff){
            var last_updated = editStaff.last_updated
            var difference = new Date() - last_updated
            shouldUpdate = (difference / (1000 * 3600 * 24)) >= 1
            editStaff.last_updated = new Date()
        }else{
            shouldUpdate = true
            editStaff =  EditStaff({"staff": req.user.id, "category":categoryThis, "last_updated": new Date()})
        }
        if(shouldUpdate == true){
            await editShop.save()
            updatables[categoryThis] = categoryValue
        }
    }
    if(updatables.size) await Staff.findByIdAndUpdate(req.user.id, updatables)
    return res.status(200).json("success")
}
catch(e){next(e)}
})


router.get("/:key", verifyToken([G.Grants.staff]), async (req, res, next) => {
    try{
    var editStaff = await EditStaff.findOne({"staff": req.user.id, "category":req.params.key})
    var shouldUpdate = false
    var difference
    if(editStaff){
        var last_updated = editStaff.last_updated
        difference = new Date() - last_updated
        shouldUpdate = 1000 * 3600 * 24 <= difference
    }else{
        shouldUpdate = true
    }
    if(shouldUpdate == true){
        return res.status(200).json("true")
    }
    return res.status(200).json((1000 * 3600 * 24) - difference)
}
catch(e){next(e)}
})
module.exports = router