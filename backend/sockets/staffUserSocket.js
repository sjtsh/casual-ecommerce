
const { default: mongoose } = require("mongoose");
const { Order, RequestedShop } = require("../models/order");
const { User } = require("../models/user");
const { Shop } = require("../models/shop");
const { Grants } = require("../enums/grant");

const OC = require("./onConnection")
const US = require("./userSocket")
const AS = require("./adminSocket")
const SS = require("./staffSocket")
const reg = require("./reg");
const { Staff } = require("../models/admin");


exports.emitBannerUpdate =async(banner)=>{
    OC.io.in("banner").emit("banner",banner)
    AS.emitBanner(banner)
}


exports.emitProductDeactivatedStatus =async(product)=>{
    OC.io.emit("product",product)
}

exports.emitRating = async(requestedshop, grant) => {
    var requestedShop = await RequestedShop.findById(requestedshop)
    var order = await Order.findById(requestedShop.order)
    if(grant == Grants.staff) {
        var staff = await Staff.findById(requestedShop.staff)
        var user = await User.findById(order.user)
        return US.emitOrNotifyUser(order.user.toString(), 'rated', { 'order_id': order._id.toString(), 'request_id': requestedShop._id.toString(), "shop": staff.name, "avgRating": user.avgRating, "ratingByShop": requestedShop.feedback.rating.ratingByShop, "raterCount": user.raterCount  }, order._id, 0, false, requestedShop._id)
    }    
    SS.emitOrNotify({ userID: requestedShop.staff.toString(), shouldNotify: true, emitGroup: 'rated', emitMessage: {order: requestedShop.order }, order: requestedShop.order._id.toString() })
    return reg.staffToSocket.get(requestedShop.staff.toString())
}


exports.emitOrderCancelled = async(orderID, toShop, userID, staffID, bySystem) => {
    var emitGroup = "request_cancelled"
    var userID = userID.toString()
    if (toShop == false) {
        if (bySystem) US.updateOrderUser(orderID, userID, -3)
        else US.updateOrderUser(orderID, userID, -1)
        return
    } else userID = staffID
    if (bySystem) emitGroup = "order_cancelled_system"
    SS.emitOrNotify({ userID: userID, shouldNotify: true, isShop: true, emitGroup: emitGroup, emitMessage: orderID, order: orderID.toString() })
}



exports.emitSystemCancelled = async(request) => {
    var orderID = request.order
    var staff1 = request.staff
    var staff2 = request.feedback.deliveredBy
    var order = await Order.findById(orderID)
    if (order) US.updateRequestUser(request._id, orderID, order.user.toString(), -4)
    SS.emitOrNotify({ userID: staff1.toString(), shouldNotify: true, isShop: true, emitGroup: 'order_cancelled_system', emitMessage: orderID.toString(), order: orderID.toString()})
    return SS.emitOrNotify({ userID: staff2.toString(), shouldNotify: true, isShop: true, emitGroup: 'order_cancelled_system', emitMessage: orderID.toString(), order: orderID.toString()})
}


