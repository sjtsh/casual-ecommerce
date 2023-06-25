
const router = require("express").Router();
const G = require("../../../enums/grant")
const V = require("../../../middleware/values")
const {verifyToken} = require("../../../controllers/verifyToken");


router.get("/",  async (req, res, next)=>{
    try{
        return res.status(200).json(await V.getList())
    }
    catch(e){next(e)}
})

router.put("/", verifyToken(G.Grants.superAdmin),  async (req, res, next)=>{
    try{
        var keys = Array.from(new Map(Object.entries(req.body)).keys())
        if(!keys.length) return res.status(400).json({"message": "key is missing in the body"})
        for(var i in keys){
            if(req.body[keys[i]]){
                await V.set(keys[i], req.body[keys[i]])
            }
        }
        return res.status(200).json(await V.getList()) 
    }
    catch(e){next(e)}
})


module.exports = router