const router = require("express").Router()
const { verifyToken } = require("../../controllers/verifyToken")
const { Grants } = require("../../enums/grant")
const { Banner } = require("../../models/banner")


const fields = ["_id", "id", "offsetX", "offsetY", "gridSpace", "img", "redirectUrl", "detail", "title", "colors", "foreign", "group","titleColor","orientation","onlyImage" ]

const projectFromFields = (fields)=>{
    var query = {}
    for(var i in fields){
        query[fields[i]] = 1   
    }
    return query
}

const serializationBanner =  [
    {$project: projectFromFields(fields)}
]

//TODO: router.get("/:group", verifyToken([G.Grants.user]), async(req,res,next)=>{
router.get("/:group", async(req,res,next)=>{
    try{
        var banners = await Banner.aggregate([ 
                {$match: {group: req.params.group, deactivated: {$ne: true}}},
                ...serializationBanner,
            ],
        )
        return res.status(200).json(banners)
    }
    catch(e) {next(e)}
})

module.exports = router