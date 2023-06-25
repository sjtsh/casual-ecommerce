const mongoose = require("mongoose")
const { autoIncrementID } = require("../middleware/autoIncrementFunction");


const ProductSuggestion = mongoose.Schema({
    id: { type: String },
    suggestion: { type: String, required: ["Suggestion is required", true], },
    user: { type: mongoose.Types.ObjectId, ref: "User",required:["User is required",true] },
    isStaff: { type: Boolean, required:["Is this user a staff",true] },
    deactivated: {type: Boolean, default: false}
    // enabled: { type: String, default: true },
}, { timestamps: true })

ProductSuggestion.index({ id: 'text' })

ProductSuggestion.pre('save', async function (next) {
    if (this.isModified('createdAt')) {
        this.id = await autoIncrementID("ProductSuggestion")
    }
    next()
})






module.exports = { ProductSuggestion: mongoose.model("ProductSuggestion", ProductSuggestion),  }