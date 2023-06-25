const mongoose = require("mongoose")
const router = require("express").Router();
const {verifyToken} = require("../../controllers/verifyToken");
const { Order, SingularOrderFeedback, RequestedShop, Rating } = require("../../models/order");
const { Shop } = require("../../models/shop");
const { User } = require("../../models/user");
const onConnection = require("../../sockets/onConnection");
const { processOrder } = require("../../middleware/change_status");

router.put("/status/cancel", verifyToken(), async (req, res, next) => {
    try{
    var cancellable = await RequestedShop.findById(req.body.request_id)
    var order = await Order.findById(cancellable.order)
    if (req.user.id != order.user.toString()) {
        return res.status(403).json("Unauthorized request")
    }
    for (var j in cancellable.itemsAllocated) {
        order.total = order.total - cancellable.itemsAllocated[j].total
    }
    cancellable.status = -5
    cancellable.save()
    onConnection.emitRequestCancelled(order._id, cancellable.shop.toString())
    var requestedShops = await RequestedShop.find({ order: order._id, $or: [{ status: 2 }, { status: 3 }, { status: 4 }] })
    if (!requestedShops.length) {
        order.status = -1
        onConnection.emitOrderCancelled(order._id.toString(), false, order.user.toString(), "shopID", false)
    }
    await order.save()
    return res.status(200).json({ "status": -5 })
}
catch(e){next(e)}
})

router.get("/:id", async (req, res, next) => {
    try{
    return res.status(200).json(await onConnection.getRequestedShop(req.params.id))
}
catch(e){next(e)}
})
//{review: "review", rate: 4, requestedshop: "requestedshop"}

module.exports = router

