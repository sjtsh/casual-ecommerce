const router = require("express").Router()
const { LensTrack } = require("../../models/lens_track")

router.post("/", async (req, res, next) => {
    try{
        var lensTrack = LensTrack(req.body)
        await lensTrack.save()
        return res.status(200).json(true)
    }
    catch(e){next(e)}
})

router.get("/", async (req, res, next) => {
    try{
        var results = await LensTrack.aggregate([
            {
                $group:{
                    _id: { "mail": "$mail", dayOfYear: {$add: [ { $dayOfYear: "$createdAt"}, { $multiply: [400, {$year: "$createdAt"}] } ]}},
                    clickCount: {$sum: "$clickCount"},
                    model: {$first: "$model"},
                    id: {$first: "$id"},
                    location: {$first: "$location"},
                    createdAt: {$first: "$createdAt"}
                }
            },
            {$project:{_id: 0, mail: "$_id.mail", model: 1, id: 1, location: "$location.coordinates", createdAt: 1}}
        ])
        return res.status(200).json(results)
    }
    catch(e){next(e)}
})
module.exports = router