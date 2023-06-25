const router = require("express").Router()
const { default: mongoose } = require("mongoose")
const { Product } = require("../../../models/product")
const { SubCategory, Category } = require("../../../models/category")
const WL = require("../../../middleware/withLength")
const {verifyToken, comprehendRole} = require("../../../controllers/verifyToken")
const DR = require("../../../enums/dashboardRole")

const { Grants } = require("../../../enums/grant")
const { getSubCategory } = require("../../../middleware/nearbyShop")
const AS = require("../../../sockets/adminSocket")

// const serializationCategory =  [
//     {$lookup: {as: "value", from: "subcategories", localField: "_id", foreignField: "category", pipeline: [
//         {$lookup: {as: "value", from: "products", localField: "_id", foreignField: "category", pipeline: [
//             {$lookup: {as: "value", from: "productitems", localField: "_id", foreignField: "product", pipeline:[
//                 {$group: {_id: 1, value: {$sum: "$total"}}},
//             ]}},
//             {$unwind: "$value"},
//             {$group: {_id: 1, value: {$sum: {$sum: "$value.value"}}}},
//         ]}},
//         {$unwind: "$value"},
//         {$group: {_id: 1, value:{$sum: "$value.value"}}}
//     ]}},
//     {$project: {"_id": 1, "id": 1, "name": 1, "image": 1, "deactivated": 1, "value": {$cond: [{$ne: ['$value', []]}, {$first: "$value"}, 0 ]}, "createdAt": 1}},
//     {$project: {"_id": 1, "id": 1, "name": 1, "image": 1, "deactivated": 1, "value": {$cond: [{$ne: ['$value', 0]}, "$value.value", 0 ]}, "createdAt": 1}}
// ]
const serializationCategory =  [
    {$lookup: {as: "value", from: "productitems", localField: "_id", foreignField: "category", pipeline:[{$group: {_id: 1, value: {$sum: "$total"}}}]}},
    {$project: {"_id": 1, "id": 1, "name": 1, "image": 1, "deactivated": 1, "value":{$cond:[{$eq: ["$value.value", []]}, 0, {$first: "$value.value"}]}, "createdAt": 1}},
]

const getCategory = async (id) => {
    var categories = await Category.aggregate([
        {$match: {_id : mongoose.Types.ObjectId(id)}},
        ...serializationCategory
    ])
    return categories[0]
}

router.get("/", verifyToken(Grants.dashboardAdmin), comprehendRole(DR.CategoriesRoles.read), async(req,res,next)=>{
    try{
        var results = await WL.handleQueriesWithCount(Category, req, serializationCategory)
        return res.status(200).json(results)
    }
    catch(e) {next(e)}
})


router.put("/:id", verifyToken(Grants.dashboardAdmin), comprehendRole(DR.CategoriesRoles.update), async (req, res, next) => {
    try{  
        var category  = await Category.findById(req.params.id)
        if(!category)  return res.status(400).json({"message": "could not find category"})
        await Category.findByIdAndUpdate(req.params.id, req.body)
        category = await getCategory(req.params.id)
        AS.updateCategory(category, req.headers["socket-id"])
        return res.status(200).json(category)
    }
    catch(e){next(e)}
})

router.post("/", verifyToken(Grants.dashboardAdmin), comprehendRole(DR.CategoriesRoles.create), async (req, res, next) => {
    try{ 
        var category = Category(req.body)
        await category.save()
        category = await getCategory(category._id)
        AS.createCategory(category, req.headers["socket-id"])
        return res.status(201).json(category)
    }
    catch(e){next(e)}
})

module.exports = router