const mongoose = require("mongoose")
const CryptoJS = require("crypto-js")
const { autoIncrementID } = require("../middleware/autoIncrementFunction")
const  OR = require("../enums/outletRole")
const DR = require("../enums/dashboardRole");

const GeoSchemaWithStamp = mongoose.Schema({
    type: { type: String, default: "Point" },
    coordinates: [Number],
}, { timestamps: true })

const IndividualOutletRole = mongoose.Schema({
    label: { type: String },
    roles: [{type: String, enum: OR.allSubs}]
})
 
const IndividualDashboardAdminRole = mongoose.Schema({
    label: { type: String },
    roles: [{type: String, enum: DR.allSubs}]
})

const OutletRole = mongoose.Schema({
    roles: [IndividualOutletRole]
})

 
const DashboardAdminRole = mongoose.Schema({
    shop: { type: mongoose.Types.ObjectId, ref: "Shop"},
    roles: [IndividualDashboardAdminRole]
})
 
const Device = mongoose.Schema({
    os: { type: String, },
    version: { type: String, required: ["FCM Token is required", true] },
    deviceId: { type: String },
    fcmToken: { type: String, required: ["FCM Token is required", true] },
    notify: { type: Boolean, default: true }
}, { timestamps: true })

const SuperAdmin = mongoose.Schema({
    id: { type: String },
    user: { type: mongoose.Types.ObjectId, ref: "User",required:["User is required",true] },
    devices: [Device],
    deactivated: {type: Boolean, default: false,
        lastActive:{type:Date,default:Date.now()}
    }
}, { timestamps: true })

const Staff = mongoose.Schema({
    id: { type: String },
    user: { type: mongoose.Types.ObjectId, ref: "User", required:["User is required",true] },
    shop: [{ type: mongoose.Types.ObjectId, ref: "Shop", required:["Shop is required",true] }],
    role: {type: OutletRole},
    devices: [Device],
    available: { type: Boolean, default: true },
    avgRating: {type: Number,  default: 0},
    raterCount: {type: Number, default: 0},
    ratingStar: {type:Array, default: [0,0,0,0,0]}, 
    deactivated: {type: Boolean, default: false},
    lastActive:{type:Date,default:Date.now()},
    lastConnected: Date,
    lastDisconnected: Date,
    support: {type: Number},
    lastLocation: GeoSchemaWithStamp,
}, { timestamps: true })

const DashboardAdmin = mongoose.Schema({
    id: { type: String },
    user: { type: mongoose.Types.ObjectId, ref: "User", required:["User is required",true] },
    roles: [DashboardAdminRole],
    devices: [Device], 
    deactivated: {type: Boolean, default: false},
    lastConnected: Date,
    lastDisconnected: Date,
}, { timestamps: true })


SuperAdmin.index({ id: 'text' })
Staff.index({ id: 'text' })
DashboardAdmin.index({ id: 'text' })

SuperAdmin.pre('save', async function(next) {
    if (this.isModified('createdAt')) {
        this.id = await autoIncrementID("superadmin")
    }
    next()
})

Staff.pre('save', async function(next) {
    if (this.isModified('createdAt')) {
        this.id = await autoIncrementID("staff")
        var dataMap = await V.get()
        this.support = dataMap.get("support")
        next()
    }
    next()
})

DashboardAdmin.pre('save', async function(next) {
    if (this.isModified('createdAt')) {
        this.id = await autoIncrementID("dashboardAdmin")
    }
    next()
})

module.exports = { SuperAdmin: mongoose.model("SuperAdmin", SuperAdmin), DashboardAdmin: mongoose.model("DashboardAdmin", DashboardAdmin), Staff: mongoose.model("Staff", Staff)}