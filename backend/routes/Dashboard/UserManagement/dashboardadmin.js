const router = require("express").Router()
const { Staff, DashboardAdmin } = require("../../../models/admin")
const DR = require("../../../enums/dashboardRole");
const {User} = require("../../../models/user");
const {verifyToken, comprehendRole, comprehendOrRole, authorityWithParam} = require("../../../controllers/verifyToken")
const OR = require("../../../enums/outletRole")
const {search}=require("../../../middleware/search")
const G = require("../../../enums/grant");
const {Shop} = require("../../../models/shop");
const { default: mongoose } = require("mongoose");
const WL = require("../../../middleware/withLength");
const { Grants } = require("../../../enums/grant");
const user = require("../../../models/user");
const SG = require("../../../middleware/ShopGrants")
const AS = require("../../../sockets/adminSocket")

router.post("/core", verifyToken(Grants.dashboardAdmin), comprehendRole(DR.AdminsRoles.create), async (req, res, next) => {
    try{
        var dashboardadmin = await DashboardAdmin.findOne({"user": req.body.user})
        if(dashboardadmin) return res.status(400).json({"message":"The user is already a staff"})
        dashboardadmin = DashboardAdmin(req.body)
        await dashboardadmin.save()
        AS.createDashboardAdmin(dashboardadmin)
        return res.status(201).json(dashboardadmin)
    }
    catch(e){next(e)}
})

router.put("/core/:id", verifyToken(Grants.dashboardAdmin), comprehendRole(DR.AdminsRoles.update),  async (req, res, next) => {
    try{  
        var dashboardAdmin = await DashboardAdmin.findById(req.params.id)
        var prevRoles = dashboardAdmin.roles
        await DashboardAdmin.findByIdAndUpdate(req.params.id, req.body)
        dashboardAdmin = await DashboardAdmin.findById(req.params.id)
        var currentRoles = dashboardAdmin.roles
        AS.updateDashboardAdmin(dashboardAdmin, prevRoles, currentRoles)
        return res.status(200).json(dashboardAdmin)
    }catch(e){next(e)}
})

router.get("/roles", verifyToken(Grants.dashboardAdmin), comprehendOrRole([DR.AdminsRoles.update, DR.AdminsRoles.create]),  async (req, res, next) => {
    try{
        return res.status(200).json(DR.providable)
    }catch(e){next(e)}
})

router.get("/roles/:id", verifyToken(Grants.dashboardAdmin), comprehendOrRole([DR.AdminsRoles.update, DR.AdminsRoles.create]), authorityWithParam("id"), async (req, res, next) => {
    try{
        if(req.grant == Grants.superAdmin) return res.status(200).json(DR.providable)
        var dashboardadmin = await DashboardAdmin.findById(req.user.id)
        var roles = []
        for(var i in dashboardadmin.roles){
            if(dashboardadmin.roles[i].shop == req.params.id) {
                roles = dashboardadmin.roles[i].roles
                break
            }
        }
        return res.status(200).json(roles)
    }catch(e){next(e)}
})


router.get("/roles/required", verifyToken(Grants.dashboardAdmin),  comprehendOrRole([DR.AdminsRoles.update, DR.AdminsRoles.create]), async (req, res, next) => {
    try{
        return res.status(200).json(DR.required)
    }
    catch(e){next(e)}
})

router.get("/search", verifyToken(Grants.dashboardAdmin), comprehendRole(DR.AdminsRoles.update), async (req, res, next) => {
    try {
        if (req.query.s) {
            var admins= await search(User,req.query.s,  [
                {$lookup: {as: "dashboardadmin", from: "dashboardadmins", localField: "_id", foreignField: "user"}},
                {$unwind: "$dashboardadmin"},
                {$project: {name:1, phone: 1, dashboardadmin: { _id: 1, user: 1, roles: 1, deactivated: 1}}},
                {$match: {"dashboardadmin._id": {$ne: mongoose.Types.ObjectId(req.user.id)}}},
                {$unwind: "$dashboardadmin.roles"},
                ...SG.filterQueryGet(req,"dashboardadmin.roles.shop"),
                {$lookup: {as: "dashboardadmin.roles.shop", from: "shops", localField: "dashboardadmin.roles.shop", foreignField: "_id", pipeline:[{$project: {_id: 1, id: 1, name: 1, phone: 1}}]}},
                {$unwind: "$dashboardadmin.roles.shop"},
                {$group:{_id: "$_id", id: {$last: "$id"}, name: {$last: "$name"}, phone: {$last: "$phone"}, "dashboardadmin_id": {$last: "$dashboardadmin._id"}, "dashboardadminuser": {$last: "$dashboardadmin.user"}, "dashboardadminroles": {$push: "$dashboardadmin.roles"}, "dashboardadmindeactivated": {$last: "$dashboardadmin.deactivated"}}},
                {$project: {id: 1, name:1, phone: 1, adminDetail: {_id: "$dashboardadmin_id", user: "$dashboardadminuser", roles: "$dashboardadminroles", deactivated: "$dashboardadmindeactivated"}}}
            ])
            return res.status(200).json(admins)
        }
        else
            return res.status(400).json({ "message": "Invalid search query" })
    }
    catch (e) {
        console.log(e)
        next(e)
    }

})



router.get("/", verifyToken(Grants.dashboardAdmin), comprehendRole(DR.AdminsRoles.read), async(req,res,next)=>{
    try{
        var results = await WL.handleQueriesWithCount(DashboardAdmin, req, [ ], {pre: [
            {$match: {_id: {$ne: mongoose.Types.ObjectId(req.user.id)}}},
            {$lookup: {as: "user", from: "users", localField: "user", foreignField: "_id", pipeline:[{$project:{"name":1,"phone":1,"_id":1}}]}},
            {$unwind:"$user"},
            {$unwind:"$roles"},
            ...SG.filterQueryGet(req, "roles.shop"),
            {$lookup: {as: "roles.shop", from: "shops", localField: "roles.shop", foreignField: "_id", pipeline:[{$project:{"name":1,"phone":1,"_id":1}}]}},
            {$unwind: "$roles.shop"},
            {$group: {_id: "$_id", roles: {$push: "$roles"}, id: {$last: "$id"}, shop: {$last: "$shop"}, user: {$last: "$user"},deactivated: {$last:  "$deactivated"}, createdAt: {$last:  "$createdAt"}, lastDisconnected: {$last:  "$lastDisconnected"}, lastConnected: {$last:  "$lastConnected"},}},
            {$project: {id: 1, roles: 1, shop: 1, user: 1, deactivated: 1, createdAt : 1,                
                active: {$cond: [{
                    $and: [
                        {$ne: [{$ifNull: ["$lastConnected", 0]}, 0]},
                        {$gte: ["$lastConnected", {$ifNull: ["$lastDisconnected", "$lastConnected"]}]}
                    ]
                }, true,  "$lastDisconnected"]},
            }}
        ]})
        return res.status(200).json(results)
    }
    catch(e) {next(e)}
})

module.exports = router