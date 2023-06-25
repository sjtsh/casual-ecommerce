const mongoose = require("mongoose")
const Grants = require("../enums/grant")
//owners name
//phone number
//password
const NotifyPage = mongoose.Schema({
    admin: {type: mongoose.Types.ObjectId},
    socket: {type: String, index: {unique: true}},
    grant: {type: String, enum: Grants.all},
    orders: [{type: mongoose.Types.ObjectId, ref: "Order"}],
    customers: [{type: mongoose.Types.ObjectId, ref: "User"}]
})

module.exports = { NotifyPage: mongoose.model("NotifyPage", NotifyPage) }

