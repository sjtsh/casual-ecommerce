const router = require("express").Router()
const { default: mongoose } = require("mongoose")
const { User } = require("../../../models/user")
const { SubCategory } = require("../../../models/category")
const WL = require("../../../middleware/withLength")
const { Shop } = require("../../../models/shop")
const { Staff } = require("../../../models/admin")
const { Grants } = require("../../../enums/grant")
const {verifyToken, comprehendRole, authorityWithParam} = require("../../../controllers/verifyToken")
const DR = require("../../../enums/dashboardRole")
const SG = require("../../../middleware/ShopGrants")
const { Product } = require("../../../models/product")
const { Order } = require("../../../models/order")

const DH = require("../../../middleware/dashboard_helper")
const user = require("../../../models/user")
const Q = require("../../../enums/query")



router.get("/", verifyToken(Grants.dashboardAdmin), comprehendRole(DR.OrdersRoles.read), async(req,res,next)=>{
    try{
        var stats = await Order.aggregate([
            ...SG.filterQueryGet(req, "shop"),
            ...WL.dtFilter(req),
            {$group: {
                _id: "_id",
                "order_count_total": {$sum: 1}, 
                "order_count_delivered": {$sum:{$cond: [{$ne: ["$status", 5]}, 0, 1]},},
                "order_value_total": {$sum: "$total"}, 
                "order_value_delivered": {$sum:{$cond: [{$ne: ["$status", 5]}, 0, "$total"]},},
                "user_count_active": {$addToSet: "$user"}
            }}
        ])      
        if(!stats.length) return res.status(200).json({"order_count_total": 0, "order_count_delivered": 0,"order_value_total":0, "order_value_delivered": 0,"user_count_active": 0,"user_count_total": 0})
        if(!stats.length) return res.status(400).json({"message": "No orders found"})
        stats[0]["user_count_active"] = stats[0]["user_count_active"].length
        if(req.user.grant == Grants.superAdmin){ 
            stats[0]["user_count_total"] = (await User.find()).length
        } else {
            stats[0]["user_count_total"] = (await Order.aggregate([...SG.filterQueryGet(req, "shop"), {$group: {_id: 1,"count": {$addToSet: "$user"}}} ]))[0].count.length
        }
        delete stats[0]["_id"]
        return res.status(200).json(stats[0])
    }
    catch(e) {
        
        console.log(e)
        next(e)}
})
module.exports = router