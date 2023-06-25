
const router = require("express").Router();
const G = require("../../../enums/grant")
const MV = require("../../../middleware/maintainanceValues")
const {verifyToken} = require("../../../controllers/verifyToken");
const { MaintainanceValues } = require("../../../models/maintainanceValues");


router.get("/",  async (req, res, next)=>{
    try{
        return res.status(200).json(await MV.getList())
    }
    catch(e){next(e)}
})


router.put("/",   async (req, res, next)=>{
    try{
        var keys = Array.from(new Map(Object.entries(req.body)).keys())
        var response = []
        if(!keys.length) return res.status(400).json({"message": "key is missing in the body"})
        for(var i in keys){
            if(req.body[keys[i]]){
                var rightNow = new Date()
                var when =  req.body[keys[i]].when
                var howLong = req.body[keys[i]].howLong
                if(howLong){
                    var to = new Date( new Date(when).setMilliseconds(new Date(when).getMilliseconds() + howLong))
                    if(new Date(to) <= new Date(rightNow)){
                        return res.status(400).json({"message": "Your maintainance has already ended"})
                    }
                }
                await MV.start(keys[i], req.body[keys[i]].when, req.body[keys[i]].howLong, rightNow)
                response.push(await MV.getOne(keys[i]))
            }
        }
        return res.status(200).json(response) 
    }
    catch(e){next(e)}
})

router.delete("/", verifyToken(G.Grants.superAdmin),  async (req, res, next)=>{
    try{
        var keys = Array.from(new Map(Object.entries(req.body)).keys())
        if(!keys.length) return res.status(400).json({"message": "key is missing in the body"})
        for(var i in keys){
            if(req.body[keys[i]]){
                await MV.cancel(keys[i])
            }
        }
        return res.status(200).json(await MV.getList()) 
    }
    catch(e){next(e)}
})


module.exports = router