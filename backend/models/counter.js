const mongoose = require("mongoose")

const Counters = mongoose.Schema({
    field: { type: String, required: ["Field name is required", true] },
    sequence_value: { type: Number, default: 0 },
})


module.exports = { Counters: mongoose.model("Counters", Counters) }