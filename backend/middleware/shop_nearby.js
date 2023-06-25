const { Shop } = require("../models/shop")
const { Order, RequestedShop } = require("../models/order")
const { Product } = require("../models/product")
const XLSX = require('xlsx');
const app = require("../urls");
// import {map} from "../sockets/onConnection";
const onConnection = require("../sockets/onConnection");
const { changeStatus } = require("./change_status");
const { SubCategory } = require("../models/category");
const { getPersonalOrder } = require("./serialization/serialization");
const SS = require("../sockets/staffSocket");
const US = require("../sockets/userSocket");
const  OR = require("../enums/outletRole");
const { Staff } = require("../models/admin");
const { default: mongoose } = require("mongoose");

const AS = require("../sockets/adminSocket");

exports.sendReqToNearbyStaffs = async(order, lat, lon, shopID) => {
    const staffs = await recurseForStaffs(
        parseFloat(10000000),
        parseFloat(10000000),
        parseFloat(lat),
        parseFloat(lon),
        shopID)
    if(!staffs) return 
    var negativeCounter = 0
    // var uniqueCategories = await findUniqueCategories(order)
    for (const i in staffs) {
        var isEmitted
        var staffWhole = await Staff.findById(staffs[i].staff._id)
        if(staffWhole) isEmitted = await comprehendShouldRequest(staffs[i].staff, order) 
        if (!isEmitted) negativeCounter += 1
    }
    console.log("requested staffs", staffs.length - negativeCounter, "at", new Date())
    if (staffs.length == 0) {
        setInstantFail(order, order.user)
    } else {
        changeStatus(order._id, order.user)
    }
}

const comprehendShouldRequest = async (staff, order)=>{
    // var assignedOrderItems = await findOrderItemsAble(order, staff.staff.shop)
    // if(!assignedOrderItems.length) return
    var requestedShop = await this.createARequestedShop( staff._id, order.shop, order)
    var personalorder = await getPersonalOrder(order._id, staff._id)
    if(personalorder){
        var isEmitted = await SS.emitOrderRequest(staff._id, personalorder, requestedShop)
    }
    return isEmitted
}

// const findOrderItemsAble = async(order, shopID)=>{
//     var shop = await Shop.findById(shopID)
//     var categories = new Set()
//     for(var i in shop.categories){
//         categories.add(shop.categories[i].toString())
//     }
//     var assignedOrderItems = []
//     for(var i in order.items){
//         var productSmall = await Product.findById(order.items[i].product)
//         var product = await SubCategory.findById(productSmall.category)
//         if(categories.has(product.category.toString())){
//             assignedOrderItems.push(order.items[i])
//         }
//     }
//     return assignedOrderItems
// }

exports.findItemsAble = async (order, shopID) =>{
    return await findOrderItemsAble(order, shopID)
}

const findUniqueCategories = async(personalOrder)=>{
    var uniqueCategories = new Set()
    for(var i in personalOrder.items){
        var product = await Product.findById(personalOrder.items[i].product)
        uniqueCategories.add(product.category.toString())
    }
    return uniqueCategories
}
 
exports.setInstantFailure = (order, userID) => {
    setInstantFail(order, userID)
}

exports.createARequestedShop = async (staffID, shopID, order)=>{
    try{
    // var assignedOrderItems = await this.findItemsAble(order, shopID)
    // if(!assignedOrderItems.length) return
    var recentRequestedShop = RequestedShop({ order: order._id, staff: staffID, shop: shopID, distance: order.distance, itemsAble: order.items })//assignedOrderItems
    await recentRequestedShop.save()
}
    catch(e){console.log(e)}
}


const setInstantFail = async(order, userID) => {
    order.status = 1
    await order.save()
    setTimeout(()=>{
        US.emitOrderFailed(order._id, userID)
        AS.updateOrderById(order._id)
    }, 1000)
}

exports.recurseForShopExport = async(max_dist, lat, lon) => {
    try{
    return await getNearbyStaffs(max_dist, lat, lon)
}
catch(e){next(e)}
}

const recurseForStaffs = async(initial_dist, max_dist, lat, lon, shopID) => {
    try{
    if (initial_dist > max_dist) return []
    const staffs = await getNearbyStaffs(shopID, lat, lon)
        // const shops = await filterOfflineShops(nearbyShops, req)

    // if (shops.length == 0) {
    //     return recurseForStaffs(initial_dist + 100, max_dist, lat, lon, req)
    // }
    return staffs
}
catch(e){console.log(e)}
}

const filterOfflineShops = async(shops, req) => {
    try{
    var onlineShops = []
    shops.forEach(element => {
        const supposedSocket = req.app.get('shopToSocket')
        if (supposedSocket.has(element._id.toString())) {
            onlineShops.push(element)
        }
    })
    return onlineShops
}
catch(e){next(e)}
}

 const getNearbyStaffs = async (shopID, lat, lon)  =>{
    try{
        var staffs = await Shop.aggregate([
            {$match: {_id: mongoose.Types.ObjectId(shopID.toString())}},
            {$lookup: {as: "staff", from: "staffs", localField: "_id", foreignField: "shop", pipeline:[
                {$unwind: "$role.roles"}, {$unwind: "$role.roles.roles"}, {$match: {"role.roles.roles": OR.OrderRoles.receive, deactivated: {$ne: true}, available: true, devices: {$ne: []}}}
            ]}},
            {$unwind: "$staff"}
        ])
        var filteredStaffs = []
        for(var i in staffs){
            delete staffs[i].staff.role
            if(staffs[i].canDeliver) filteredStaffs.push(staffs[i])
        }
        return staffs
    }
    catch(e){console.log(e)}
}