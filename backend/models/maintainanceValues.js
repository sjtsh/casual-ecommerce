const mongoose = require("mongoose")


const MaintainanceValues = mongoose.Schema({
    key: {type: String},
    when: {type: Date},
    howLong: {type: Number},
}, {timestamps: true})

module.exports = { MaintainanceValues: mongoose.model("MaintainanceValues", MaintainanceValues) }