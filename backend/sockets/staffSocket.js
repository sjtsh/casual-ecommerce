const { default: mongoose } = require("mongoose");

const reg = require("./reg")
const Serialization = require("../middleware/serialization/serialization")
const { Order } = require("../models/order");
const { sendNotification } = require("../controllers/pushNotification")
const OC = require("./onConnection")

const SS = require("./staffSocket");
const DV= require("../routes/Staff/delivery");
const { Staff } = require("../models/admin");

// exports.emitRequestCancelled = async(order_id, shop_id) => {
//     emitOrNotify({ userID: shop_id.toString(), shouldNotify: true, isShop: true, emitGroup: 'request_cancelled', emitMessage: order_id, order: order_id.toString() })
// }

exports.handleStamp = async (socket)=>{
    try{
        const stamp = async (data) => {
            var staff = await Staff.findById(socket.user.id)
            staff.lastLocation = data
            await staff.save()
        }
        return stamp
    }catch(e){console.log(e)}
}

exports.emitRequestCancelledByStaff = async(order_id, staff) => {
    SS.emitOrNotify({ userID: staff.toString(), shouldNotify: true, isShop: true, emitGroup: 'request_cancelled_by_staff', emitMessage: order_id, order: order_id.toString() })
}

exports.emitOrderFailed = async(request, user) =>{
    if(!user) user = request.staff
    SS.emitOrNotify({ userID: user.toString(), shouldNotify: true, isShop: true, emitGroup: 'order_failed', emitMessage: request.order.toString(), order: request.order.toString()})
}

exports.emitDeliveryReject = async(requestID, staffID, orderID) => SS.emitOrNotify({ userID: staffID.toString(), shouldNotify: true, emitGroup: 'delivery_reject', emitMessage: orderID.toString(), timeToLive: 120000, order: orderID.toString() })

exports.emitDeliveryMissed = async(request, userID) => {
    SS.emitOrNotify({ userID: userID.toString(), shouldNotify: true, isShop: true, emitGroup: 'delivery_missed', emitMessage: { "order": request.order, }, order: request.order.toString()})
}

exports.emitDeliveryAccepted = async(userID, request) => {
    SS.emitOrNotify({ userID: userID.toString(), shouldNotify: true, isShop: true, emitGroup: 'delivery_accepted', emitMessage: { "order": request.order, "deliveredBy": request.feedback.deliveredBy, }, order: request.order.toString()})
}

exports.emitDeliveryStarted = async( request) => {
    SS.emitOrNotify({ userID: request.staff.toString(), shouldNotify: true, isShop: true, emitGroup: 'delivery_started', emitMessage: request.order.toString(), order: request.order.toString()})
}

exports.emitDeliveryEnded = async( request) => {
    SS.emitOrNotify({ userID: request.staff.toString(), shouldNotify: true, isShop: true, emitGroup: 'delivery_ended', emitMessage: request.order.toString(), order: request.order.toString()})
}

exports.emitDeliveryRequest = async(request, staff)=>{
    var order = await Serialization.getPersonalOrderForDeliveryNew(request.order, Serialization.pipeline(request.shop, staff._id))
    SS.emitOrNotify({ userID: staff._id.toString(), shouldNotify: true, isShop: true, emitGroup: 'delivery_request', emitMessage: order, order: request.order.toString() })
}

exports.emitFeedbackMissed = async(request) => {
    var order = await Order.findById(request.order)
    SS.emitOrNotify({ userID: request.staff.toString(), shouldNotify: true, isShop: true, emitGroup: 'feedback_missed', emitMessage: { "order": request.order, }, order: request.order.toString(), displayId: order.id.toString()  })
}

exports.emitFeedbackDisregard = async(request) => {
    SS.emitOrNotify({ userID: request.staff.toString(), shouldNotify: true, isShop: true, emitGroup: 'feedback_disregard', emitMessage: { "selectedRequest": request._id.toString(), "request": request, }, order: request.order.toString() })
}

exports.emitFeedbackComfirmationShop = async(requestedShop) => {
    var r = await Serialization.getPersonalRequestedShop(requestedShop)
    SS.emitOrNotify({ userID: requestedShop.staff.toString(), shouldNotify: true, isShop: true, emitGroup: 'feedback_confirmation', emitMessage: r, order: requestedShop.order.toString() })
}

exports.notifyUrgency = async(request) => {
    SS.emitOrNotify({ userID: request.staff.toString(), shouldNotify: true, isShop: true, emitGroup: "notify_urgency", emitMessage: request.order.toString(), order: request.order.toString() })
}

exports.emitOrderReject = async(requestID, staffID, orderID) => SS.emitOrNotify({ userID: staffID.toString(), shouldNotify: true, emitGroup: 'order_reject', emitMessage: orderID.toString(), timeToLive: 120000, order: orderID.toString() })

exports.emitOrderRequest = async(staffID, order) => {
    if(!order.waitTime) order.waitTime = 120000
    SS.emitOrNotify({ userID: staffID.toString(), shouldNotify: true, emitGroup: 'order_request', emitMessage: {...order,  "requestedShop": await order.requestedShop }, timeToLive: order.waitTime, order: order._id.toString() })
    return reg.staffToSocket.get(staffID.toString())
}

exports.emitOrNotify = async({ userID, shouldNotify, isShop, emitGroup, emitMessage, timeToLive, body, title, order,  }) => {
    var notify = false
    var socketID = reg.staffToSocket.get(userID)
    if (socketID) {
        OC.io.to(socketID).emit(emitGroup, emitMessage)
        if(emitGroup == "order_request" || emitGroup == "delivery_request" ) return
    }
    if (shouldNotify) {
        notifyListed(emitGroup, userID, { life: timeToLive, body: body, title: title, order: order, notification: notify})
    }
}

const notifyListed = function(emitGroup, userID, { life, body, title, order, notification = false }) {
    var titleDefault = "Notification"
    var bodyDefault = "Notification Body"
    var timeToLive = 0
    switch (emitGroup) {
        case "otp_verification":
            titleDefault = "OTP Verified"
            bodyDefault = "The otp is verified"
            break
        case "delivery_started":
            titleDefault = "Delivery Started"
            bodyDefault = "The delivery has started"
            break
        case "order_processing":
            titleDefault = "Order Processed"
            bodyDefault = "The order has started to be processed"
            break
        case "feedback_disregard":
            titleDefault = "Bid Disregarded"
            bodyDefault = "Your bid was disregarded"
            break
        case "feedback_confirmation":
            titleDefault = "Bid Confirmed"
            bodyDefault = "Your bid has been confirmed"
            break
        case "request_cancelled":
            titleDefault = "Order Cancelled"
            bodyDefault = "The order has been cancelled"
            break
        case "order_failed":
            titleDefault = "Order Failed"
            bodyDefault = "No shops are available at the moment"
            break
        case "order_request":
            timeToLive = life
            titleDefault = "Order Request"
            bodyDefault = "A order has been recieved"
            break
        case "delivery_request":
            titleDefault = "Delivery Request"
            bodyDefault = "A delivery request has been recieved"
            break
        case "notify_urgency":
            titleDefault = "Order expiry is near"
            bodyDefault = "The order expires is 10 minutes"
            break
        case "order_cancelled_system":
            titleDefault = "Order expired"
            bodyDefault = "The order has expired"
            break
        case "rated":
            titleDefault = "You have been rated"
            bodyDefault = "You have got a new rating"
            break
        case "feedback_missed":
            titleDefault = "Order Missed"
            bodyDefault = "The order has been missed"
            break
        case "delivery_missed":
            titleDefault = "Delivery Missed"
            bodyDefault = "The delivery request has been missed"
            break
        case "order_reject":
            titleDefault = "Order Rejected"
            bodyDefault = "The order has been rejected"
            break
        case "delivery_reject":
            titleDefault = "Delivery Rejected"
            bodyDefault = "The delivery has been rejected"
            break
        case "delivery_accepted":
            titleDefault = "Delivery Accepted"
            bodyDefault = "The delivery request has been accepted"
            break
        case "delivery_ended":
            titleDefault = "Delivery Ended"
            bodyDefault = "The delivery has ended"
            break
        case "request_cancelled_by_staff":
            titleDefault = "Order cancelled"
            bodyDefault = "The order has been cancelled by a staff"
            break
    }
    if (body) bodyDefault = body
    if (title) titleDefault = title
    if(titleDefault == "Notification") console.log("please add", emitGroup, "into the notification switch case")
    // if(titleDefault == "Delivery Request") console.log("delivery request notification sent")
    sendNotification([], { device: true, title: titleDefault, body: bodyDefault, userID: userID, image: "", notification: notification, timeToLive: timeToLive, order: order})
}


