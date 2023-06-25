const { default: mongoose } = require("mongoose")
const { Product } = require("../../models/product")

exports.serializationSKU = [
    {$lookup: {as: "subcategory", from: "subcategories", localField: "category", foreignField: "_id", pipeline:[
        {$project:{"name":1,"image":1,"_id":1}}, 
    ]}},
    {$unwind:"$subcategory"},
    {$lookup: {as: "value", from: "productitems", localField: "_id", foreignField: "product", pipeline:[{$group: {_id: 1, value: {$sum: "$total"}}}]}},
    {$lookup: {as: "master", from: "masterproducts", localField: "master", foreignField: "_id"}},
    {$unwind: "$master"},
    {$sort:{createdAt:-1}},
    {$project:{"_id": 1, "id": 1, "margin": 1, "master_barcode": "$master.barcode", "return": 1, "master": "$master._id","master_price": "$master.price",  "master_tags": "$master.tags","verificationOutlet": 1,"verificationAdmin": 1, "name": 1, "price": 1, "sku": 1, "unit": 1, "barcode": 1, "tags": 1, "mrp": 1, "image": 1, "deactivated": 1, "master_tags": "$master.tags", "master": "$master._id", "subcategory": {"name":1,"image":1,"_id":1}, "value":{$cond:[{$eq: ["$value.value", []]}, 0, {$first: "$value.value"}]}, "remarks": 1}},
]

exports.getSKU = async (id)=>{
    var prod = await Product.aggregate([
        {$match: {_id: mongoose.Types.ObjectId(id)}},
         ...this.serializationSKU
    ])
    return prod[0]
}