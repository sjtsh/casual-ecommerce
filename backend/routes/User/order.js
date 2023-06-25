const { Order, SingularOrderFeedback, RequestedShop, AddressSchema } = require("../../models/order");
const { OrderItem } = require("../../models/order")
const router = require("express").Router();
const {verifyToken} = require("../../controllers/verifyToken");
const { default: mongoose } = require("mongoose");
const ShopNearby = require("../../middleware/shop_nearby");
const onConnection = require("../../sockets/onConnection")
const G = require("../../enums/grant")
const SUS = require("../../sockets/staffUserSocket");
const { Product } = require("../../models/product");
const { getNearestShop, getNearestShopFromLocation } = require("../../middleware/nearbyShop");

const AS = require("../../sockets/adminSocket")
const MV = require("../../middleware/maintainanceValues")

router.post("/",  verifyToken([G.Grants.user]),   async(req, res, next) => {
    try{
        if( MV.maintainanceValues.get("orderSystem") || MV.maintainanceValues.get("partnerSystem") || MV.useMaintainanceWarning("partnerSystem")) {
            return res.status(403).json({ "message": "Order System is under maintainance" })
        }
        if(MV.useMaintainanceWarning("userSystem")) {
            var message = "System is going under maintainance in " + diff(MV.useMaintainanceWarning("userSystem") , new Date())+ " minutes"
            return res.status(403).json({ "message": message})
        }
        if (req.user.isShop) return res.status(403).json({ "message": "Shop cannot place order!" })
        req.body.user = req.user.id
        var pendingOrderCount = await Order.aggregate([
            { $match: { user: mongoose.Types.ObjectId(req.user.id), status: 0 }, },
            { $project: { _id: 1 } }
        ])
        if (pendingOrderCount.length > 30) return res.status(400).json({ "message": "Complete previous orders!" })
        req.body.location = req.body.address.location
        var newItems = []
        var total = 0
        for(var i in req.body.items){
            
            var count = req.body.items[i].item_count
            var prod = req.body.items[i].product
            var productObj = await Product.findById(prod)
       
            newItems.push({count, item_count: count, total: productObj.price * count, product: prod, margin: productObj.margin, return: productObj.return})
            total += productObj.price * count
        }
        var shop = await getNearestShopFromLocation(req.body.location)
        if(shop == "throw") return res.status(400).json({"message": "Please send your location on the query"})
        if(!shop) return res.status(400).json({ "message": "Could not find shops Nearby!" })
        req.body.items = newItems
        req.body.total = total
        var order = Order({...req.body, "itemsAll": newItems, shop: shop._id})
        await order.save()
        await removeItemsFromOldOrder(req.body.order, order.items)
        AS.createOrderById(order._id)
        ShopNearby.sendReqToNearbyStaffs(order, order.location.coordinates[1], order.location.coordinates[0], shop._id)
        return res.status(200).json(order)
    }catch(E){
        console.log(E)
        next(E)
    }
})

const diff = (d1, d2)=>{
    var diff = Math.abs(d1 -d2)
    return Math.floor((diff/1000)/60)
}

router.put("/cancel",  verifyToken([G.Grants.user]),  async(req, res, next) => {
    try{
        var order = await Order.findById(req.body.order_id)
        order.status = -2
        await order.save()
        var requestedShops = await RequestedShop.find({order: order._id, $and: [{status: {$gte: 0}},{status: {$lte: 3}}]})
        for (var i in requestedShops) {
            requestedShops[i].status = -5
            await requestedShops[i].save()
            SUS.emitOrderCancelled(order._id, true, order.user.toString(), requestedShops[i].staff.toString(), false)
        }
        AS.updateOrderById(order._id)
        return res.status(200).json({"status": -2})
    }catch(E){
        console.log(E)
        next(E)
    }
})

const removeItemsFromOldOrder = async (orderID, items)=>{
    if(!orderID || orderID == null) return
    var order = await Order.findById(orderID)
    if(!order) return
    if(order.status==5) return
    var newItems = []
    for(var i in order.items){
        var isFound = false
        for(var j in items){
            if(order.items[i].product.toString() == items[j].product.toString()){
                isFound = true
            }
        }
        if(isFound == false){
            newItems.push(order.items[i])
        }
    }
    order.items = newItems
    await order.save()
}

router.get("/",  verifyToken([G.Grants.user]),   async(req, res, next) => {
        try{
    const itemsPerPage = 20
    var todayPageNum=1,historyPageNum=1
    if(req.query.tpage)
    todayPageNum=req.query.tpage
    if(req.query.hpage)
    historyPageNum=req.query.hpage

    // console.log(todayPageNum,historyPageNum)
    const orderFetch=async(today)=>{

        
        var dateWithTime=new Date()
        var todayStart,todayEnd
        if(process.env.ISPRODUCTION === "false"){
       
            todayStart = new Date(dateWithTime.getFullYear(), dateWithTime.getMonth(), dateWithTime.getDate(), 5, 45, 0, 0)// true for non production server
            todayEnd = new Date(dateWithTime.getFullYear(), dateWithTime.getMonth(), dateWithTime.getDate() + 1, 5, 45, 0, 0)
        }else{
       
            todayStart = new Date(dateWithTime.getFullYear(), dateWithTime.getMonth(), dateWithTime.getDate(), 0, 0, 0, 0) // true for production server
            todayEnd = new Date(dateWithTime.getFullYear(), dateWithTime.getMonth(), dateWithTime.getDate() + 1, 0, 0, 0, 0) // true for production server
        }
// Create the end date which holds the end of today

        var filter={createdAt:{$lt:todayStart}}
        if(today==true)
        // var filter={$and: [{createdAt: {$gte: todayStart}}, {createdAt: {$lt: todayEnd}}]}
        filter={ createdAt: {$gte: todayStart,$lt: todayEnd}}
       var data= await Order.aggregate(
            [
                { $match: { $and:[{user: mongoose.Types.ObjectId(req.user.id)},filter]}},
                //------sajat---so the reordered doesnt disappear------------
                { $project: { _id: 1, total: 1, id:1, status: 1, items: { $size: "$itemsAll" }, createdAt: 1, waitTime: 1, remarks: 1, fulfilled: 1 } },
                //---------------------------------------------------------
                // { $unwind: "$items" },
                // { $project: { id:1, total: 1, status: 1, items: 1, createdAt: 1, waitTime: 1 , remarks:1 } },
                // { $group: { _id: "$_id", total: { $last: "$total" },id:{$last:"$id"}, status: { $last: "$status" }, items: { $sum: 1 }, createdAt: { $last: "$createdAt" }, waitTime: { $last: "$waitTime" }, remarks: { $last: "$remarks" } } },
                //----------------------------------------------
                {$sort: {createdAt: -1}},
                {$skip:itemsPerPage*((today==true? todayPageNum:historyPageNum)-1)},
                {$limit:itemsPerPage},
                {$lookup: {from: "requestedshops", as: "requests", localField: "_id", foreignField: "order", pipeline:[
                    {$match: {status: {$gte: 2}}},{$unwind:"$feedback.items"}, {$group: {_id: "_id", total: {$sum : "$feedback.items.total"}}}
                ]}},
                { $project: {id:1, status: 1, items: 1, createdAt:1, waitTime:1, total:{$cond: {if: {$eq: [[], "$requests"]}, then: "$total", else: {$sum: "$requests.total"} }}, remarks: 1, fulfilled: 1 } },
            ]
        )
        return data;
    }
    var today= await orderFetch(true)
  
    
    var history= await orderFetch(false)
    return res.status(200).json({today,history})
}catch(e){
    console.log(e)
    next(e)
}
})



router.get("/:id",  verifyToken([G.Grants.user]),  async(req, res, next) => {
    try{
    var orders = await Order.aggregate(
        [
            { $match: { _id: mongoose.Types.ObjectId(req.params.id.toString()) } },
            { $unwind: "$itemsAll" },
            {$lookup: {foreignField: "_id",localField: "itemsAll.product",as: "itemsAll.product",from: "products",pipeline: [
                { $project: { name: 1, _id: 1, price: 1, category: 1, weight: 1, image: 1 } }
            ]},},
            { $unwind: "$itemsAll.product" },
            {
                $group: {
                    _id: '$_id',
                    itemsAll :{ $addToSet: '$itemsAll' },
                    items:{ $last: "$items" },
                    location: { $last: '$location' },
                    address: { $last: '$address' },
                    status: { $last: '$status' },
                    id: { $last: "$id" },
                    total: { $last: "$total" },
                    createdAt: { $last: "$createdAt" },
                    updatedAt: { $last: "$updatedAt" },
                    remarks: { $last: "$remarks" },
                    verificationOTP: { $last: "$verificationOTP" },
                    waitTime: { $last: "$waitTime" },
                    fulfilled: {$last: "$fulfilled"}
                }
            },
            {
                $lookup: {
                    foreignField: "order",localField: "_id",as: "requestedShop",from: "requestedshops",
                    pipeline: [{$match: {  $or: [{ status: -4 },{ status: -2 },{status: { $gt: 1 }}], },},
                        {$lookup: {
                                foreignField: "_id", localField: "shop", as: "shop", from: "shops",
                                pipeline: [{ $project: { name: 1, _id: 1, phone: 1, img:1 } }]
                        },},
                        { $unwind: "$shop" },
                        {$lookup: {
                            
                                //-------------------------------------------------------------------------------------------------
                                //----------------------------Change the local field with delivered by-----------------------------
                                //-------------------------------------------------------------------------------------------------
                                foreignField: "_id", localField: "staff", as: "staff", from: "staffs", pipeline: [
                                    {$lookup: {foreignField: "_id",localField: "user",as: "user",from: "users"},},
                                    {$unwind: "$user"},
                                    { $project: {avgRating:1, raterCount:1, ratingStar:1, phone: "$user.phone", name: "$user.name" } }
                                ]
                            },},
                        {$unwind:"$staff"},
                        {$project: { "feedback.items": 0 }}
                        // { $group: {_id: "$feedback._id",deliveryTime: { $last: '$deliveryTime' }, }},
                    ]
                },
            },
            {$lookup: {from: "requestedshops", as: "requests", localField: "_id", foreignField: "order", pipeline:[
                {$match: {status: {$gte: 2}}},{$unwind:"$feedback.items"}, {$group: {_id: "_id", total: {$sum : "$feedback.items.total"}}}
            ]}},
            {$project: {_id: 1,items: 1,location: 1,address: 1,status: 1,id: 1,total: 1,createdAt: 1,updatedAt: 1, 
            total:{$cond: {if: {$eq: [[], "$requests"]}, then: "$total", else: {$sum: "$requests.total"} }},
            verificationOTP: 1,waitTime: 1,remarks:1,requestedShop:1, itemsAll:1, fulfilled: 1}},
        ]
    )
    return res.status(200).json(orders[0])
}
catch(e){next(e)}
})


module.exports = router