const mongoose = require("mongoose");
const { Units } = require("../enums/unit");
const { autoIncrementID } = require("../middleware/autoIncrementFunction");

const MasterProduct = mongoose.Schema({
    id: { type: String },
    name: { type: String },
    price: { type: Number, },
    image: { type: String },
    tags: [ String ],
    category: { type: mongoose.Types.ObjectId, ref: "SubCategory" }, //creator
    //--------------non implemented-------------
    verificationOutlet: {type: Number, default: 1},
    verificationAdmin: {type: Number, default: 1},
    staff: { type: mongoose.Types.ObjectId, ref: "Staff" }, //creator
    unit: { type: String, enum: Units.all},
    margin: { type: Number, }, //in percentage
    sku: { type: Number, }, //count in a package
    return: { type: Number, }, // daily
    barcode: { type: String, }, 
    limit: {type: Number},//number of quantity that can be bought
    deactivated: {type: Boolean, default: false},
},{ timestamps: true })

const RemarksWithUserModel =  mongoose.Schema({
    phone: {type: String},
    name: {type: String},
    by: { type: mongoose.Types.ObjectId }, //creator
    remarks:  {type: String},
}, { timestamps: true })

const RemarksModel = mongoose.Schema({
    remarksStaff: RemarksWithUserModel,
    remarksOutletAdmin: RemarksWithUserModel,
    remarksSuperAdmin: RemarksWithUserModel,
    remarksStaffReferenceUrl: String, 
})

const Product = mongoose.Schema({
    id: { type: String },
    name: { type: String, index: {unique: true}, },
    price: { type: Number, },
    image: { type: String },
    tags: [ String ],
    category: { type: mongoose.Types.ObjectId, ref: "SubCategory" }, //creator
    //--------------non implemented-------------
    verificationOutlet: {type: Number, default: 1},
    verificationAdmin: {type: Number, default: 1},
    staff: { type: mongoose.Types.ObjectId, ref: "Staff" }, //creator
    master:{ type: mongoose.Types.ObjectId, ref: "MasterProduct" }, //master
    shop:{ type: mongoose.Types.ObjectId, ref: "Shop" }, //outlet related
    unit: { type: String, enum: Units.all},
    margin: { type: Number, }, //in percentage
    sku: { type: Number, }, //count in a package
    return: { type: Number, }, // daily
    barcode: { type: String, }, 
    remarks: RemarksModel, 
    limit: {type: Number},//number of quantity that can be bought
    deactivated: {type: Boolean, default: false},
}, { timestamps: true })


//verification status 0 - > unapproved
//verification status 1 - > pending
//verification status 2 - > approved

Product.index({ id: 'text', tags: 'text', name: 'text' })
MasterProduct.index({ tags: 'text', id: 'text' , name: 'text'})

MasterProduct.pre('save', async function (next) {
    if (this.isModified('createdAt')) {
        this.id = await autoIncrementID("master")
    }
    next()
})

Product.pre('save', async function (next) {
    if (this.isModified('createdAt')) {
        this.id = await autoIncrementID("product")
    }
    next()
})
module.exports = { Product: mongoose.model("Product", Product) , MasterProduct: mongoose.model("MasterProduct", MasterProduct) }