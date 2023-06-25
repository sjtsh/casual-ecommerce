const router = require("express").Router()
const { default: mongoose } = require("mongoose")
const { Product } = require("../../../models/product")
const { SubCategory, Category } = require("../../../models/category")
const WL = require("../../../middleware/withLength")
const {verifyToken, comprehendRole} = require("../../../controllers/verifyToken")
const DR = require("../../../enums/dashboardRole")

const AS = require("../../../sockets/adminSocket")
const { Grants } = require("../../../enums/grant")
const { getSubCategory } = require("../../../middleware/nearbyShop")
const { Banner } = require("../../../models/banner")

const BR = require("../../../enums/banner");
const fields = ["_id", "id", "offsetX", "offsetY", "gridSpace", "img", "redirectUrl", "detail", "title", "colors", "foreign", "createdAt", "updatedAt", "deactivated","group","titleColor","orientation","onlyImage" ]
const { emitBannerUpdate } = require("../../../sockets/staffUserSocket")

const serializationBanner =  [
    {$project: WL.serializerProject(fields)}
]

const getBanner = async (id) => {
    var banner = await Banner.aggregate([
        {$match: {_id : mongoose.Types.ObjectId(id)}},
        ...serializationBanner
    ])
    return banner[0]
}

router.get("/", verifyToken(Grants.superAdmin), async(req,res,next)=>{
    try{
        var results = await WL.handleQueriesWithCount(Banner, req, serializationBanner)
        return res.status(200).json(results)
    }
    catch(e) {next(e)}
})

router.put("/:id",verifyToken(Grants.superAdmin), async (req, res, next) => {
    try{  
        var banner  = await Banner.findById(req.params.id)
        if(!banner)  return res.status(400).json({"message": "could not find banner"})
        await Banner.findByIdAndUpdate(req.params.id, req.body)
        banner = await getBanner(req.params.id)
           
        var data={...req.body,"_id":banner._id,"foreign":banner.foreign,"group":banner.group}
        if(req.body.deactivated!=null){
            if(req.body.deactivated) emitBannerUpdate(data)
            else emitBannerUpdate(banner)
        } else emitBannerUpdate(data)
        AS.updateBanner(banner, req.headers["socket-id"])
        
        return res.status(200).json(banner)
    }
    catch(e){next(e)}
})

router.post("/", verifyToken(Grants.superAdmin), async (req, res, next) => {
    try{ 
        var banner = Banner(req.body)
        await banner.save()
        banner = await getBanner(banner._id)
        emitBannerUpdate(banner)
        AS.createBanner(banner, req.headers["socket-id"])
        return res.status(201).json(banner)
    }
    catch(e){next(e)}
})


module.exports = router