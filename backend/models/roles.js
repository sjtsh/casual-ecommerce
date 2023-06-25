const mongoose = require("mongoose")
const CryptoJS = require("crypto-js")
const { autoIncrementID } = require("../middleware/autoIncrementFunction")
const Grant = require("../enums/grant");
const DR = require("../enums/dashboardRole");


const Role = mongoose.Schema({
    id: { type: String },
    label: { type: String, index: {unique: true},},
    roles:[{type: String, enum: DR.allSubs}],
    deactivated: {type: Boolean, default: false}
    // cart: {type: mongoose.Types.ObjectId, ref: "Cart"}
}, { timestamps: true })


Role.pre('save', async function(next) {
    if (this.isModified('createdAt')) {
        this.id = await autoIncrementID("user")
    }
    next()
})

Role.index({ id: 'text',  name: 'text', label: 'text'});

module.exports = { Role: mongoose.model("Role", Role)}