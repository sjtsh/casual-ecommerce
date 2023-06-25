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

const Q = require("../../../enums/query")
const DH = require("../../../middleware/dashboard_helper")
const DOrder = require("../../../middleware/serialization/dashboardOrder")
//  sku fullfilled, bill

//quewry search no date
//sort should work
router.get("/", verifyToken(Grants.dashboardAdmin), comprehendRole(DR.OrdersRoles.read), async(req,res,next)=>{
    try{
        var results = await WL.handleQueriesWithCount(Order, req, DOrder.serialization, {param: "shop"})
        return res.status(200).json(results)
    }catch(e) {next(e)}
})
module.exports = router