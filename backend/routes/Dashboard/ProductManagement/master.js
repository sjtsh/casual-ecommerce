const router = require("express").Router()
const { default: mongoose } = require("mongoose")
const { Product, MasterProduct } = require("../../../models/product")
const WL = require("../../../middleware/withLength")
const { Grants } = require("../../../enums/grant")
const {verifyToken, comprehendRole} = require("../../../controllers/verifyToken")
const DR = require("../../../enums/dashboardRole")
const { SubCategory, Category } = require("../../../models/category")

const AS = require("../../../sockets/adminSocket")
// const serializationMaster =  [
//     {$lookup: {as: "subcategory", from: "subcategories", localField: "category", foreignField: "_id", pipeline:[
//         {$project:{"name":1,"image":1,"_id":1, "category": 1}}, 
//         {$lookup: {as: "category", from: "categories", localField: "category", foreignField: "_id", pipeline:[{$project:{"name":1,"image":1,"_id":1}}]}},
//         {$unwind:"$category"},
//     ]}}, 
//     {$unwind:"$subcategory"},
//     {$lookup: {as: "value", from: "products", localField: "_id", foreignField: "master", pipeline: [
//         {$lookup: {as: "value", from: "productitems", localField: "_id", foreignField: "product", pipeline:[{$group: {_id: 1, value: {$sum: "$total"}}}]}},
//         {$group: {_id: 1, value: {$sum: {$sum: "$value.value"}}}}
//     ]}},
//     {$lookup: {as: "staff", from: "staffs", localField: "staff", foreignField: "_id", pipeline:[
//         {$lookup: {as: "user", from: "users", localField: "user", foreignField: "_id", pipeline:[{$project: {name: 1, phone: 1}}]}},
//         {$unwind: "$user"}
//     ]}},
//     {$project:{"_id": 1, "id": 1, "name": 1, "sku": 1,"verificationOutlet": 1,"verificationAdmin": 1,  "unit": 1, "barcode": 1, "tags": 1,  "price": 1, "image": 1, "deactivated": 1, "master": 1, "subcategory": {"name":1,"image":1,"_id":1}, "category": "$subcategory.category", "value":{$cond:[{$eq: ["$value.value", []]}, 0,{$first: "$value.value"}] },"createdAt":1, "staff":{$cond:[{$eq: ["$staff", []]}, null, {$first: "$staff.user"}] }}},
// ]
const serializationMaster =  [

    {$lookup: {as: "subcategory", from: "subcategories", localField: "category", foreignField: "_id", pipeline:[
        {$project:{"name":1,"image":1,"_id":1, "category": 1}}, 
        {$lookup: {as: "category", from: "categories", localField: "category", foreignField: "_id", pipeline:[{$project:{"name":1,"image":1,"_id":1}}]}},
        {$unwind:"$category"},
    ]}}, 
    {$unwind:"$subcategory"},
    {$lookup: {as: "value", from: "productitems", localField: "_id", foreignField: "master", pipeline:[{$group: {_id: 1, value: {$sum: "$total"}}}]}},
    {$lookup: {as: "staff", from: "staffs", localField: "staff", foreignField: "_id", pipeline:[
        {$lookup: {as: "user", from: "users", localField: "user", foreignField: "_id", pipeline:[{$project: {name: 1, phone: 1}}]}},
        {$unwind: "$user"}
    ]}},
    {$project:{"_id": 1, "id": 1, "name": 1, "sku": 1, "limit": 1, "verificationOutlet": 1,"verificationAdmin": 1,  "unit": 1, "barcode": 1, "tags": 1,  "price": 1, "image": 1, "deactivated": 1, "master": 1, "subcategory": {"name":1,"image":1,"_id":1}, "category": "$subcategory.category", "value":{$cond:[{$eq: ["$value.value", []]}, 0, {$first: "$value.value"}]},"createdAt":1, "staff":{$cond:[{$eq: ["$staff", []]}, null, {$first: "$staff.user"}] }}},
]
// 

const getMaster = async (id)=>{
    var prod = await MasterProduct.aggregate([
        {$match: {_id: mongoose.Types.ObjectId(id.toString())}},
         ...serializationMaster
    ])
    return prod[0]
}

router.get("/", verifyToken(Grants.dashboardAdmin), comprehendRole(DR.MasterRoles.read), async(req,res,next)=>{
    try{
        return res.status(200).json(await WL.handleQueriesWithCount(MasterProduct,req,serializationMaster))
    }
    catch(e) {next(e)}
})

router.get("/subcategory", verifyToken(Grants.dashboardAdmin), comprehendRole(DR.MasterRoles.create), async (req, res, next) => {
    try{  
        var subcategory = await SubCategory.aggregate([{$match: {deactivated: {$ne: null}}},{$project:{_id: 1, id: 1, name: 1}}])
        return res.status(200).json({"data": subcategory, "count": 0})
    }
    catch(e){next(e)}
})

const update = async (key, req)=>{
    if(req.body[key] != 0 && !req.body[key]) return
    var prods = await Product.find({master: req.params.id})
    for(var i in prods){
        prods[i][key] = req.body[key]
        await prods[i].save()
    }
}

router.put("/:id", verifyToken(Grants.dashboardAdmin), comprehendRole(DR.MasterRoles.update), async (req, res, next) => {
    try{  
        await MasterProduct.findByIdAndUpdate(req.params.id, req.body)
        var response = await getMaster(req.params.id)
        await update("name", req)
        await update("image", req)
        await update("category", req)
        await update("unit", req)
        await update("margin", req)
        await update("sku", req)
        await update("return", req)
        AS.updateMaster(response, req.headers["socket-id"])
        return res.status(200).json(response)
    }
    catch(e){next(e)}
})

router.post("/", verifyToken(Grants.dashboardAdmin), comprehendRole(DR.MasterRoles.create), async (req, res, next) => {
    try{  
        var prod = MasterProduct(req.body)
        await prod.save()
        var response = await getMaster(prod._id)
        AS.createMaster(response, req.headers["socket-id"])
        return res.status(201).json(response)
    }
    catch(e){next(e)}
})

module.exports = router