const mongoose = require("mongoose")

//owners name
//phone number
//password
const EditStaff = mongoose.Schema({
    category: { type: String, required: ["category is required", true]  },
    last_updated: {type: Date, required: ["updated date is required", true]  },
    staff: {type: mongoose.Types.ObjectId, ref: "Staff"},
    deactivated: {type: Boolean, default: false}
}, { timestamps: true })


module.exports = { EditStaff: mongoose.model("EditStaff", EditStaff) }

