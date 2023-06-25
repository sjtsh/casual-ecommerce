const mongoose = require("mongoose")
const { autoIncrementID } = require("../middleware/autoIncrementFunction");
const CryptoJS = require("crypto-js");
// CryptoJS.AES = require("crypto-js/aes");
const {DeviceSchema} = require("./user");


const GeoSchema = mongoose.Schema({
    type: { type: String, default: "Point" },
    coordinates: [Number],
})

const AdditionalInfo = mongoose.Schema({
    pan: { type: String },
})

const TimingInfoDetail = mongoose.Schema({
    hour: {type: Number},
    minute: {type: Number},
})

const TimingInfo = mongoose.Schema({
    start: TimingInfoDetail,
    end: TimingInfoDetail,
    closedOn: [{type: Number}],
})

const ImageWithLabel = mongoose.Schema({
    label: {type: String},
    url: {type: String}
})

const Shop = mongoose.Schema({
    id: { type: String },
    documents: [ImageWithLabel],
    img: [String],
    address: { type: String, },
    name: { type: String, required: ["name is required", true] },
    owner: {type: String},
    phone: { type: String, required: ["phone number is required", true] },
    info: AdditionalInfo,
    location: { type: GeoSchema, required: ["Location point is required", true], index: "2dsphere" },
    deliveryRadius: { type: Number, default: 3000 },
    approved: {type: Boolean, default: false},
    deactivated: {type: Boolean, default: false},
    timing: TimingInfo,
}, { timestamps: true })

Shop.index({ location: '2dsphere' })
Shop.index({ name: 'text', id: 'text',phone: 'text', owner: 'text', address: 'text' })

Shop.pre('save', async function(next) {
    if (this.isModified('createdAt')) {
        this.id = await autoIncrementID("shop")
    }
    next()
})
module.exports = { Shop: mongoose.model("Shop", Shop) }