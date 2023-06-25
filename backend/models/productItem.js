const mongoose = require("mongoose");
const { autoIncrementID } = require("../middleware/autoIncrementFunction");

const ProductItem = mongoose.Schema({
    item_count: { type: Number },
    total: { type: Number },
    product: { type: mongoose.Types.ObjectId, ref: "Product" },
    subcategory: { type: mongoose.Types.ObjectId, ref: "Subcategory" },
    category: { type: mongoose.Types.ObjectId, ref: "Category" },
    master: { type: mongoose.Types.ObjectId, ref: "MasterProduct" },
    order: { type: mongoose.Types.ObjectId, ref: "Order" },
}, { timestamps: true })

module.exports = { ProductItem: mongoose.model("ProductItem", ProductItem)}