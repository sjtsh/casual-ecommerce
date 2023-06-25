
const { default: mongoose } = require("mongoose");
exports.Queries = {
    date: "date",
    search: "search",
    sort: "sort",
    skip: "skip",
    length: "length"
}
exports.all = Array.from(new Map(Object.entries(this.Queries)).values())