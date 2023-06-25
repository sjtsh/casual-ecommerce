
const { default: mongoose } = require("mongoose");

exports.Banners = {
    landing: "landing",
    subgroup: "subgroup",
}

exports.all = Array.from(new Map(Object.entries(this.Banners)).values())