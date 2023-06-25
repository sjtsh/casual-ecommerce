const mongoose = require("mongoose")
const BR = require("../enums/banner")
const { autoIncrementID } = require("../middleware/autoIncrementFunction");

const ColorObj = mongoose.Schema({
    color: String,
    transparency: {type: Number, default: 0}, //0 to 1
})

const Banner = mongoose.Schema({
    id: String,
    offsetX: {type: Number, default: 0}, //offset on the grid
    offsetY: {type: Number, default: 0}, 
    gridSpace: {type: Number, default: 2}, //with respect to product 
    img: String,
    redirectUrl: String, //ontap
    detail: String, //info
    title: String,
    titleColor:ColorObj,
    orientation:{type:Boolean,default:true},
    onlyImage:{type:Boolean,default:false},
    colors: [ColorObj],
    group: {type: String, enum: BR.all, default:BR.Banners.subgroup},
    foreign: mongoose.Types.ObjectId,
    deactivated: {type: Boolean, default: false}
}, { timestamps: true })

Banner.index({ id: 'text',title: 'text'})
Banner.pre('save', async function (next) {
    if (this.isModified('createdAt')) {
        this.id = await autoIncrementID("banner")
    }
    next()
})

module.exports = { Banner: mongoose.model("Banner", Banner) }