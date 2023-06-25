const router = require("express").Router()
const { Grants } = require("../../../enums/grant")
const {verifyToken, comprehendRole} = require("../../../controllers/verifyToken")
const { Role } = require("../../../models/roles")

const WL = require("../../../middleware/withLength")
const { default: mongoose } = require("mongoose")
const AS = require("../../../sockets/adminSocket")

const roleSerialization = [
    {$project:{"_id": 1, "id": 1, "label": 1, "roles": 1, "createdAt": 1, "deactivated": 1,}},
]

const getRole = async (id) => {
    var role = await Role.aggregate([
        {$match: {_id: mongoose.Types.ObjectId(id.toString())}},
        ...roleSerialization
    ])
    return role
}

router.get("/", verifyToken(Grants.dashboardAdmin), async(req,res,next)=>{
    try{
        var results = await WL.handleQueriesWithCount(Role, req, roleSerialization, {sort: "value"})
        return res.status(200).json(results)
    }
    catch(e) {next(e)}
})


router.put("/:id",verifyToken(Grants.superAdmin), async (req, res, next) => {
    try{
        var role = await Role.findById(req.params.id)
        if(!role) return res.status(400).json({"message": "could not find the preset"})
        await Role.findByIdAndUpdate(req.params.id, req.body)
        var response = await getRole(req.params.id)
        AS.updateRoleProfile(response, req.headers["socket-id"])
        return res.status(200).json(response)
    }catch(e){next(e)}
})

router.post("/",verifyToken(Grants.superAdmin), async (req, res, next) => {
    try{
        var roles = Role(req.body)
        await roles.save()
        var response = await getRole(roles._id)
        AS.createRoleProfile(response, req.headers["socket-id"])
        return res.status(201).json(response)
    }catch(e){next(e)}
})

module.exports = router