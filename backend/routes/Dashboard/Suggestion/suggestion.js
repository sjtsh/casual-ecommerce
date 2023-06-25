const router = require("express").Router()
const { default: mongoose } = require("mongoose")
const { User } = require("../../../models/user")
const { SubCategory } = require("../../../models/category")
const WL = require("../../../middleware/withLength")
const { Shop } = require("../../../models/shop")
const { Staff } = require("../../../models/admin")
const { Grants } = require("../../../enums/grant")
const {verifyToken, comprehendRole, authorityWithParam} = require("../../../controllers/verifyToken")
const DR = require("../../../enums/dashboardRole")
const SG = require("../../../middleware/ShopGrants")
const { Product } = require("../../../models/product")
const { Order } = require("../../../models/order")
const { ProductSuggestion } = require("../../../models/productSuggestion")
const DSuggestion = require("../../../middleware/serialization/dashboardSuggestion")


router.get("/", verifyToken(Grants.superAdmin), async(req,res,next)=>{
    try{
        return res.status(200).json(await WL.handleQueriesWithCount(ProductSuggestion, req, [
            ...DSuggestion.serialization
        ]))
    }
    catch(e) {next(e)}
})

module.exports = router