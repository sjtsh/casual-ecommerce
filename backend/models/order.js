const mongoose = require("mongoose")
const { autoIncrementID } = require("../middleware/autoIncrementFunction");
const V = require('../middleware/values')
const { AddressSchema } = require("./user")


const GeoSchema = mongoose.Schema({
    type: { type: String, default: "Point" },
    coordinates: [Number],
})

const OrderItem = mongoose.Schema({
    item_count: { type: Number },
    total: { type: Number },
    product: { type: mongoose.Types.ObjectId, ref: "Product" },
    margin: {type: Number},
    return: {type: Number},
    deactivated: {type: Boolean, default: false}
}, { timestamps: true })

const Rating = mongoose.Schema({
    ratingByUser: { type: Number },
    ratingByStaff: { type: Number },
    reviewByUser: { type: String },
    user: { type: mongoose.Types.ObjectId, ref: "User", },
    deactivated: {type: Boolean, default: false}
}, { timestamps: true })

const SingularOrderFeedback = mongoose.Schema({
    id: { type: String },
    deliveryTime: { type: Number },
    deliveryCharge: { type: Number },
    items: [OrderItem],
    itemsAllocated: [OrderItem],
    rating: Rating,
    createdAt: {type: Date},
    deliveryAcceptedAt: {type:Date},
    startDeliveryTime: { type: Date },
    otpDeliveryTime: { type: Date },
    deactivated: {type: Boolean, default: false},
    deliveredBy: { type: mongoose.Types.ObjectId, ref: "Staff"},
    deliveryRejections: [{type: mongoose.Types.ObjectId, ref: "Staff"}],
    deliveryMisses: [{type: mongoose.Types.ObjectId, ref: "Staff"}],
    referenceImages: [String],
    bill: String,
    billNumber: String
})

SingularOrderFeedback.index({ id: 'text' })

const RequestedShop = mongoose.Schema({
    order: { type: mongoose.Types.ObjectId, ref: "Order", required: ["Order is required", true] },
    staff: { type: mongoose.Types.ObjectId, ref: "Staff", required: ["Staff is required", true] },
    shop: { type: mongoose.Types.ObjectId, ref: "Shop", required: ["Shop is required", true] },
    distance: { type: Number},
    feedback: SingularOrderFeedback,
    itemsAble: [OrderItem],
    status: { type: Number, default: 0 },
    verificationOTP: { type: Number },
    selectAt: { type: Date },
    deactivated: {type: Boolean, default: false},
    //-5 => cancelled by user, 
    //-4 => cancelled by timeout, 
    //-3 => allocated to another shop by system, 
    //-2 => cancelled by shop, 
    //-1 => rejected by shop, 
    //0 => requested to shop, 
    //1 => feedback recieved by system, 
    //2 => selected by system,  
    //3 => delivery has been started, 
    //4 => delivery has been ended
}, { timestamps: true })


const ValuesModel = mongoose.Schema({
    deliveryCost: { type: Number},
    failAfter: {type: Number},
    failDeliveryRequestAfter: {type: Number},
    cancellationWaitTime: {type: Number},
    possibleDeliveryTime: {type: String}
})

ValuesModel.pre('save', async function (next) {
    if (this.isModified('createdAt')) {
        var dataMap = await V.get()
        this.deliveryCost = parseInt(dataMap.get("deliveryCost"))
        this.failAfter = parseInt(dataMap.get("failAfter"))
        this.failDeliveryRequestAfter = parseInt(dataMap.get("failDeliveryRequestAfter"))
        this.cancellationWaitTime = parseInt(dataMap.get("cancellationWaitTime"))
        this.possibleDeliveryTime = dataMap.get("possibleDeliveryTime")
    }
    next()
})

//-3 -> cancelled by timeout
//-2 -> cancelled by user
//-1 -> cancelled by shop
// 0 -> new order
// 1 -> failed when no shops are requested
// 2 -> when open to feedbacks
// 3 -> when feedback has been selected
// 4 -> when delivery has been started
// 5 -> when delivery has been completed

const Order = mongoose.Schema({
    id: { type: String },
    status: { type: Number, default: 0 },
    shop: { type: mongoose.Types.ObjectId, ref: "Shop", required: ["Shop is required", true] },
    user: { type: mongoose.Types.ObjectId, ref: "User", required: ["User is required", true] },
    total: { type: Number, required: ["Total is required", true] },
    location: {
        type: GeoSchema,
        required: ["Location point is required", true]
    },
    address: { type: AddressSchema, required: ["Address is required", true] },
    waitTime: { type: Number },
    items: [OrderItem],
    itemsAll: [OrderItem],
    allOrNone: { type: Boolean, default: false },
    remarks: String,
    fulfilled: {type:Boolean, default: true},
    deactivated: {type: Boolean, default: false},
    values: ValuesModel,
}, { timestamps: true })


Order.index({ id: 'text' })

Order.index({ location: '2dsphere' });

Order.pre('save', async function (next) {
    if (this.isModified('createdAt')) {
        this.id = await autoIncrementID("order")
    }
    next()
})


module.exports = { Order: mongoose.model("Order", Order),Rating:mongoose.model("Rating",Rating), SingularOrderFeedback: mongoose.model("SingularOrderFeedback", SingularOrderFeedback), OrderItem: mongoose.model("OrderItem", OrderItem), RequestedShop: mongoose.model("RequestedShop", RequestedShop) }