const mongoose = require("mongoose")

const GeoSchema = mongoose.Schema({
    type: { type: String, default: "Point" },
    coordinates: [Number],
    deactivated: {type: Boolean, default: false}
})

const LensTrack = mongoose.Schema({
    clickCount: { type: Number },
    mail: { type: String },
    model: { type: String },
    id: { type: String },
    otherInfo: { type: String },
    location: { type: GeoSchema, required: ["Location point is required", true], index: "2dsphere" },
}, { timestamps: true })

module.exports = { LensTrack: mongoose.model("LensTrack", LensTrack) }