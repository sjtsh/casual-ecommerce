
const { default: mongoose } = require("mongoose");
const { Order, RequestedShop } = require("../models/order");
const { Shop } = require("../models/shop");
const { sendNotification } = require("../controllers/pushNotification");

const US = require("./userSocket")
const reg = require("./reg")
const OC = require("./onConnection");
const AS = require("./adminSocket");
const { Staff } = require("../models/admin");
const { User } = require("../models/user");

exports.emitOrderTimeOut = async(userID, orderID) =>{
    US.updateOrderUser(orderID, userID.toString(), -3)
}

exports.handleStamp = async (socket)=>{
    try{
        const stamp = async (data) => {
            var user = await User.findById(socket.user.id)
            user.lastLocation = data
            await user.save()
        }
        return stamp
    }catch(e){console.log(e)}
}


exports.verifyOTP = async(order, otp, requestedShop) => {
    if(!requestedShop.verificationOTP) return false
    if (requestedShop.verificationOTP == otp) {
        requestedShop.status = 4
        await requestedShop.save()
        US.updateRequestUser(requestedShop._id.toString(), order._id.toString(), order.user.toString(), 4)
        return true
    }
    return false
}

exports.emitDeliveryStarted = async(request) => {
    var order = await Order.findById(request.order)
    if (order) {
        this.emitOrNotifyUser(order.user.toString(), 'request_update', { 'order_id': order._id.toString(), 'request_id': request._id.toString(), "otp":request.verificationOTP, "status": 3}, order._id.toString(), 3, true, request._id.toString())
    }
}
exports.emitFeedbackComfirmationUser = async(order) => {
    US.updateOrderUser(order._id, order.user.toString(), 3, order.fulfilled)
}

exports.emitOrderProcessingStarted = async(orderID, userID, waitTime) => {
    US.updateOrderUser(orderID, userID.toString(), 2)
}
exports.emitOrderFailed = async(orderID, userID) => US.updateOrderUser(orderID, userID, 1)

exports.emitRequestCancelUser = async (requestID, orderID, userID)=> US.updateRequestUser(requestID, orderID, userID, -2)

exports.handleEndDelivery = async (socket) => {
    const handle = async (data) => {
        var requestedShop = await RequestedShop.findById(data)
        var order = await Order.findById(requestedShop.order)
        var staffObj = await Staff.findById(requestedShop.staff)
        var staff = await User.findById(staffObj.user)
        this.emitOrNotifyUser(order.user.toString(), 'end_delivery', { 'order_id': requestedShop.order.toString(), 'request_id': requestedShop._id.toString(), 'staff': staff.name, 'otp':requestedShop.verificationOTP},  requestedShop.order.toString(), "0", true, requestedShop._id.toString())
    }
    return handle
}

exports.updateOrderUser = async(order_id, user_id, newStatus, fulfilled) => {
    this.emitOrNotifyUser(user_id.toString(), 'order_update', { 'order_id': order_id, 'status': newStatus, 'fulfilled': fulfilled}, order_id, newStatus, false)
}
exports.updateRequestUser = async(request_id, order_id, user_id, newStatus) => {
    this.emitOrNotifyUser(user_id.toString(), 'request_update', { 'order_id': order_id, 'request_id': request_id, 'status': newStatus }, order_id, newStatus, true)
}


exports.emitOrNotifyUser = async(userID, emitGroup, emitMessage, order, status, isRequest, requestID) => {
    try{
    socketID = reg.userToSocket.get(userID)
    if (typeof emitMessage == Map) {
        emitMessage = JSON.stringify(emitMessage)
    }
    if (socketID) {
        OC.io.to(socketID).emit(emitGroup, emitMessage)
    } else {
        notifyListedUser(userID, order, status, isRequest, requestID)
    }
    AS.updateOrderById(emitMessage["order_id"])
    return socketID
}
    catch(e){console.log(e)}
}

const notifyListedUser = function(userID, orderID, status, isRequest, requestID) {
    try{
        sendNotification([], { device: true, title: "Notification", body: "Notification Body", userID: userID.toString(), image: "", notification: false, timeToLive: 0, order: orderID.toString(), status: status, isRequest: isRequest, request_id:  requestID})
    }
    catch(e){console.log(e)}
}