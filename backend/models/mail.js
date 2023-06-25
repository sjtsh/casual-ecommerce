const mongoose = require("mongoose")

//owners name
//phone number
//password
const Mail = mongoose.Schema({
    name: String,
    phone: String,
    email: String,
    message: String
}, { timestamps: true })


module.exports = { Mail: mongoose.model("Mail", Mail) }

