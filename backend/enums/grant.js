
const { default: mongoose } = require("mongoose");

const G = require("./grant.js");

exports.Grants = {
    user: "user",
    staff: "staff",
    dashboardAdmin: "dashboardadmin",
    superAdmin: "superadmin"
}

exports.all = Array.from(new Map(Object.entries(G.Grants)).values())