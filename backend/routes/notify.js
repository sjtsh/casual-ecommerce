const e = require("express");
const mongoose = require("mongoose");
const { sendNotification } = require("../controllers/pushNotification");
const router = require("express").Router();
const { User } = require("../models/user");

router.get("/:id", async(req, res, next) => {
    try{
    // var tokens = []
    // var users = await User.aggregate([
    //     {$unwind: "$devices"}
    // ])
    // for(var i in users){
    //     tokens.push(users[i].devices.fcmToken)
    // }

    var img = "https://images.unsplash.com/photo-1541963463532-d68292c34b19?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxleHBsb3JlLWZlZWR8Mnx8fGVufDB8fHx8&auto=format&fit=crop&w=500&q=60"
    return await sendNotification([], { device: true, title: "Broadcast Message", body: "Testing our very own broadcast message", image: img, userID: req.params.id, res: res,order:"test order",timeToLive:1,notification:true })
}
catch(e){next(e)}
})
router.get("/message/:id", async(req, res, next) => {
    try{
    // var tokens = []
    // var users = await User.aggregate([
    //     {$unwind: "$devices"}
    // ])
    // for(var i in users){
    //     tokens.push(users[i].devices.fcmToken)
    // }

    var img = "https://images.unsplash.com/photo-1541963463532-d68292c34b19?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxleHBsb3JlLWZlZWR8Mnx8fGVufDB8fHx8&auto=format&fit=crop&w=500&q=60"
    return await sendNotification([], { device: true, title: "Broadcast Message", body: "Testing our very own broadcast message", image: img, userID: req.params.id, res: res, notification: false,order:"test order",timeToLive:1})
}
catch(e){next(e)}
})

module.exports = router