const mongoose = require("mongoose")
const router = require("express").Router()
const {verifyToken, comprehendRole} = require("../../controllers/verifyToken")
const { Order, SingularOrderFeedback, RequestedShop, Rating } = require("../../models/order")
const { Shop } = require("../../models/shop")
const { User } = require("../../models/user")
const onConnection = require("../../sockets/onConnection")
const { OrderItem } = require("../../models/order")
const ShopNearby = require("../../middleware/shop_nearby")
const { findById } = require("../../models/shop")
const { verify } = require("jsonwebtoken")
const { processOrder } = require("../../middleware/change_status")
const G = require("../../enums/grant")
const OR = require("../../enums/outletRole")
const { getPersonalRequestedShop } = require("../../middleware/serialization/serialization")
const SS = require("../../sockets/staffSocket");
const US = require("../../sockets/userSocket");
const SUS = require("../../sockets/staffUserSocket");
const { Staff } = require("../../models/admin")
const AS = require("../../sockets/adminSocket");
const { Product } = require("../../models/product")

router.post("/:id", verifyToken([G.Grants.staff]), comprehendRole(OR.OrderRoles.receive), async (req, res, next) => {
    try{    
        var requestedShop = await RequestedShop.findById(req.params.id)
        if(!requestedShop) return res.status(400).json("Sorry could not find the request")
        if(requestedShop.deactivated == true) return res.status(400).json("Sorry the request has been deactivated")
        if(requestedShop.status != 0) return res.status(400).json("Sorry the request has already progressed")
        var order = await Order.findById(requestedShop.order)
        if(order.deactivated == true) return res.status(400).json("Sorry the order has been deactivated")
        if(order.status != 0 && order.status != 2) return res.status(400).json("Sorry the order has already expired")
       
        var newItems = []
        for(var i in req.body.items){
            var count = req.body.items[i].item_count
            var prod = req.body.items[i].product
            var total = req.body.items[i].total
            var productObj = await Product.findById(prod)
            newItems.push({count, item_count: count, total: total, product: prod, margin: productObj.margin, return: productObj.return})
        }

        req.body.items = newItems
        var fulfilled = true
        if(order.items.length != newItems.length) fulfilled = false
        if(fulfilled){
            var itemsMap = new Map()
            var itemsAllMap = new Map()
            for(var i in order.items){
                itemsMap.set(order.items[i].product.toString(),order.items[i])
            }
            for(var i in newItems){
                itemsAllMap.set(newItems[i].product.toString(),newItems[i])
            }
            for(var i in order.items){
                var prod = newItems[i].product.toString()
                var itemMapProd = itemsMap.get(prod)
                var itemMapAllProd = itemsAllMap.get(prod)
                if(itemMapProd.item_count != itemMapAllProd.item_count || itemMapProd.total != itemMapAllProd.total){
                    fulfilled = false
                    break
                }
            }
        }

        order.fulfilled = fulfilled
        await order.save()
        console.log("#" + order.id, "has fulfilled value:", order.fulfilled)

        var feedback = SingularOrderFeedback(req.body)
        requestedShop.feedback = feedback
        requestedShop.status = 1
        await requestedShop.save()
        var respons = await getPersonalRequestedShop(requestedShop)
        await processOrder(order._id, order.user)
        
        return res.status(200).json(respons)
    }
    catch(e){next(e)}
})

router.put("/cancel", verifyToken([G.Grants.staff]), comprehendRole(OR.OrderRoles.cancellation), async(req, res, next) => {
    try{
        var order = await Order.findById(req.body.order_id)
        if(order.deactivated == true) return res.status(400).json("Sorry the order has been deactivated")
        var requestedShop = await RequestedShop.find({ order: order._id, $or: [{staff: req.user.id},{"feedback.deliveredBy": req.user.id}] })
        for (var i in requestedShop) {
            if(requestedShop[i].status == -2) return res.status(400).json("Sorry the request has already been cancelled")
            if(requestedShop[i].deactivated == true) return res.status(400).json("Sorry the request has been deactivated")
            requestedShop[i].status = -2
            await requestedShop[i].save()
            if(requestedShop[i].feedback){
                for(var j in requestedShop[i].feedback.itemsAllocated){
                    order.total = order.total - requestedShop[i].feedback.itemsAllocated[j].total
                }
            }
            if(requestedShop[i].feedback && requestedShop[i].feedback.deliveredBy){
                SS.emitRequestCancelledByStaff(order._id, requestedShop[i].feedback.deliveredBy.toString())
                if(requestedShop[i].feedback.deliveredBy != requestedShop[i].staff){
                    SS.emitRequestCancelledByStaff(order._id, requestedShop[i].staff)
                }
            }
        }
        
        US.emitRequestCancelUser(requestedShop._id, order._id, order.user.toString())
        AS.updateOrderById(order._id)

        var requestedShops = await RequestedShop.find({ order: order._id, $or: [{status: 2}, {status:3}, {status:4}]})
        if(!requestedShops.length){
            order.status = -1
            SUS.emitOrderCancelled(order._id.toString(), false, order.user.toString(), "staffID", false) 
        }
        await order.save()
        return res.status(200).json("success")
    }
    catch(e){next(e)}
})

router.get("/review/:id", verifyToken([ G.Grants.staff]),  async (req, res, next) => {
    if(!req.query.skip) req.query.skip= 0
    if(!req.query.limit) req.query.limit= 10
    try {
        var reviews = await RequestedShop.aggregate([
            { $match: { staff: mongoose.Types.ObjectId(req.params.id), feedback: { $ne: null } } },
            // {$lookup:{
            //     from:"users",
            //      as:"user",
            //     foreignField:"_id",
            //     localField:"feedback.rating.user"
            // }},
            {$project:{
                "ratingByUser":"$feedback.rating.ratingByUser",
                "ratingByShop":"$feedback.rating.ratingByShop",
                "reviewByUser":"$feedback.rating.reviewByUser",
                "createdAt":"$feedback.rating.createdAt",
                "updatedAt":"$feedback.rating.updatedAt",
                "user":"$feedback.rating.user",
            }},
            {$lookup:{localField:"user",as:"user",from:"users",foreignField:"_id",pipeline:[{$project:{name:1}}]},},
            {$unwind:"$user"},
            {$sort: {createdAt: -1}},
            {$skip: parseFloat(req.query.skip)},
            {$limit: 10}
        ])
        var stats = await Staff.findById(req.params.id)
        if(!stats) return res.status(201).json("Could not find a staff with the following id")
        return res.status(200).json({"reviews":reviews, "stats":stats.ratingStar})
    }catch (e) {next(e)}
})

router.put("/review", verifyToken([G.Grants.staff]), comprehendRole(OR.DeliveryRoles.delivery),  async (req, res, next) => {
    try {
        if (!req.body.requestedshop) return res.status(400).json({ "message": "requested shop not found" })
        if (!req.body.rate) return res.status(400).json({ "message": "rate not found" })
        if (!(req.body.rate >= 0 && req.body.rate <= 5)) return res.status(400).json({ "message": "rate not in range" })
        var requestedShop = await RequestedShop.findById(req.body.requestedshop)
        if(requestedShop.status != 4) return res.status(400).json("Sorry the delivery has not yet ended")
        if(requestedShop.deactivated == true) return res.status(400).json("Sorry the request has been deactivated")
        if (!requestedShop) return res.status(400).json({ "message": "invalid id" })
        if (!requestedShop.feedback) return res.status(400).json({ "message": "feedback not found" })
        var order = await Order.findById(requestedShop.order)
        if(order.deactivated == true) return res.status(400).json("Sorry the order has been deactivated")
        var user = await User.findById(order.user)
        if(user.deactivated == true) return res.status(400).json("Sorry the user has been deactivated")
        if(requestedShop.feedback.rating && requestedShop.feedback.rating.ratingByStaff ) return res.status(400).json("Sorry the order has already been rated")
        user.avgRating = (user.avgRating * user.raterCount + req.body.rate) / (user.raterCount + 1)
        user.raterCount = user.raterCount + 1
        user.ratingStar[req.body.rate - 1] = user.ratingStar[req.body.rate - 1] + 1
        await user.save()
        if(!requestedShop.feedback.rating) requestedShop.feedback.rating = Rating();
        requestedShop.feedback.rating.ratingByStaff = req.body.rate
        await requestedShop.save()
        SUS.emitRating(requestedShop._id, req.grant)
        return res.status(200).json("success")      
    }
    catch (e) {
        console.log(e)
        next(e)
    }

})


router.put("/reject", verifyToken([G.Grants.staff]), comprehendRole(OR.OrderRoles.receive), async(req, res, next) => {
    try{
        var rejectable = await RequestedShop.find({ order: req.body.order_id, staff: req.user.id })
        for (var i in rejectable) {
            if(rejectable[i].status != 0) return res.status(400).json({"message":"Could not take action on the request"})
            if(rejectable[i].status == -1) return res.status(400).json({"message":"Sorry the order was already rejected"})
            rejectable[i].status = -1
            await rejectable[i].save()
            SS.emitOrderReject(rejectable[i]._id, rejectable[i].staff, rejectable[i].order)
        }
        var remaining = await RequestedShop.findOne({ order: req.body.order_id, status: 0})
        if(!remaining) {
            var order = await Order.findById(req.body.order_id)
            if(!order) return res.status(400).json({"message":"Could not find the order"})
            ShopNearby.setInstantFailure(order, order.user)
        }
        return res.status(200).json("success")
    }
    catch(e){next(e)}
})



module.exports = router



