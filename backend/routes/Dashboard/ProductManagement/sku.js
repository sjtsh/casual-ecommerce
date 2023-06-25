const router = require("express").Router()
const { default: mongoose } = require("mongoose")
const { Product, MasterProduct } = require("../../../models/product")
const WL = require("../../../middleware/withLength")
const { Grants } = require("../../../enums/grant")
const {verifyToken, comprehendRole, authorityWithParam} = require("../../../controllers/verifyToken")
const DR = require("../../../enums/dashboardRole")
const { SuperAdmin, DashboardAdmin } = require("../../../models/admin")
const { User } = require("../../../models/user")
const { filterQueryGet } = require("../../../middleware/ShopGrants")
const AS = require("../../../sockets/adminSocket")
const DSKU = require("../../../middleware/serialization/dashboardSKU")




router.get("/outlet/", verifyToken(Grants.dashboardAdmin), comprehendRole(DR.ProductRoles.read), async(req,res,next)=>{
    try{
        return res.status(200).json(await WL.handleQueriesWithCount(Product, req, DSKU.serializationSKU, {param: "shop"}))
    }
    catch(e) {next(e)}
})

router.get("/outlet/:id", verifyToken(Grants.dashboardAdmin), comprehendRole(DR.ProductRoles.read), authorityWithParam("id"), async(req,res,next)=>{
    try{
        return res.status(200).json(await WL.handleQueriesWithCount(Product, req, DSKU.serializationSKU, 
            {pre: [{$match: {shop: mongoose.Types.ObjectId(req.params.id)}}]}
        ))
    }
    catch(e) {next(e)}
})

router.get("/:id", async(req,res,next)=>{
    try{
        return res.status(200).json(await DSKU.getSKU(req.params.id))
    }
    catch(e) {next(e)}
})


router.put("/approve/:id", verifyToken(Grants.dashboardAdmin), comprehendRole(DR.ProductRoles.approve), async (req, res, next) => {
    try{  
        var prod = await Product.findById(req.params.id)
        if(!prod.remarks) prod.remarks = {}
        if(req.grant == Grants.superAdmin){
            prod.verificationAdmin = req.body.verificationAdmin
            var admin = await SuperAdmin.findById(req.user.id)
            var user = await User.findById(admin.user)
            prod.remarks.remarksSuperAdmin = {remarks:  req.body.remarks.remarks, by: user._id, name: user.name, phone: user.phone}
        }else{
            prod.verificationOutlet = req.body.verificationOutlet
            var admin = await DashboardAdmin.findById(req.user.id)
            var user = await User.findById(admin.user)
            prod.remarks.remarksOutletAdmin = {remarks:  req.body.remarks.remarks, by: user._id, name: user.name, phone: user.phone}
            prod.remarks.remarksSuperAdmin = {}
            prod.verificationAdmin = 1 
        }
        if(req.body.price) prod.price = req.body.price
        if(req.body.margin) prod.margin = req.body.margin
        if(req.body.barcode) prod.barcode = req.body.barcode
        await prod.save()
        AS.updateProduct(prod)
        return res.status(200).json(await DSKU.getSKU(req.params.id))
    }
    catch(e){
        console.log(e)
        
        next(e)}
})

router.post("/", verifyToken(Grants.dashboardAdmin), comprehendRole(DR.ProductRoles.create), async (req, res, next) => {
    try{ 
        var prod = Product(req.body)
        await prod.save()
        AS.createProduct(prod)
        return res.status(201).json(await DSKU.getSKU(prod._id))
    }
    catch(e){next(e)}
})

module.exports = router