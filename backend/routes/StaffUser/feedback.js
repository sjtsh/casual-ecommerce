const mongoose = require("mongoose")
const router = require("express").Router();
const {verifyToken} = require("../../controllers/verifyToken");
const { Order, SingularOrderFeedback, RequestedShop, Rating } = require("../../models/order");
const { Shop } = require("../../models/shop");
const { User } = require("../../models/user");
const onConnection = require("../../sockets/onConnection");
const { processOrder } = require("../../middleware/change_status");
const G = require("../../enums/grant");
const { Staff } = require("../../models/admin");

router.get("/review/:id", verifyToken([G.Grants.staff]),  async (req, res, next) => {
    if(!req.query.skip) req.query.skip= 0
    if(!req.query.limit) req.query.limit= 10
    try {
        var reviews = await RequestedShop.aggregate([
            { $match: { staff: mongoose.Types.ObjectId(req.params.id), feedback: { $ne: null } } },
            // {$lookup:{
            //     from:"users",
            //      as:"user",
            //     foreignField:"_id",
            //     localField:"feedback.rating.user"
            // }},
            {$project:{
                "ratingByUser":"$feedback.rating.ratingByUser",
                "ratingByShop":"$feedback.rating.ratingByShop",
                "reviewByUser":"$feedback.rating.reviewByUser",
                "createdAt":"$feedback.rating.createdAt",
                "updatedAt":"$feedback.rating.updatedAt",
                "user":"$feedback.rating.user",
            }},
            {$lookup:{localField:"user",as:"user",from:"users",foreignField:"_id",pipeline:[{$project:{name:1}}]},},
            {$unwind:"$user"},
            {$sort: {createdAt: -1}},
            {$skip: parseFloat(req.query.skip)},
            {$limit: 10}
        ])
        var stats = await Staff.findById(req.params.id)
        if(!stats) return res.status(201).json("Could not find a staff with the following id")
        return res.status(200).json({"reviews":reviews, "stats":stats.ratingStar})
    }catch (e) {next(e)}
})
module.exports = router

