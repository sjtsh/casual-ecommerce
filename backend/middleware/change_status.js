const e = require("express");
const { app } = require("firebase-admin");
const fs = require("fs");
const { request } = require("http");
const { default: mongoose } = require("mongoose");
const VT = require("../controllers/verifyToken");
const { Order, SingularOrderFeedback, RequestedShop, OrderItem } = require("../models/order");
const onConnection = require("../sockets/onConnection");
const shopNearby = require("./shop_nearby");
const { agenda, processTime } = require('../jobs/agenda')
const SS = require("../sockets/staffSocket");
const US = require("../sockets/userSocket");
const SUS = require("../sockets/staffUserSocket");
const { Staff } = require("../models/admin");
const { OutletRoles, DeliveryRoles } = require("../enums/outletRole");
// adminSocket
const min = 60000
const failAfter = min * 5
const failDeliveryRequestAfter = 10 * min
const cancellationWaitTime = 10 * min

exports.changeStatus = async(orderID, userID, distance) => {
    try{
    //emit to the user that the order is processing within 1 min
        var order = await Order.findById(orderID)
        if (order) {
            order.status = 2
            await order.save()
            US.emitOrderProcessingStarted(orderID, userID, order.waitTime)
            agenda.schedule(processTime(failAfter), "processOrder", { "orderID": orderID, "userID": userID })
        }
    }catch(E){
        console.log(E)
    }
}

exports.failIfNoFeedback = async (orderID, userID) => {
    var response = await Order.findById(orderID)
    if(response.status == 0 || response.status == 2){
        shopNearby.setInstantFailure(response, userID)
        var requestMissed = await RequestedShop.find({ order: orderID, status: 0  })
        for (var i in requestMissed) {
            SS.emitFeedbackMissed(requestMissed[i])
        }
    }
}

exports.processOrder = async(orderID, userID) => {
    try{
        var order = await Order.findById(orderID)
        if (!order) {
            return
        }
        if (order.status == -1 || order.status == -2 || order.status == -3 || order.status == 1) {
            return
        }
        var requestedShops = await RequestedShop.find({ order: orderID, status: 1 })
        const optimalRequestedShops = await calculateOptimalFeedback(order, requestedShops)
        if (optimalRequestedShops == null) {
            shopNearby.setInstantFailure(order, userID)
            return
        }
        order.status = 3
        await order.save()
            // order.confirmationDate = new Date()

        //---------------UNCOMMENT----------------
        // var requestToDisregard = await RequestedShop.find({ order: orderID, $and: [{ status: { $ne: 2 } }, { status: { $ne: 0 } }] })
        var requestToDisregard = await RequestedShop.find({ order: orderID, status: 1  })
        for (var i in requestToDisregard) {
            requestToDisregard[i].status = -3
            await requestToDisregard[i].save()
            SS.emitFeedbackDisregard(requestToDisregard[i])
        }

        var requestMissed = await RequestedShop.find({ order: orderID, status: 0  })
        for (var i in requestMissed) {
            SS.emitFeedbackMissed(requestMissed[i])
        }
        
        //------------------------------
        var requestsToConfirm = await RequestedShop.find({ order: orderID, status: 2 })
        for (var i in requestsToConfirm) {
            requestsToConfirm[i].selectAt = Date()
            await requestsToConfirm[i].save()
            var hasRole = await VT.comprehendRoleStaff(DeliveryRoles.delivery, requestsToConfirm[i].staff )
            if(hasRole) hasRoleRequestConfirmation(requestsToConfirm[i], order.user)
            else  notHasRoleRequestConfirmation(requestsToConfirm[i], requestsToConfirm[i].staff)
        }
        US.emitFeedbackComfirmationUser(order)
    }catch(e){
        console.log(e)
    }
}

const hasRoleRequestConfirmation = async(request, user)=>{
    request.feedback.deliveredBy = request.staff
    request.feedback.deliveryAcceptedAt = new Date()
    await request.save()
    setTimeout(()=>{
        SS.emitFeedbackComfirmationShop(request)
    }, 3000)
    const emergencyWaitTime = request.feedback.deliveryTime * min
    agenda.schedule(processTime(emergencyWaitTime), "notifyAsEmergency", { "requestForId": request, "user": user.toString() })
}

const notHasRoleRequestConfirmation = async(request, staff)=>{
    var deliveryStaffs = await this.findDeliveryStaffs(request.shop)
    if (!deliveryStaffs.length) {
        var order = await Order.findById(request.order)
        shopNearby.setInstantFailure(order, order.user)
        return SS.emitOrderFailed(request, staff)
    } 
    var delivStaffs = []
    for(var i in deliveryStaffs) delivStaffs.push(deliveryStaffs[i]._id.toString())
    for(var i in deliveryStaffs){
        SS.emitDeliveryRequest(request, deliveryStaffs[i])
        agenda.schedule(processTime(failDeliveryRequestAfter), "failDeliveryRequest", { "request": request._id.toString(), "user": delivStaffs })
    }
}

exports.failDeliveryRequest = async(request, delivStaffs)=>{
    var req = await RequestedShop.findById(request)
    if(!req.feedback.deliveredBy){
        var order = await Order.findById(req.order)
        shopNearby.setInstantFailure(order, order.user)
        SS.emitOrderFailed(req, request.staff)
        for(var i in delivStaffs){
            SS.emitOrderFailed(req, delivStaffs[i])
        }
    }
}

exports.findDeliveryStaffs = async (shopID) =>{
    var staffs =  await Staff.aggregate([
        {$match: {shop: mongoose.Types.ObjectId(shopID.toString()), devices: {$ne: []}, available: true, deactivated: {$ne: true}}}, 
        {$unwind: "$role.roles"}, 
        {$unwind: "$role.roles.roles"}, 
        {$match: {"role.roles.roles": DeliveryRoles.delivery}}
    ])
    return staffs
}

exports.notifyAsEmergency = async(requestForId) => {
    try{
    var request = await RequestedShop.findById(requestForId._id)
    var order = await Order.findById(request.order)
    if (request && (request.status == 3 || request.status == 2) && (order.status == 3 || order.status == 4)) {
        SS.notifyUrgency(request)
        agenda.schedule(processTime(cancellationWaitTime), "urgentCancellation", { "request": request, })
    }}catch(e){
        console.log(e)
    }
}

exports.urgentCancellation = async(requestForId) => {
    try{
    var request = await RequestedShop.findById(requestForId._id)
    if (request) {
        var order = await Order.findById(request.order)
        if (order) {
            if (request && (request.status == 3 || request.status == 2) && (order.status == 3 || order.status == 4)) {
                request.status = -4
                await request.save()
                SUS.emitSystemCancelled(request)
                checkWhetherOrderTimeout(order._id)
            }
        }
    }}catch(e){
        console.log(e)
    }
}

const checkWhetherOrderTimeout = async(orderID)=>{
    var requests = await RequestedShop.find({order: orderID})
    for(var i in requests){
        if(requests[i].status == 2 || requests[i].status == 3 || requests[i].status == 4){
            return
        }
    }
    var order = await Order.findById(orderID)
    order.status = -3
    await order.save()
    US.emitOrderTimeOut(order.user, order._id)
}

const calculateOptimalFeedback = async(order, requestedShopsAll) => {
    try{
    var requestedShops = []
    for (var i in requestedShopsAll) {
        if (requestedShopsAll[i].feedback) {
            requestedShops.push(requestedShopsAll[i])
        }
    }
    if (!requestedShops.length) return
    if (requestedShops.length == 1) {
        requestedShops[0].feedback.itemsAllocated = requestedShops[0].feedback.items.filter(function(item) {
            return item.item_count > 0
        })
        requestedShops[0].status = 2
        await requestedShops[0].save()
        return requestedShops
    }
    return await decideBestByVariation(order, requestedShops)}
    catch(e){console.log(e)}
}

const decideBestByVariation = async(order, requestedShops) => {
    try{
    var choosenOrders = []
    var requiredSKUs = new Map()
    var requiredSKUSet = new Set()
    var feedbackVsProductVsAllocatedCount = new Map()

    for (var i in order.items) {
        requiredSKUs.set(order.items[i].product.toString(), order.items[i].item_count)
        requiredSKUSet.add(order.items[i].product.toString())
    }

    var viableAloneShops = shopsViableAlone(requestedShops, requiredSKUs)

    if (viableAloneShops.length > 1) {
        var viableAloneShops = [chooseAmongViableShops(viableAloneShops)]
    }

    if (viableAloneShops.length == 1) {
        viableAloneShops[0].feedback.itemsAllocated = viableAloneShops[0].feedback.items.filter(function(item) {
            return item.item_count > 0
        })
        viableAloneShops[0].status = 2
        await viableAloneShops[0].save()
        return viableAloneShops
    }

    if (order.allOrNone) {
        return
    }

    for (let [key, value] of requiredSKUs) {
        //lowest priority first sorting
        //------------------------------------------------
        requestedShops.sort(function(a, b) {
            var aUniqueItemCount = 0
            var bUniqueItemCount = 0
            for (var i in a.feedback.items) {
                if (requiredSKUSet.has(a.feedback.items[i].product)) aUniqueItemCount += a.feedback.items[i].item_count
            }
            for (var i in b.feedback.items) {
                if (requiredSKUSet.has(b.feedback.items[i].product)) bUniqueItemCount += b.feedback.items[i].item_count
            }
            return bUniqueItemCount - aUniqueItemCount
        })
        requestedShops.sort(function(a, b) {
                var aUniqueCount = 0
                var bUniqueCount = 0
                for (var i in a.feedback.items) {
                    if (requiredSKUSet.has(a.feedback.items[i].product)) aUniqueCount += 1
                }
                for (var i in b.feedback.items) {
                    if (requiredSKUSet.has(b.feedback.items[i].product)) bUniqueCount += 1
                }
                return bUniqueCount - aUniqueCount
            })
            //------------------------------------------------

        var sKUVsFeedbackVsCount = new Map()
        for (var i in requestedShops) {
            for (var j in requestedShops[i].feedback.items) {
                var sku = requestedShops[i].feedback.items[j].product.toString()
                if (!sKUVsFeedbackVsCount.get(sku)) {
                    sKUVsFeedbackVsCount.set(sku, new Map())
                }
                sKUVsFeedbackVsCount.get(sku).set(requestedShops[i]._id.toString(), requestedShops[i].feedback.items[j].item_count)
            }
        }

        var itemsAllocated = 0
        var index = 0
        var listOfKeys = []
        var someoneHasIt = sKUVsFeedbackVsCount.get(key)
        if (someoneHasIt) {
            listOfKeys = Array.from(someoneHasIt.keys())
        }
        while (itemsAllocated < value && index < listOfKeys.length) {
            var itemCount = Math.min(sKUVsFeedbackVsCount.get(key).get(listOfKeys[index]), value - itemsAllocated)
            itemsAllocated = itemsAllocated + itemCount
            if (itemCount != 0) {
                if (!feedbackVsProductVsAllocatedCount.has(listOfKeys[index])) {
                    feedbackVsProductVsAllocatedCount.set(listOfKeys[index], new Map())
                }
                feedbackVsProductVsAllocatedCount.get(listOfKeys[index]).set(key, itemCount)
            }
            index += 1
        }
    }

    for (let [key, value] of feedbackVsProductVsAllocatedCount) {
        var singularOrderFeedbackOrUndefined = await allocateOrderToFeedback(key, value)
        if (singularOrderFeedbackOrUndefined) {
            choosenOrders.push(singularOrderFeedbackOrUndefined)
        }
    }

    return choosenOrders.slice(0, Math.min(choosenOrders.length, 5))}
    catch(e){console.log(e)}
}

const chooseAmongViableShops = (viableAloneShops) => {
    try{
    //TODO: decision making
    viableAloneShops = compareAmounts(viableAloneShops)
    // viableAloneShops = compareDeliveryCharge(viableAloneShops)
    viableAloneShops = compareDeliveryTime(viableAloneShops)
    viableAloneShops = compareDistance(viableAloneShops)
    return viableAloneShops[0]}
    catch(e){console.log(e)}
}

const allocateOrderToFeedback = async(feedback, productVsCount) => {
    try{

    var requestedShop = await RequestedShop.findById(feedback)
    var allocatedOrderItems = []
    for (var i in requestedShop.feedback.items) {
        var productID = requestedShop.feedback.items[i].product.toString()
        if (productVsCount.get(productID) && productVsCount.get(productID) != 0) {
            var rate = requestedShop.feedback.items[i].total / requestedShop.feedback.items[i].item_count
            allocatedOrderItems.push(OrderItem({ item_count: productVsCount.get(productID), total: productVsCount.get(productID) * rate, product: mongoose.Types.ObjectId(productID), margin: requestedShop.feedback.items[i].margin, return: requestedShop.feedback.items[i].return }))
        }
    }
    if (allocatedOrderItems.length != 0) {
        requestedShop.feedback.itemsAllocated = allocatedOrderItems.filter(function(item) {
            return item.item_count > 0
        })
        requestedShop.status = 2
        await requestedShop.save()
        return requestedShop
    }
    return
}
catch(e){console.log(e)}
}

const shopsViableAlone = (requestedShops, requiredSKUs) => {
    try{
    var sumOfRequired = 0
    for (var [i, j] of requiredSKUs) {
        sumOfRequired += j
    }
    var viableAloneShops = []
    for (var i in requestedShops) {
        var sumOfThere = 0
        for (var j in requestedShops[i].feedback.items) {
            sumOfThere += requestedShops[i].feedback.items[j].item_count
        }
        if (sumOfThere == sumOfRequired) {
            viableAloneShops.push(requestedShops[i])
        }
    }
    return viableAloneShops
}
catch(e){console.log(e)}
}

const compareAmounts = (viableAloneShops) => {
    try{
    var minAmountShops = null
    var minAmount = null
    for (var i in viableAloneShops) {
        var total = viableAloneShops[i].feedback.deliveryCharge
        for (var j in viableAloneShops[i].feedback.items) {
            total += viableAloneShops[i].feedback.items[j].total
        }
        if (minAmount == null) {
            minAmount = total
            minAmountShops = [viableAloneShops[i]]
        } else {
            if (total < minAmount) {
                minAmount = total
                minAmountShops = [viableAloneShops[i]]
            } else if (total == minAmount) {
                minAmountShops.push(viableAloneShops[i])
            }
        }
    }
    return minAmountShops
}
catch(e){console.log(e)}
}

const compareDeliveryCharge = (viableAloneShops) => {
    try{
    var minAmountShops = null
    var minAmount = null
    for (var i in viableAloneShops) {
        var total = viableAloneShops[i].feedback.deliveryCharge
        if (minAmount == null) {
            minAmount = total
            minAmountShops = [viableAloneShops[i]]
        } else {
            if (total < minAmount) {
                minAmount = total
                minAmountShops = [viableAloneShops[i]]
            } else if (total == minAmount) {
                minAmountShops.push(viableAloneShops[i])
            }
        }
    }
    return minAmountShops
}
catch(e){console.log(e)}
}

const compareDeliveryTime = (viableAloneShops) => {
    try{
    var minAmountShops = null
    var minAmount = null
    for (var i in viableAloneShops) {
        var total = viableAloneShops[i].feedback.deliveryTime
        if (minAmount == null) {
            minAmount = total
            minAmountShops = [viableAloneShops[i]]
        } else {
            if (total < minAmount) {
                minAmount = total
                minAmountShops = [viableAloneShops[i]]
            } else if (total == minAmount) {
                minAmountShops.push(viableAloneShops[i])
            }
        }
    }
    return minAmountShops
}
catch(e){console.log(e)}
}

const compareDistance = (viableAloneShops) => {
    try{
    var minAmountShops = null
    var minAmount = null
    for (var i in viableAloneShops) {
        var total = viableAloneShops[i].feedback.distance
        if (minAmount == null) {
            minAmount = total
            minAmountShops = [viableAloneShops[i]]
        } else {
            if (total < minAmount) {
                minAmount = total
                minAmountShops = [viableAloneShops[i]]
            } else if (total == minAmount) {
                minAmountShops.push(viableAloneShops[i])
            }
        }
    }
    return minAmountShops
}
catch(e){console.log(e)}
}