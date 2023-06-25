const router = require("express").Router()
const { Staff } = require("../../../models/admin")
const DR = require("../../../enums/dashboardRole");
const {User} = require("../../../models/user");
const {verifyToken, comprehendRole, comprehendOrRole, authorityWithParam} = require("../../../controllers/verifyToken")
const OR = require("../../../enums/outletRole")
const {search}=require("../../../middleware/search")
const G = require("../../../enums/grant");
const {Shop} = require("../../../models/shop");
const { default: mongoose } = require("mongoose");
const WL = require("../../../middleware/withLength");
const { Grants } = require("../../../enums/grant")
const SG = require("../../../middleware/ShopGrants")
const AS = require("../../../sockets/adminSocket")


const staffSerialization = [
    {$lookup: {as: "user", from: "users", localField: "user", foreignField: "_id", pipeline:[{$project:{"name":1,"phone":1,"_id":1}}]}},
    {$unwind:"$user"},
    {$unwind:"$shop"},
    {$lookup: {as: "shop", from: "shops", localField: "shop", foreignField: "_id", pipeline:[{$project:{"name":1,"phone":1,"_id":1}}]}},
    {$unwind:"$shop"},
    {$group: {
        _id: "$_id", 
        id: {$last: "$id"}, 
        user: {$last: "$user"}, 
        shop: {$push: "$shop"}, 
        role: {$last: "$role"}, 
        createdAt: {$last: "$createdAt"},
        deactivated: {$last: "$deactivated"}, 
        lastLocation: {$last: "$lastLocation"}, 
        lastConnected: {$last: "$lastConnected"}, 
        lastDisconnected: {$last: "$lastDisconnected"}
    }},
    {$project: {id: 1, user: 1, shop: 1, role: 1, createdAt: 1, deactivated: 1, lastLocation: 1,
        active: {$cond: [{
            $and: [
                {$ne: [{$ifNull: ["$lastConnected", 0]}, 0]},
                {$gte: ["$lastConnected", {$ifNull: ["$lastDisconnected", "$lastConnected"]}]}
            ]
        }, true,  "$lastDisconnected"]},}}
]


const getStaff = async (id) => {
    var staff = await Staff.aggregate([
        {$match: {_id : mongoose.Types.ObjectId(id)}},
        ...staffSerialization
    ])
    return staff[0]
}

router.post("/core", verifyToken(Grants.dashboardAdmin), comprehendRole(DR.StaffsRoles.create), async (req, res, next) => {
    try{
        var staff = await Staff.findOne({"user": req.body.user})
        if(staff) return res.status(400).json({"message":"The user is already a staff"}) 
        var staff = Staff(req.body)
        await staff.save()
        staff = getStaff(staff._id)
        AS.updateStaff(staff, req.headers["socket-id"])
        return res.status(201).json(staff)
    }
    catch(e){next(e)}
})

router.put("/core/:id", verifyToken(Grants.dashboardAdmin), comprehendRole(DR.StaffsRoles.update), async (req, res, next) => {
    try{  
        await Staff.findByIdAndUpdate(req.params.id, req.body)
        var staff = await Staff.findById(req.params.id)
        staff = getStaff(staff._id)
        AS.createStaff(staff, req.headers["socket-id"])
        return res.status(200).json(staff)
    }
    catch(e){next(e)}
})


router.get("/roles", verifyToken(Grants.dashboardAdmin), comprehendOrRole([DR.StaffsRoles.update, DR.StaffsRoles.create]), async (req, res, next) => {
    try{
        return res.status(200).json(OR.all)
    }
    catch(e){next(e)}
})

router.get("/role/:id", verifyToken(Grants.dashboardAdmin), comprehendOrRole([DR.StaffsRoles.update, DR.StaffsRoles.create]), authorityWithParam("id"), async (req, res, next) => {
    try{
        return res.status(200).json(OR.all)
    }
    catch(e){next(e)}
})


router.get("/roles/required", verifyToken(Grants.dashboardAdmin), comprehendOrRole([DR.StaffsRoles.update, DR.StaffsRoles.create]), async (req, res, next) => {
    try{
        return res.status(200).json(OR.required)
    }
    catch(e){next(e)}
})

router.get("/user/search", verifyToken(Grants.dashboardAdmin), comprehendRole( DR.StaffsRoles.create), async (req, res, next) => {
    try {
        if (req.query.s) {
            var shops= await search(User,req.query.s)
            return res.status(200).json(shops)
        }
        else
            return res.status(400).json({ "message": "Invalid search query" })
    }
    catch (e) {
        console.log(e)
        next(e)
    }

})

router.get("/search", verifyToken(Grants.dashboardAdmin), comprehendRole(DR.StaffsRoles.edit), async (req, res, next) => {
    try {
        if (req.query.s) {
            var shops= await search(User,req.query.s,  [
                {$lookup: {as: "staff", from: "staffs", localField: "_id", foreignField: "user", pipeline: [
                    {$lookup: {as: "shop", from: "shops", localField: "shop", foreignField: "_id", pipeline: [{$project:{name:1,phone:1}}]}},
                    {$unwind: "$shop"}
                ]}},
                {$unwind: "$staff"},
                {$project: {name:1,phone: 1,staff: { _id: 1, user: 1,shop: 1,"role.roles":{label: 1, roles: 1},deactivated: 1}}},
                {$project: {name:1,phone: 1,detail: "$staff"}}
            ])
            return res.status(200).json(shops)
        }
        else
            return res.status(400).json({ "message": "Invalid search query" })
    }
    catch (e) {
        console.log(e)
        next(e)
    }

})



router.get("/", verifyToken(Grants.dashboardAdmin), comprehendRole(DR.StaffsRoles.read), async(req,res,next)=>{
    try{
        var staffs = await WL.handleQueriesWithCount(Staff, req, staffSerialization , {param: "shop"})
        return res.status(200).json(staffs)
    }
    catch(e) {next(e)}
})

module.exports = router