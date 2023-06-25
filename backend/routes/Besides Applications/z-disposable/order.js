const { Order, SingularOrderFeedback, RequestedShop, AddressSchema } = require("../../models/order");
const { OrderItem } = require("../../models/order")
const router = require("express").Router();
const {verifyToken} = require("../../controllers/verifyToken");
const { default: mongoose } = require("mongoose");
const ShopNearby = require("../../middleware/shop_nearby");
const onConnection = require("../../sockets/onConnection");
const { Shop } = require("../../models/shop");
const { findById } = require("../../models/shop");
const { verify } = require("jsonwebtoken");

router.post("/", verifyToken(), async(req, res, next) => {
    try{
        if (req.user.isShop) return res.status(403).json({ "message": "Shop cannot place order!" })
        req.body.user = req.user.id
        var pendingOrderCount = await Order.aggregate([
            { $match: { user: mongoose.Types.ObjectId(req.user.id), status: 0 }, },
            { $project: { _id: 1 } }
        ]);
        if (pendingOrderCount.length > 30)
            return res.status(400).json({ "message": "Complete previous orders!" })
        req.body.location = req.body.address.location
        // var order = Order({...req.body, "waitTime": onConnection.waitTime, "itemsAll": req.body.items })
        var order = Order({...req.body, "itemsAll": req.body.items })
        order.waitTime = onConnection.waitTime
        await order.save()
        await removeItemsFromOldOrder(req.body.order, order.items)
        ShopNearby.sendReqToNearbyShops(order, order.location.coordinates[1], order.location.coordinates[0], req)
        return res.status(200).json(order)
    }catch(E){
        console.log(E)
        next(E)
    }
})

// const foundARelativeOrder = async(orderID, order){

// }

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


router.get("/user", verifyToken(), async(req, res, next) => {

    try {
        var orders = await Order.aggregate([
            { $match: { user: mongoose.Types.ObjectId(req.user.id) } },
            { $project: { user: 0, "items.createdAt": 0, "items.updatedAt": 0 } },
            {
                $lookup: {
                    foreignField: "order",
                    localField: "_id",
                    as: "requestedShop",
                    from: "requestedshops",
                    pipeline: [{ $match: { $or: [{ status: 2 }, { status: 3 }, { status: 4 }] } }]
                },
            },
        ])
        return res.status(200).json(orders)

    } catch (e) {
        next(e)
    }

})
router.get("/detail/:id", verifyToken(), async(req, res, next) => {

    try {
        var orders = await Order.findById(req.params.id)

        return res.status(200).json(orders)

    } catch (e) {
        next(e)
    }

})
router.get("/feedback/:id", verifyToken(), async(req, res, next) => {

    try {
        var orders = await Order.findById(req.params.id)

        return res.status(200).json(orders)

    } catch (e) {
        next(e)
    }

})

router.get("/", verifyToken(), async(req, res, next) => {
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
                { $unwind: "$items" },
                { $project: { id:1, total: 1, status: 1, items: 1, createdAt: 1, waitTime: 1 , remarks:1 } },
                { $group: { _id: "$_id", total: { $last: "$total" },id:{$last:"$id"}, status: { $last: "$status" }, items: { $sum: 1 }, createdAt: { $last: "$createdAt" }, waitTime: { $last: "$waitTime" }, remarks: { $last: "$remarks" } } },
                {$sort: {createdAt: -1}},
                {$skip:itemsPerPage*((today==true? todayPageNum:historyPageNum)-1)},
                {$limit:itemsPerPage},
                {$lookup: {from: "requestedshops", as: "requests", localField: "_id", foreignField: "order", pipeline:[
                    {$match: {status: {$gte: 2}}},{$unwind:"$feedback.items"}, {$group: {_id: "_id", total: {$sum : "$feedback.items.total"}}}
                ]}},
                { $project: {id:1, status: 1, items: 1, createdAt:1, waitTime:1, total:{$cond: {if: {$eq: [[], "$requests"]}, then: "$total", else: {$sum: "$requests.total"} }}, remarks: 1 } },
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


router.post("/retry/:id", verifyToken(), async(req, res, next) => {
    try{
    var oldOrder = await Order.findById(req.params.id)
    if (!oldOrder) {
        return res.status(502).json("No Order Found For That Id")
    }
    if (oldOrder.user.toString() != req.user.id.toString()) {
        return res.status(503).json("You are not authenticated to retry")
    }
    var orderItems = []
    for (var i in oldOrder.items) {
        var orderItem = oldOrder.items[i]
        orderItems.push(OrderItem({ item_count: orderItem.item_count, total: orderItem.total, product: orderItem.product }))
    }
    var order = Order({ user: oldOrder.user, total: oldOrder.total, items: orderItems, ...req.body })
    order.verificationOTP = Math.floor(Math.random() * 9000 + 1000);
    await order.save()
    ShopNearby.sendReqToNearbyShops(order, order.location.coordinates[1], order.location.coordinates[0], req)
    var returnable = await onConnection.getOrder(order._id, req.user.id)
    return res.status(200).json(returnable)
}
catch(e){next(e)}
})

router.get("/:id", verifyToken(), async(req, res, next) => {
    try{
    var orders = await Order.aggregate(
        [
            { $match: { _id: mongoose.Types.ObjectId(req.params.id.toString()) } },
            { $unwind: "$items" },
            {
                $lookup: {
                    foreignField: "_id",
                    localField: "items.product",
                    as: "items.product",
                    from: "products",
                    pipeline: [{ $project: { name: 1, _id: 1, price: 1, category: 1, weight: 1, image: 1 } }]
                },
            },
            { $unwind: "$items.product" },
            {
                $group: {
                    _id: '$_id',
                    items: { $addToSet: '$items' },
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
                }
            },
            {
                $lookup: {
                    foreignField: "order",
                    localField: "_id",
                    as: "requestedShop",
                    from: "requestedshops",
                    pipeline: [{
                            $match: {  $or: [
                                { status: -4 },
                                { status: -2 },
                                {status: { $gt: 1 }}
                            ], },
 
                        },
                        {
                            $lookup: {
                                foreignField: "_id",
                                localField: "shop",
                                as: "shop",
                                from: "shops",
                                pipeline: [{ $project: { name: 1, _id: 1, phone: 1,avgRating:1,raterCount:1, img:1 } }]
                            },
                        },
                        { $unwind: "$shop" },
                        {
                            $project: { "feedback.items": 0 }
                        }
                        // {
                        //     $group: {
                        //         _id: "$feedback._id",
                        //         deliveryTime: { $last: '$deliveryTime' },

                        //     }
                        // },


                    ]
                },
            },
            {$lookup: {from: "requestedshops", as: "requests", localField: "_id", foreignField: "order", pipeline:[
                {$match: {status: {$gte: 2}}},{$unwind:"$feedback.items"}, {$group: {_id: "_id", total: {$sum : "$feedback.items.total"}}}
            ]}},
            {
                $project: {
                    _id: 1,
                    items: 1,
                    location: 1,
                    address: 1,
                    status: 1,
                    id: 1,
                    total: 1,
                    createdAt: 1,
                    updatedAt: 1, 
                    total:{$cond: {if: {$eq: [[], "$requests"]}, then: "$total", else: {$sum: "$requests.total"} }},
                    verificationOTP: 1,
                    waitTime: 1,
                    remarks:1,
                    requestedShop:1,
                }
            },
        ]
    )
    return res.status(200).json(orders[0])
}
catch(e){next(e)}
})


module.exports = router