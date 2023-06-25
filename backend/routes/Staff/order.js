const mongoose = require("mongoose")
const router = require("express").Router();
const {verifyToken, comprehendRole} = require("../../controllers/verifyToken");
const ShopNearby = require("../../middleware/shop_nearby");
const { Order, SingularOrderFeedback, RequestedShop, Rating } = require("../../models/order");
const { Shop } = require("../../models/shop");
const onConnection = require("../../sockets/onConnection");
const { Staff } = require("../../models/admin");
const OR = require("../../enums/outletRole")
const G = require("../../enums/grant");
const { getPersonalOrder, getPersonalRequestedShop } = require("../../middleware/serialization/serialization");
const Serialization = require("../../middleware/serialization/serialization");


router.get("/new", verifyToken([G.Grants.staff]), comprehendRole(OR.OrderRoles.receive),  async(req, res, next) => {
    try {
        const staff = await Staff.findById(req.user.id)
        if(staff.deactivated == true) return res.status(411).json({"message":"Sorry the staff has been deactivated"})
        var orders = await Order.aggregate([
            {$match: {shop: {$in: staff.shop}}},
            {$match: {$or: [{ status: 0 },{ status: 2 },], deactivated: {$ne: true}}},   
            {$lookup: {foreignField: "order",localField: "_id",as: "requestedShop",from: "requestedshops", pipeline: [{ $match: { shop: {$in: staff.shop}, staff: staff._id} }]},},
        ])
        
        var returnableOrders = []
        for (var i in orders) {
            var recentRequestedShop = null
            if (!orders[i].requestedShop.length) {
                recentRequestedShop = await ShopNearby.createARequestedShop( req.user.id, orders[i].shop, orders[i])
            } else if (!orders[i].requestedShop[0].status) {
                recentRequestedShop = orders[i].requestedShop[0]
            }
            if(recentRequestedShop != null){
                orders[i].requestedShop = getPersonalRequestedShop(recentRequestedShop)
                if(orders[i].requestedShop.deactivated != true) {
                    returnableOrders.push(orders[i])
                }
            }
        }
        for (var i in returnableOrders) {
            returnableOrders[i] = await getPersonalOrder(returnableOrders[i]._id, req.user.id)
        }
        return res.status(200).json(returnableOrders)
    } catch (e) {
        next(e)
    }

})
 


router.get("/all",  verifyToken([G.Grants.staff]), async(req, res, next) => {
    try{
        var staff = await Staff.findById(req.user.id)
        if(staff.deactivated == true) return res.status(411).json({"message":"Sorry the staff has been deactivated"})
        if(!req.query.skip) return res.status(403).json("version outdated")
        var request
        var order
        var withFilters = [{_id: {$ne: null}}]
        if(req.query.request){
            validRequestStatuses = req.query.request.split(".").map((element)=> { 
                var ele = parseInt(element)
                if(ele == -1) return {$or: [{status: ele}, {"feedback.deliveryRejections": mongoose.Types.ObjectId(req.user.id)}]}
                if(ele == 0) return {$or: [{status: ele}, {"feedback.deliveryMisses": mongoose.Types.ObjectId(req.user.id)}]}
                else return {$and: [{"status": ele},  {"order.status": {$ne: 1}},]}
            })
            var request =  {$or: validRequestStatuses}
        }
        if(req.query.order) var order = req.query.order.split(".").map((element) => {return {"order.status": parseInt(element)}})
        if(request || order) withFilters = []
        if(request) withFilters.push(request)
        if(order) withFilters.push({$or: order})
        var dateStart
        var dateEnd
        var dateWithTime = new Date()
        if(process.env.ISPRODUCTION === "false"){
            dateStart = new Date(dateWithTime.getFullYear(), dateWithTime.getMonth(), dateWithTime.getDate(), 5, 45, 0, 0) // true for non production server
            dateEnd = new Date(dateWithTime.getFullYear(), dateWithTime.getMonth(), dateWithTime.getDate() + 1, 5, 45, 0, 0)
        }else{
            dateStart = new Date(dateWithTime.getFullYear(), dateWithTime.getMonth(), dateWithTime.getDate(), 0, 0, 0, 0) // true for production server
            dateEnd = new Date(dateWithTime.getFullYear(), dateWithTime.getMonth(), dateWithTime.getDate() + 1, 0, 0, 0, 0) // true for production server
        }
        // subtracting with the utc to nepal time 5:45
        dateStart = new Date(dateStart.getFullYear(), dateStart.getMonth(), dateStart.getDate(), dateStart.getHours() - 5, dateStart.getMinutes() - 45, 0, 0) 
        var dateFilter = [{createdAt: {$ne: null}}]
        if(req.query.today == "false") dateFilter = [{$or: [{createdAt: {$lt: dateStart}}, {createdAt: {$gte: dateEnd}}]}]
        else if(req.query.today == "true") dateFilter = [{$and: [{createdAt: {$gte: dateStart}}, {createdAt: {$lt: dateEnd}}]}]
        var queries = [
            {$match: {
                deactivated: {$ne: true},
                $and: dateFilter,
                $or: [...Serialization.standardOrRequestQuery(req.user.id)]
            }},
        ]
        if(request || order){
            queries = [...queries,
                {$lookup: {foreignField: "_id",localField: "order",as: "order",from: "orders",}},
                { $unwind: "$order" },
                {$match:{ $or: withFilters}},
            ]
        }
        queries = [...queries, 
            {$sort: {createdAt: -1}},
            {$skip: parseInt(req.query.skip) },
            {$limit: parseInt(req.query.limit) },
        ]
        var requestedShops = await RequestedShop.aggregate(queries)
        for (var i in requestedShops) {
            var id = requestedShops[i].order
            if(request || order) id = id._id
            var ord = await getPersonalOrder(id, req.user.id)
            requestedShops[i]= ord
        }
        return res.status(200).json(requestedShops)
    }
    catch(e){
        console.log(e)
        next(e)}
})
module.exports = router