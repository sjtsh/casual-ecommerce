const { Category } = require("../../models/category")
const router = require("express").Router();
const {verifyToken} = require("../../controllers/verifyToken")
const { Shop } = require("../../models/shop");
const {getSubCategory, trending}=require("../../middleware/productCat")

const subcategories = require("./subcategory");
const test = require("../../models/test");

router.post("/", verifyToken(), async (req, res, next) => {
    try{
    var category = Category(req.body)
    await category.save()
    return res.status(200).json(category)}catch(e){
        next(e)
    }
})


router.get("/", async (req, res, next) => {
    try {
        var categories = await Category.find();
        return res.status(200).json(categories)
    }
    catch (e) {
        next(e)
    }
})

router.get("/nearby", async (req, res, next) => {

try{
    var categories=[]
const sphere = true
const shops = await Shop.aggregate([{
        $geoNear: {
            near: {
                type: "Point",
                coordinates: [parseFloat(req.query.lon),parseFloat(req.query.lat) ]
            },
            spherical: sphere,
            maxDistance: 3000,
            distanceField: 'distance',
            query: {
                available: true,
                categories: {$not:{$size:0}}
            },
            // distanceMultiplier:1.141
        },
    },
    {$lookup:{
        foreignField: "_id",
        localField: "categories",
        as: "categories",
        from: "categories",
        // pipeline:[
        //   {  $lookup:{
        //         foreignField:'_id',
        //         localField:"categories",
        //         as:"subcategory",
        //         from:"subcategories"
                
        //     }}
        // ]
       
    }},
 {$project:{  phone:1,canDeliver: { $lte: ["$distance", "$deliveryRadius"] },
 categories:1}}
    //  {
    //     $match: { 

    //         deliveryRadius:{$gt:0}
    //         // deliveryRadius: {$gt: "$distance"}
    //     }
    // },
    // {
    //     $match: {

    //         // $or: [{$and: [{distance : {$lte: 1000}}, {deliveryRadius: null}]}, ]
    //     }
    // },
  
    

])
var categories=[];
var categoriesId=[];

 shops.filter(function(value, index, arr) {
    if(value.canDeliver)
   {
    value.categories.forEach(element => {
      
        if(categories.findIndex(e=>e._id.toString()==element._id.toString())==-1)
      {  categories.push(element)
            categoriesId.push(element._id.toString())
    }   
    });
   
    return
   } 
    
})

 var sub= await getSubCategory(categoriesId) 
 var subId=[];
 subId.forEach(element=>{
        subId.push(element._id.toString())
 })

 var trend= await trending(subId)

return  res.status(200).json({"categories":categories,"subcategories":sub,"trending":trend})
   
  
     
  


// shops.forEach(element => {
            
//     categories.push(...element.categories)
// });
      
//      return res.status(200).json(categories)
}
catch(e)
{
    console.log(e)
    next(e)
}

})

module.exports = router