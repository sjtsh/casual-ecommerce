
const DH = require("../../middleware/dashboard_helper")
const WL = require("../../middleware/withLength")

exports.serialization = [
    {$lookup: {as: "value", from: "orders", localField: "_id", foreignField: "user", pipeline: [{$group: {_id: 1, last: {$last: "$total"}, value: { $sum: "$total"}}}]}},
    {$project:{
        "_id": 1, "id": 1, "name": 1, "phone": 1, "createdAt": 1, "deactivated": 1, 
        "value":{$cond:[{$eq: ["$value", []]}, 0, {$last: "$value.value"}]}, 
        "last":{$cond:[{$eq: ["$value", []]}, 0, {$last: "$value.last"}]},
        active: {$cond: [{
                    $and: [
                        {$ne: [{$ifNull: ["$lastConnected", 0]}, 0]},
                        {$gte: ["$lastConnected", {$ifNull: ["$lastDisconnected", "$lastConnected"]}]}
                    ]
                }, true,  "$lastDisconnected"]},
    }},
]