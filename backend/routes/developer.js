const router = require("express").Router()
const { verifyToken } = require("../controllers/verifyToken")
const { Grants } = require("../enums/grant")
const OR = require("../enums/outletRole")
const { Staff } = require("../models/admin")

router.put("/", verifyToken(Grants.staff), async (req, res, next) => {
    try{
        if(process.env.ISPRODUCTION === "true") return res.status(400).json("Unable to change own role")
        await Staff.findByIdAndUpdate(req.user.id, req.body)
        return res.status(200).json("success")
    }
    catch(e){next(e)}
})

router.get("/", async (req, res, next) => {
    try{return res.status(200).json(OR.all)}
    catch(e){next(e)}
})

module.exports = router