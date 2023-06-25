const mongoose = require("mongoose")
const {autoIncrementID} = require("../middleware/autoIncrementFunction");


const CartItem = mongoose.Schema({
    product: {type: mongoose.Types.ObjectId, required: ["SKU is required", true], ref: "Product"},
    qty: {type: Number, required: ["Quantity is required", true]},
    price: {type: Number, required: ["Price is required", true]},
    deactivated: {type: Boolean, default: false}
}, {timestamps: true})

CartItem.pre('save',async function (next) {
    if (this.isModified('createdAt')) {
        this.id = await autoIncrementID("cart_item")
    }
    next()
})

const Cart = mongoose.Schema({
    id: { type: String },
    items: [CartItem],
    deactivated: {type: Boolean, default: false}
}, {timestamps: true})

Cart.pre('save',async function (next) {
    if (this.isModified('createdAt')) {
        this.id = await autoIncrementID("cart")
    }
    next()
})

Cart.index({ id: 'text' })

module.exports = {Cart: mongoose.model("Cart", Cart), CartItem: mongoose.model("CartItem", CartItem)}