const mongoose = require("mongoose")
const {autoIncrementID} = require("../middleware/autoIncrementFunction");


const Category = mongoose.Schema({
    id: { type: String },
    name: { type: String, required: ["Name is required", true], index: {unique: true},},
    image: { type: String },
    tags: [{ type: String }],
    deactivated: {type: Boolean, default: false}
}, { timestamps: true })

Category.pre('save', async function (next) {
    if (this.isModified('createdAt')) {
        this.id = await autoIncrementID("category")
    }
    next()
})


Category.index({ id: 'text',tags: 'text', name: "text"  })

const SubCategory = mongoose.Schema({
    id: { type: String },
    category: { type: mongoose.Types.ObjectId, required: ["Category is required", true], ref: "Category" },
    name: { type: String, required: ["Name is required", true], index: {unique: true}, },
    image: { type: String },
    tags: [{ type: String }],
    deactivated: {type: Boolean, default: false}
}, { timestamps: true })

SubCategory.pre('save', async function (next) {
    if (this.isModified('createdAt')) {
        this.id = await autoIncrementID("sub_category")
    }
    next()
})

SubCategory.index({ id: 'text', tags: 'text', name: "text"   })


module.exports = { Category: mongoose.model("Category", Category), SubCategory: mongoose.model("SubCategory", SubCategory) }