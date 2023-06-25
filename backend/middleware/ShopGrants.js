
const { default: mongoose } = require("mongoose");
const { Grants } = require("../enums/grant");

exports.filterQueryGet = (req,  matchKey)=>{
    if(req.grant == Grants.superAdmin) return []
    var matchQuery = {}
    matchQuery[matchKey] = {$in: req.shopAuthorityObject}
    return [{$match: matchQuery}]
}
