const mongoose = require("mongoose")


const Values = mongoose.Schema({
    key: {type: String},
    value: {type: String},
}, {timestamps: true})

module.exports = { Values: mongoose.model("Values", Values) }