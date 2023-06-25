const admin = require("../controllers/firebaseAdmin");

var { User } = require("../models/user");
var { Shop } = require("../models/shop");
const { Order } = require("../models/order");
const { urlencoded } = require("express");
const { Staff } = require("../models/admin");

async function sendNotification(topicOrDevice, { device = true, title, body, image, sound = "default", notification = false, userID, res, timeToLive, order, status, isRequest, request_id, displayId }) {
    try {
        var progress = false;

        var data = { notification: {title: title,body: body,image: image,sound: sound},data: {"order": order}}
        var properties = {
            // Required for background/quit data-only messages on iOS
            contentAvailable: true,
            // Required for background/quit data-only messages on Android
            priority: "high",
            timeToLive: timeToLive
        }
        if (!notification){
            data = { data: { title: title, body: body, image: image, "order": order} }
            if((status != null || status) && (isRequest != null || isRequest)){
                if(request_id != null || request_id) data = { data: { title: title, body: body, image: image, "order_id": order, "isRequest": isRequest.toString(), "status":status.toString(), request_id: request_id.toString(),} }
                else data = { data: { title: title, body: body, image: image, "order_id": order, "isRequest": isRequest.toString(), "status":status.toString(),} }
            }
        }
        if (timeToLive) properties = {contentAvailable: true,priority: "high",timeToLive: timeToLive}
        if (device) {
            var user = await User.findById(userID)
            if (!user) {
                user = await Staff.findById(userID)
                var orderObj = await Order.findById(order)
                if(user){
                    var date = new Date(orderObj.createdAt)
                    data.data.createdAt = date.toISOString()
                    data.data.displayId = orderObj.id.toString()
                }
            }
            if (user && user.devices.length) {
                topicOrDevice = [] /// get user tokens from devices where notifications are on
                for (var i in user.devices) {
                    if (user.devices[i].notify == true) topicOrDevice.push(user.devices[i].fcmToken)
                }
                if (topicOrDevice.length) {
                    progress = await admin.messaging().sendToDevice(topicOrDevice, data, properties)
                    // if(progress.results[0].error) console.log(progress.results[0].error)
                }
            } else return false
        } else progress = await admin.messaging().sendToTopic(topicOrDevice, data, properties)
       
        if (res) {
            if (progress) return res.status(200).json("success")
            else return res.status(201).json("unsuccessful")
        }
        if (progress) return true
        else return false
    } catch (err) {
        if (res)  return res.status(401).json(err)
        return false
    }
}

async function subscribeToTopic(tokens, topic) {
    if (!tokens || !topic)
        return false;
    return await admin.messaging().subscribeToTopic(tokens, topic);
}

module.exports = {
    sendNotification,
    subscribeToTopic
};