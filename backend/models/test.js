const mongoose = require("mongoose")
const CryptoJS = require("crypto-js")
const {autoIncrementID} = require("../middleware/autoIncrementFunction")


const Test = mongoose.Schema({
    name: String
})



module.exports =  {Test: mongoose.model("Test", Test)}