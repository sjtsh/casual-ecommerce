const mongoose = require("mongoose")
const router = require("express").Router();
const {verifyToken} = require("../../controllers/verifyToken");
const { Order, SingularOrderFeedback, RequestedShop, Rating } = require("../../models/order");
const { Shop } = require("../../models/shop");
const { User } = require("../../models/user");
const onConnection = require("../../sockets/onConnection");
const { processOrder } = require("../../middleware/change_status");
const G = require("../../enums/grant")
const SS = require("../../sockets/staffSocket");
const US = require("../../sockets/userSocket");
const SUS = require("../../sockets/staffUserSocket");
const { Staff } = require("../../models/admin");

router.get("/review/:id", verifyToken([G.Grants.user]),  async (req, res, next) => {
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

// router.put("/cancel",  verifyToken([G.Grants.user]),   async (req, res, next) => {
//     try{
//         var cancellable = await RequestedShop.findById(req.body.request_id)
//         var order = await Order.findById(cancellable.order)
//         if (req.user.id != order.user.toString()) return res.status(403).json("Unauthorized request")
//         for (var j in cancellable.itemsAllocated) {
//             order.total = order.total - cancellable.itemsAllocated[j].total
//         }
//         cancellable.status = -5
//         cancellable.save()
//         onConnection.emitRequestCancelled(order._id, cancellable.shop.toString())
//         var requestedShops = await RequestedShop.find({ order: order._id, $or: [{ status: 2 }, { status: 3 }, { status: 4 }] })
//         if (!requestedShops.length) {
//             order.status = -1
//             onConnection.emitOrderCancelled(order._id.toString(), false, order.user.toString(), "shopID", false)
//         }
//         await order.save()
//         return res.status(200).json({ "status": -5 })
//     }
//     catch(e){next(e)}
// })
//{review: "review", rate: 4, requestedshop: "requestedshop"}

router.put("/review/", verifyToken([G.Grants.user]),   async (req, res, next) => {
    try {
        if (req.user.grant != G.Grants.user) return res.status(400).json({ "message": "invalid request" })
        if (!req.body.requestedshop) return res.status(400).json({ "message": "requested shop not found" })
        if (!req.body.rate) return res.status(400).json({ "message": "rate not found" })
        if (!(req.body.rate >= 0 && req.body.rate <= 5)) return res.status(400).json({ "message": "rate not in range" })
        var requestedShop = await RequestedShop.findById(req.body.requestedshop)
        if (!requestedShop)return res.status(400).json({ "message": "invalid id" })
        if (!requestedShop.feedback) return res.status(400).json({ "message": "feedback not found" })
        var order = await Order.findById(requestedShop.order)
        var user = await User.findById(order.user)
        user.avgRating = (user.avgRating * user.raterCount + req.body.rate) / (user.raterCount + 1)
        user.raterCount = user.raterCount + 1
        user.ratingStar[req.body.rate - 1] = user.ratingStar[req.body.rate - 1] + 1
        await user.save()
        if(!requestedShop.feedback.rating) requestedShop.feedback.rating = Rating();
        requestedShop.feedback.rating.ratingByStaff = req.body.rate
        await requestedShop.save()
        SUS.emitRating(requestedShop._id,  req.user.isShop)
        return res.status(200).json({"message":"success"})       
    }
    catch (e) {
        console.log(e)
        next(e)
    }

})
module.exports = router

