const mongoose = require("mongoose")


const DeliveryRequest = mongoose.Schema({
    id: { type: String },
    name: {type:String},
    deactivated: {type: Boolean, default: false}
}, { timestamps: true })

DeliveryRequest.pre('save',async function (next) {
    if (this.isModified('createdAt')) {
        this.id = await autoIncrementID("delivery_request")
    }
    next()
})

DeliveryRequest.index({ id: 'text' })

module.exports =  {DeliveryRequest: mongoose.model("DeliveryRequest", DeliveryRequest)}