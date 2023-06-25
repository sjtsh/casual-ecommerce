
const { default: mongoose } = require("mongoose");

exports.Units = {
    gram: "gm",
    kilogram: "kg",
    milliliter: "ml",
    liter: "ltr",
    pieces: "pcs",
    box: "box",
}

exports.all = Array.from(new Map(Object.entries(this.Units)).values())