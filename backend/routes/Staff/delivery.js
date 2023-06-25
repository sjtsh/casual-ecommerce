const mongoose = require("mongoose")
const router = require("express").Router()
const {verifyToken, comprehendRole, authorityForDelivery} = require("../../controllers/verifyToken")
const { Order, SingularOrderFeedback, RequestedShop, Rating } = require("../../models/order")
const { Shop } = require("../../models/shop")
const { User } = require("../../models/user")
const onConnection = require("../../sockets/onConnection")
const { OrderItem } = require("../../models/order")
const ShopNearby = require("../../middleware/shop_nearby")
const { findById } = require("../../models/shop")
const { verify } = require("jsonwebtoken")
const CS = require("../../middleware/change_status")
const G = require("../../enums/grant")
const OR = require("../../enums/outletRole")
const { getPersonalRequestedShop, getPersonalOrderForDeliveryNew } = require("../../middleware/serialization/serialization")
const SS = require("../../sockets/staffSocket")
const US = require("../../sockets/userSocket")
const SUS = require("../../sockets/staffUserSocket");
const { Staff } = require("../../models/admin")
const { agenda, processTime } = require("../../jobs/agenda")
const { ProductItem } = require("../../models/productItem")

const Serialization = require("../../middleware/serialization/serialization")
const { Product } = require("../../models/product")
const { SubCategory } = require("../../models/category")

router.get("/new", verifyToken([G.Grants.staff]), comprehendRole(OR.DeliveryRoles.delivery),  async(req, res, next) => {
    try {
        const staff = await Staff.findById(req.user.id)
        const shop = await Shop.findById(staff.shop)
        if(staff.deactivated == true) return res.status(411).json({"message":"Sorry the shop has been deactivated"})
        var deliveryRadius = 1000
        if (shop.deliveryRadius && shop.deliveryRadius != null) deliveryRadius = shop.deliveryRadius
        var requestsToBeDelivered = await RequestedShop.aggregate(Serialization.pipeline(shop._id,staff._id))
        var responseWorth = []
        for (var i in requestsToBeDelivered) {
            var responseWorthy = await getPersonalOrderForDeliveryNew(requestsToBeDelivered[i].order, Serialization.pipeline(shop._id,staff._id))
            if(responseWorthy) responseWorth.push(responseWorthy)
        }
        return res.status(200).json(responseWorth)
    } catch (e) {
        next(e)
    }

})

router.put("/accept/:id", verifyToken([G.Grants.staff]), comprehendRole(OR.DeliveryRoles.delivery), async (req, res, next) => {
    try{    
        var requestedShop = await RequestedShop.findById(req.params.id)
        if(requestedShop.feedback && requestedShop.feedback.deliveredBy) return res.status(400).json({"message":"Sorry someone else already accepted it"})
        if(!requestedShop) return res.status(400).json("Sorry the request does not exist")
        if(requestedShop.deactivated == true) return res.status(400).json("Sorry the request has been deactivated")
        if(!req.body.deliveryTime) return res.status(400).json("Please allocate a delivery time")
        if(req.body.deliveryCharge != 0 && !req.body.deliveryCharge) return res.status(400).json("Please allocate a delivery charge")
        var order = await Order.findById(requestedShop.order)
        if(order.deactivated == true) return res.status(400).json("Sorry the order has been deactivated")
        requestedShop.feedback.deliveredBy = req.user.id
        requestedShop.feedback.deliveryTime = req.body.deliveryTime
        requestedShop.feedback.deliveryCharge = req.body.deliveryCharge
        requestedShop.feedback.deliveryAcceptedAt = new Date()
        await requestedShop.save()
        await SS.emitDeliveryAccepted(requestedShop.staff, requestedShop)
        await emitMisses(req.user.id, requestedShop)
        
        var emergencyWaitTime = requestedShop.feedback.deliveryTime * 60000
        agenda.schedule(processTime(emergencyWaitTime), "notifyAsEmergency", { "requestForId": requestedShop })

        var respons = await getPersonalRequestedShop(requestedShop)
        return res.status(200).json(respons)
    }
    catch(e){next(e)}//641ffd903d00d263aa656c2e
})

router.put("/reject/:id", verifyToken([G.Grants.staff]), comprehendRole(OR.DeliveryRoles.delivery), async(req, res, next) => {
    try{
        var staff = await Staff.findById(req.user.id)
        var rejectable = await RequestedShop.findOne({status: 2, shop: staff.shop, order: req.params.id})
        if(!rejectable)return res.status(400).json({"message":"Could not take find the request"})
        if(rejectable.status != 2) return res.status(400).json({"message":"Could not take action on the request"})
        // if(rejectable.feedback.deliveredRejections.includes(req.user.id)) return res.status(400).json({"message":"Sorry the order was already rejected"})
        rejectable.feedback.deliveryRejections.push(mongoose.Types.ObjectId(req.user.id))
        await rejectable.save()
        SS.emitDeliveryReject(rejectable._id, rejectable.staff, rejectable.order)
        var remaining = await CS.findDeliveryStaffs(rejectable.shop)
        if(rejectable.feedback.deliveryRejections.length == remaining.length) {
            var order = await Order.findById(rejectable.order)
            ShopNearby.setInstantFailure(order, order.user)
            SS.emitOrderFailed(rejectable, rejectable.staff)
        }
        return res.status(200).json("success")
    }
    catch(e){next(e)}
})

const emitMisses = async  (userID, request)=>{
    
    var remaining = await CS.findDeliveryStaffs(request.shop)
    var rejectedIds = []
    for(var i in request.feedback.deliveryRejections){
        rejectedIds.push(request.feedback.deliveryRejections[i].toString())
    }
    var deliveryMisses = []
    for(var i in remaining) {
        if(remaining[i].id.toString() != userID.toString() && !rejectedIds.includes(remaining[i].id.toString())){
            deliveryMisses.push(remaining[i]._id)
            SS.emitDeliveryMissed(request, remaining[i]._id)
        }
    }
    request.feedback.deliveryMisses = deliveryMisses
    await request.save()
}

//{'order_id': Order ID}
router.put("/status/3",  verifyToken([G.Grants.staff]), authorityForDelivery("request_id"), async(req, res, next) => {
    try{
        var requestedShop = await RequestedShop.findById(req.body.request_id)
        if(!requestedShop) return res.status(400).json("Sorry could not find the request")
        if(requestedShop.feedback.deliveredBy.toString() != req.user.id.toString()) return res.status(400).json("Sorry the request is not assigned to you")
        if(requestedShop.deactivated == true) return res.status(400).json("Sorry the request has been deactivated")
        requestedShop.status = 3
        var verificationOTP = Math.floor(Math.random() * 90000 + 10000)
        if(process.env.ISPRODUCTION === "false") verificationOTP = 11111
        requestedShop.verificationOTP = verificationOTP
        requestedShop.feedback.startDeliveryTime = new Date()
        requestedShop.feedback.referenceImages = req.body.images
        requestedShop.feedback.bill = req.body.bill
        requestedShop.feedback.billNumber = req.body.billNumber
        await requestedShop.save()

        if (requestedShop.feedback) {
            await US.emitDeliveryStarted(requestedShop)
            await SS.emitDeliveryStarted(requestedShop)
            // var requestedShops = await RequestedShop.find({ order: requestedShop.order, status: 2})
            // if(!requestedShops.length){
                var order = await Order.findById(requestedShop.order)
                order.status = 4
                await order.save()
                US.updateOrderUser(order._id.toString(), order.user.toString(), 4) 
            // }
        }
        return res.status(200).json("success")
    }
    catch(e)
    {next(e)}
})

//{'order_id': Order ID, 'otp': OTP Code}
router.put("/status/4",  verifyToken([G.Grants.staff]), authorityForDelivery("request_id"), async(req, res, next) => {
    try{
        var requestedShop = await RequestedShop.findById(req.body.request_id)
        if(!requestedShop) return res.status(400).json("Sorry could not find the request")
        if(requestedShop.feedback.deliveredBy.toString() != req.user.id.toString()) return res.status(400).json("Sorry the request is not assigned to you")
        if(requestedShop.deactivated == true) return res.status(400).json("Sorry the request has been deactivated")
        if(requestedShop.status != 3) return res.status(411).json({"message":"The request has already timed out"})
        var order = await Order.findById(requestedShop.order)
        var success = await US.verifyOTP(order, req.body.otp, requestedShop)
        if (success) {
            requestedShop.status = 4
            requestedShop.feedback.otpDeliveryTime = new Date()
            await requestedShop.save()
            
            //needs to be after saving the requestedshop
            for(var i in requestedShop.feedback.itemsAllocated){
                var item = requestedShop.feedback.itemsAllocated[i]
                var prodObj = await Product.findById( item.product)
                var subObj = await SubCategory.findById( prodObj.category)
                var prod = ProductItem({item_count: item.item_count, total: item.total, product: item.product, order: requestedShop.order, category: subObj.category, subcategory: subObj._id, master: prodObj.master})
                await prod.save()
            }
            //----------------------------------------------
            await SS.emitDeliveryEnded(requestedShop)
            // var requestedShops = await RequestedShop.find({ order: requestedShop.order,  $or: [{status: 2}, {status: 3}]})
            // if(!requestedShops.length){
                order.status = 5
                await order.save()
                US.updateOrderUser(order._id.toString(), order.user.toString(), 5) 
            // }
            return res.status(200).json("success")
        }
        return res.status(207).json("denied")}
    catch(e){next(e)}
})

module.exports = router



