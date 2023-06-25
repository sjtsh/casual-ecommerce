const mongoose = require("mongoose")
const CryptoJS = require("crypto-js")
const { autoIncrementID } = require("../middleware/autoIncrementFunction")
const Grant = require("../enums/grant");

const GeoSchemaWithStamp = mongoose.Schema({
    type: { type: String, default: "Point" },
    coordinates: [Number],
}, { timestamps: true })

const GeoSchema = mongoose.Schema({
    type: { type: String, default: "Point" },
    coordinates: [Number],
    deactivated: {type: Boolean, default: false}
})

const Address = mongoose.Schema({
    fullName: { type: String, required: ["Full name is required", true] },
    phone: { type: String, required: ["Phone is required", true] },
    address: { type: String, required: ["Address is required", true] },
    fullAddress: { type: String, required: ["FullAddress is required", true] },
    label: { type: String, required: ["Label is required", true] },
    location: { type: GeoSchema, required: ["Location is required", true] },
    deactivated: {type: Boolean, default: false}
})

const Device = mongoose.Schema({
    os: { type: String, },
    version: { type: String, required: ["FCM Token is required", true] },
    deviceId: { type: String },
    fcmToken: { type: String, required: ["FCM Token is required", true] },
    notify: { type: Boolean, default: true },
}, { timestamps: true })

const Favourites =mongoose.Schema({
    products:[{type: mongoose.Types.ObjectId, ref: "Product"}],
    categories:[{type: mongoose.Types.ObjectId, ref: "Category"}],
    deactivated: {type: Boolean, default: false}
})

const User = mongoose.Schema({
    id: { type: String },
    name: { type: String, required: ["name is required", true] },
    countryCode :{type: String, default: "+977" },
    phone: { type: String, require: ["phone number is required", true] },
    password: { type: String, require: ["password is required", true] },
    address: [Address],
    devices: [Device],
    favourites:Favourites,
    avgRating: {type: Number,  default: 0},
    raterCount: {type: Number, default: 0},
    ratingStar: {type:Array, default: [0,0,0,0,0]}, 
    deactivated: {type: Boolean, default: false},
    lastConnected: Date,
    lastDisconnected: Date,
    lastLocation: GeoSchemaWithStamp,
    // cart: {type: mongoose.Types.ObjectId, ref: "Cart"}
}, { timestamps: true })



User.pre('save', async function(next) {
    if (this.isModified('createdAt')) {
        this.id = await autoIncrementID("user")
    }
    next()
})

User.index({ id: 'text',  name: 'text', phone: 'text', countryCode: 'text' });

module.exports = { User: mongoose.model("User", User), Address: mongoose.model("Address", Address), Device: mongoose.model("Device", Device), DeviceSchema: Device, AddressSchema: Address }