
const DH = require("../../middleware/dashboard_helper")
const WL = require("../../middleware/withLength")

exports.serialization = [
    {$lookup: {as: "user",localField: "user", foreignField: "_id", from: "users", pipeline: [
        {$lookup: {as: "count",localField: "_id", foreignField: "user", from: "orders", pipeline: [
            {$match: {status: 5, deactivated: {$ne: true}}},
            {$group : {_id: "_id", count: {$sum: 1}}}
        ]},},
        {$project: {name: 1, number: 1, count: {$cond: [{$ne: ["$count", []]}, {$first: "$count"}, 0]}}},
    ]}},
    {$unwind: "$user"},
    {$project: {id: 1, suggestion: 1, user: 1}}
]