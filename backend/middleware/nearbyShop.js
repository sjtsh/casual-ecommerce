
const { DeliveryRoles, OrderRoles } = require("../enums/outletRole");
const { Categry, SubCategory } = require("../models/category")
const { Order,RequestedShop } = require("../models/order");
const { Shop } = require("../models/shop");

exports.getNearestShop = async(req)=>{
    var lon
    var lat
    if(req.query.lon) lon = parseFloat(req.query.lon)
    if(req.query.lat) lat = parseFloat(req.query.lat)
    if(!lat || !lon) return res.status(400).json({"message": "Please send your location on the query"})
    var allShopsInRange = await Shop.aggregate(this.getNearestShopQuery(lat, lon))
    allShopsInRange = allShopsInRange.filter((e)=> e.canDeliver)
    return allShopsInRange[0]
}
exports.getNearestShopFromLocation = async(location, res)=>{
    var lon = location.coordinates[0]
    var lat = location.coordinates[1]
    if(!lat || !lon) return "throw"
    var allShopsInRange = await Shop.aggregate(this.getNearestShopQuery(lat, lon))
    allShopsInRange = allShopsInRange.filter((e)=> e.canDeliver)
    return allShopsInRange[0]
}

exports.getNearestShopQuery =  (lat, lon)=>{

    var d = new Date()
    var dateWithTime 
    var today
    if(process.env.ISPRODUCTION === "false") dateWithTime =new Date(d.getFullYear(), d.getMonth(), d.getDate(), d.getHours() - 5,d.getMinutes() - 45, 0, 0) // true for non production server
    else dateWithTime = new Date(d.getFullYear(), d.getMonth(), d.getDate(), d.getHours(), d.getMinutes(), 0, 0) // true for production server

    var todayHour = dateWithTime.getHours()
    var todayMinute = dateWithTime.getMinutes()
    var todayDay = dateWithTime.getDay()
    return [
        {
            $geoNear: {
                near: {type: "Point",coordinates: [lon, lat]},
                spherical: true,
                maxDistance:3000,
                distanceField: 'distance',
            },
        },
        {$project: {
            unconventional: {$or: [{$gte: ["$timing.start.hour", "$timing.end.hour"]}, {$and: [{$eq: ["$timing.start.hour", "$timing.end.hour"]},{$gte: ["$timing.start.minute", "$timing.end.minute"]}]}]}, 
            canDeliver: { $lte: ["$distance", "$deliveryRadius"] },
            timing: 1, phone:1, distance: 1, deactivated: 1
        }},
        {$match: {
            deactivated: {$ne: true},
            $or: [
                {timing: null},
                {$and: [
                    // 9.30am to 9pm -> 11:30 
                    {$and: [
                        {$or:[
                            {$and: [{unconventional: true}, {$or: [{"timing.start.hour": {$gt: todayHour}}, {$and: [{"timing.start.minute": {$gt: todayMinute}}, {"timing.start.hour": todayHour}]}]}]},
                            {$or: [{"timing.start.hour": {$lt: todayHour}}, {$and: [{"timing.start.minute":  {$lte: todayMinute}}, {"timing.start.hour": todayHour}]}]},
                        ]},
                        {$or: [{"timing.end.hour": {$gt: todayHour}}, {$and: [{"timing.end.minute": {$gt: todayMinute}}, {"timing.end.hour": todayHour}]}]},
                    ]},
                    {"timing.closedOn": {$ne: todayDay}}
                ]}
            ]
        }},
        {$lookup: {as: "count", from: "staffs", localField: "_id", foreignField: "shop", pipeline: figureRole(DeliveryRoles.delivery)}}, 
        {$unwind: "$count"},
        {$lookup: {as: "count", from: "staffs", localField: "_id", foreignField: "shop", pipeline: figureRole(OrderRoles.receive)}},
        {$unwind: "$count"},
        {$lookup: {as: "count", from: "products", localField: "_id", foreignField: "shop", pipeline: [
            {$match: {deactivated: {$ne: true}, verificationAdmin: 2}},
            {$group: {_id: "_id", count: {$sum: 1}}}
        ]}},
        {$unwind: "$count"},
        {$sort: {"count.count": -1}},
        {$project:{phone: 1, canDeliver: 1, distance: 1}},
    ]
}

const figureRole = (role) =>{
    var d = new Date()
    if(process.env.ISPRODUCTION === "false") today = new Date(d.getFullYear(), d.getMonth(), d.getDate(), - 5, - 45, 0, 0) // true for non production server
    else today = new Date(d.getFullYear(), d.getMonth(), d.getDate(), 0, 0, 0, 0) // true for production server

    return [
        {$match: {devices: {$ne: []}, available: true, deactivated: {$ne: true}, lastConnected: {$gte: today}}}, 
        {$unwind: "$role.roles"},  
        {$unwind: "$role.roles.roles"}, 
        {$match: {"role.roles.roles": role}}, 
        {$group: {_id: "_id"}}
    ]
}