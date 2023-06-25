const mongoose = require("mongoose")
const {autoIncrementID} = require("../middleware/autoIncrementFunction");


const DeliverRequest = mongoose.Schema({
    id: { type: String },
    name: { type: String },
    success: { type: Boolean },
    deactivated: {type: Boolean, default: false}
}, { timestamps: true })


DeliverRequest.pre('save',async function (next) {
    if (this.isModified('createdAt')) {
        this.id = await autoIncrementID("deliver_request")
    }
    next()
})

DeliverRequest.index({ id: 'text' })

module.exports = {DeliverRequest: mongoose.model("DeliverRequest", DeliverRequest)}