const router = require("express").Router()
const { default: mongoose } = require("mongoose")
const { User } = require("../../../models/user")
const { SubCategory } = require("../../../models/category")
const WL = require("../../../middleware/withLength")
const { Shop } = require("../../../models/shop")
const { Staff } = require("../../../models/admin")
const { Grants } = require("../../../enums/grant")
const {verifyToken, comprehendRole, authorityWithParam} = require("../../../controllers/verifyToken")
const DR = require("../../../enums/dashboardRole")
const SG = require("../../../middleware/ShopGrants")
const { Product } = require("../../../models/product")
const AS = require("../../../sockets/adminSocket")
const { Order } = require("../../../models/order")


const serializationProduct = [
    {$lookup: {as: "master", from: "masterproducts", localField: "master", foreignField: "_id"}},
    {$unwind: "$master"},
     {$sort:{createdAt:-1}},
    {$project:{"_id": 1, "id": 1, "name": 1, "barcode": 1, "master_barcode": "$master.barcode", "master": "$master._id", "sku": 1, "unit": 1, "price": 1, "master_price": "$master.price", "return": 1, "margin":1, "verificationOutlet": 1, "verificationAdmin":1, "image": 1, "deactivated": 1, "tags":1,  "master_tags": "$master.tags", "remarks": 1, "createdAt": 1}},
]

const serializationShop = [
    {$lookup:{from: "products", as: "products", localField:"_id", foreignField: "shop", pipeline:[{$match:{verificationAdmin: 1}}, {$group:{_id: "_id", count: {$sum: 1}}}]}},
    {$lookup:{from: "products", as: "products1", localField:"_id", foreignField: "shop", pipeline:[{$match:{verificationAdmin: 2}}]}},
    {$lookup: {as: "value", from: "requestedshops", localField: "_id", foreignField: "shop", pipeline: [{$match: {status: 4}},{$project:{value:{$sum:"$feedback.items.total"},sku:{$sum:"$feedback.items.item_count"}}}]}},
    {$project: {_id: 1, id: 1, name: 1,img: 1, address: 1, location: 1, phone: 1, owner: 1, deliveryRadius: 1, approved: 1, deactivated: 1, createdAt: 1, value: {$sum:  {$sum:"$value.value"}}, sku: {$size:"$products1"}, pending:{$cond: [{$ne: ["$products", []]}, true, false]}}},
]

const getShop = async (id) =>{
    var shops = await Shop.aggregate([
        {$match: {_id : mongoose.Types.ObjectId(id.toString())}},
        ...serializationShop
    ])
    return shops[0]
}

router.get("/products/:id",  verifyToken(Grants.dashboardAdmin), comprehendRole(DR.OutletsRoles.read), authorityWithParam("id"), async(req,res,next)=>{
    try{
        return res.status(200).json(await WL.handleQueriesWithCount(Product, req, [
            {$match: {shop: mongoose.Types.ObjectId(req.params.id)}},
            ...serializationProduct,
        ]))
    }
    catch(e) {next(e)}
}) 

router.get("/staffs/:id",  verifyToken(Grants.dashboardAdmin), comprehendRole(DR.OutletsRoles.read), authorityWithParam("id"), async(req,res,next)=>{
    try{
        return res.status(200).json(await WL.handleQueriesWithCount(Staff, req, [
            {$match: {shop: mongoose.Types.ObjectId(req.params.id)}},
            {$lookup: {as: "user", from: "users", localField: "user", foreignField: "_id", pipeline:[{$project:{"name":1,"phone":1,"_id":1}}]}},
            {$unwind:"$user"},
            {$unwind:"$shop"},
            {$match: {shop: mongoose.Types.ObjectId(req.params.id)}},
            {$lookup: {as: "shop", from: "shops", localField: "shop", foreignField: "_id", pipeline:[{$project:{"name":1,"phone":1,"_id":1}}]}},
            {$unwind:"$shop"},
        ]))
    }
    catch(e) {next(e)}
}) 

router.get("/:id", verifyToken(Grants.dashboardAdmin), comprehendRole(DR.OutletsRoles.read), authorityWithParam("id"), async(req,res,next)=>{
    try{
        var shops = await Shop.aggregate([
            {$match: {_id: mongoose.Types.ObjectId(req.params.id)}},
            {$lookup:{from: "staffs", as: "partners", localField:"_id", foreignField:"shop", pipeline:[{$group:{_id: "_id", count: {$sum: 1}}}]}},
            {$project: {createdAt: 1, updatedAt: 1, owner: 1, name: 1, phone: 1, address: 1, info: 1, timing: 1, img: 1, deliveryRadius: 1, location: 1, deactivated: 1, shopImg: 1, documents: 1, partners: {$sum: "$partners.count"}}},
        ])
        return res.status(200).json(shops[0])
    }
    catch(e) {next(e)}
})

router.get("/", verifyToken(Grants.dashboardAdmin), comprehendRole(DR.OutletsRoles.read), async(req,res,next)=>{
    try{
        return res.status(200).json(await WL.handleQueriesWithCount(Shop, req, [...serializationShop, {$sort: {name: 1}},], {sort: "name", param: "_id"}))
    }
    catch(e) {
        console.log(e)
        next(e)}
})
// router.get("/:id", async(req,res,next)=>{
//     try{
//         var users = await Shop.aggregate([ 
//                 {$lookup: {as: "value", from: "orders", localField: "_id", foreignField: "user", pipeline: [{$group: {_id: 1, last: {$last: "$total"}, value: { $sum: "$total"}}}]}},
//                 {$project:{"_id": 1, "id": 1, "name": 1, "phone": 1, "createdAt": 1, "deactivated": 1, "value":{$cond:[{$eq: ["$value", []]}, 0, {$last: "$value.value"}]}, "last":{$cond:[{$eq: ["$value", []]}, 0, {$last: "$value.last"}]}}},
//                 {$sort:{value:-1}},
//             ],
//         )
//         return res.status(200).json(users[0])
//     }
//     catch(e) {next(e)}
// })

router.put("/:id", verifyToken(Grants.dashboardAdmin), comprehendRole(DR.OutletsRoles.update), authorityWithParam("id"), async (req, res, next) => {
    try{ 
        await Shop.findByIdAndUpdate(req.params.id, req.body)
        var response = await getShop(req.params.id)
        AS.updateShop(response, req.headers["socket-id"])
        return res.status(200).json(response)
    }
    catch(e){next(e)}
})

router.post("/", verifyToken(Grants.dashboardAdmin), comprehendRole(DR.OutletsRoles.create), async (req, res, next) => {
    try{ 
        var shop = Shop(req.body)
        await shop.save()
        var response = await getShop(shop._id)
        AS.createShop(response, req.headers["socket-id"])
        return res.status(201).json(response)
    }
    catch(e){next(e)}
})

module.exports = router