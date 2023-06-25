const router = require("express").Router()
const { default: mongoose } = require("mongoose")
const { User } = require("../../../models/user")
const { SubCategory } = require("../../../models/category")
const WL = require("../../../middleware/withLength")
const { Grants } = require("../../../enums/grant")
const {verifyToken, comprehendRole} = require("../../../controllers/verifyToken")
const DR = require("../../../enums/dashboardRole")
const SG = require("../../../middleware/ShopGrants")
const { Order } = require("../../../models/order")
const DCustomer = require("../../../middleware/serialization/dashboardCustomer")


router.get("/", verifyToken(Grants.dashboardAdmin), comprehendRole(DR.CustomersRoles.read), async(req,res,next)=>{
    try{
        var queries = []
        if(req.user.grant == Grants.dashboardAdmin){
            var usersOrdered = (await Order.aggregate([...SG.filterQueryGet(req, "shop"), {$group: {_id: 1,"count": {$addToSet: "$user"}}} ]))
            if(!usersOrdered.length) return res.status(200).json({"data": [], count: 0})
            if(usersOrdered.length) queries.push({$match: {_id: {$in: usersOrdered[0].count}}})
        }
        var results = await WL.handleQueriesWithCount(User, req, [
            ...DCustomer.serialization
            ], {sort: "value", pre: queries})
        return res.status(200).json(results)
    }catch(e) {next(e)}
})

module.exports = router