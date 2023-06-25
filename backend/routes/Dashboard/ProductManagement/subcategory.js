const router = require("express").Router()
const { default: mongoose } = require("mongoose")
const { Product } = require("../../../models/product")
const { SubCategory, Category } = require("../../../models/category")
const WL = require("../../../middleware/withLength")
const { Grants } = require("../../../enums/grant")
const {verifyToken, comprehendRole} = require("../../../controllers/verifyToken")
const DR = require("../../../enums/dashboardRole")
const B = require("../../../enums/banner")
const AS = require("../../../sockets/adminSocket")



// const serializationSubgroup = [
//     {$lookup: {as: "value", from: "products", localField: "_id", foreignField: "category", pipeline:[
//         {$lookup: {as: "value", from: "productitems", localField: "_id", foreignField: "product", pipeline:[{$group: {_id: 1, value: {$sum: "$total"}}}]}},
//         {$unwind: "$value"},
//         {$group: {_id: 1, value: { $sum: "$value.value"}}}
//     ]}},
//     {$lookup: {as: "banners", from:"banners", localField:"_id", foreignField: "foreign", pipeline: [
//         {$match: {deactivated: {$ne: true}}},
//         { $project: {__v: 0, createdAt: 0, updatedAt: 0}}
//     ]}},
//     {$lookup: {as: "category", from: "categories", localField: "category", foreignField: "_id", pipeline:[{$project: {_id: 1, name: 1, id: 1, image: 1}}]}},
//     {$unwind: "$category"},
//     {$project:{"_id": 1, "id": 1, "name": 1, "image": 1, "category": 1, "deactivated": 1, "banners": 1, "value":{$cond:[{$eq: ["$value.value", []]}, 0, {$first: "$value.value"}]}, "createdAt": 1}},
// ]

const serializationSubgroup =  [
    {$lookup: {as: "value", from: "productitems", localField: "_id", foreignField: "subcategory", pipeline:[{$group: {_id: 1, value: {$sum: "$total"}}}]}},
    {$lookup: {as: "banners", from:"banners", localField:"_id", foreignField: "foreign", pipeline: [
        {$match: {deactivated: {$ne: true}}},
        { $project: {__v: 0, createdAt: 0, updatedAt: 0}}
    ]}},
    {$lookup: {as: "category", from: "categories", localField: "category", foreignField: "_id", pipeline:[{$project: {_id: 1, name: 1, id: 1, image: 1}}]}},
    {$unwind: "$category"},
    {$project:{"_id": 1, "id": 1, "name": 1, "image": 1, "category": 1, "deactivated": 1, "banners": 1, "value":{$cond:[{$eq: ["$value.value", []]}, 0, {$first: "$value.value"}]}, "createdAt": 1}},

]

router.get("/category", verifyToken(Grants.dashboardAdmin), comprehendRole(DR.SubCategoriesRoles.create), async (req, res, next) => {
    try{  
        var category = await Category.aggregate([{$match: {deactivated: {$ne: null}}},{$project:{_id: 1, id: 1, name: 1}}])
        return res.status(200).json({"data": category, "count": 0})
    }
    catch(e){next(e)}
})

router.get("/", verifyToken(Grants.dashboardAdmin), async(req,res,next)=>{
    try{
        return res.status(200).json(await WL.handleQueriesWithCount(SubCategory, req, serializationSubgroup))
    }
    catch(e) {next(e)}
})

const getSubcategory = async(id) => {
    var respon = await SubCategory.aggregate([
        {$match: {_id: mongoose.Types.ObjectId(id.toString())}},
        ...serializationSubgroup,
    ])
    if(respon.length) return respon[0]
    return {"message":"could not find the subcategory"}
}

router.put("/:id", verifyToken(Grants.dashboardAdmin), comprehendRole(DR.SubCategoriesRoles.update), async (req, res, next) => {
    try{  

        await SubCategory.findByIdAndUpdate(req.params.id, req.body)
        var updatedSubcategory= await getSubcategory(req.params.id)
        AS.updateSubcategory(updatedSubcategory, req.headers["socket-id"])
        return res.status(200).json(updatedSubcategory)
    }
    catch(e){next(e)}
})

router.post("/", verifyToken(Grants.dashboardAdmin), comprehendRole(DR.SubCategoriesRoles.create), async (req, res, next) => {
    try{ 
        var cat = SubCategory(req.body)
        await cat.save()
        var createdSubcategory= await getSubcategory(cat._id)
        AS.createSubcategory(createdSubcategory, req.headers["socket-id"])
        return res.status(201).json(createdSubcategory)
    }
    catch(e){next(e)}
})

module.exports = router