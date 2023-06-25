const router = require("express").Router()
const { Product, MasterProduct } = require("../../models/product")
const { Category, SubCategory } = require("../../models/category")
const OR = require("../../enums/outletRole")
const G = require("../../enums/grant")
const { verifyToken, comprehendRole, comprehendOrRole } = require("../../controllers/verifyToken")
const {search}=require("../../middleware/search")
const Unit =require("../../enums/unit")
const { User } = require("../../models/user")
const { Staff } = require("../../models/admin")
const { maxConcurrency } = require("agenda/dist/agenda/max-concurrency")
const { default: mongoose } = require("mongoose")
const product = require("../../models/product")
const { emitProductDeactivatedStatus } = require("../../sockets/staffUserSocket")
const AS = require("../../sockets/adminSocket")

const SC = require("../../middleware/speedCheck")

const personalFilter = (tags, tag) => {
    var newtags = []
    var found = false
    for(var i in tags){
        if(tags[i] == tag && !found){
            newtags.push(tags[i])
        }
    }
    return newtags;
}

//remarks is only mandatory when deactivated or editing, not when activating the already approved product

router.put("/deactivate/:id", verifyToken([G.Grants.staff]), async (req, res, next) => {
    try{
        var staff = await Staff.findById(req.user.id)
        var user = await User.findById(staff.user)
        var product = await Product.findById(req.params.id)
        if(!product) return res.status(400).json({"message":"Sorry the product could not be found"})
        deactivate = req.query.deactivated == 1 ? true : false
        product.deactivated = deactivate        
        var possibleRemarks = {remarksStaff: {remarks:req.body.remarks, by: req.user.id, phone: user.phone, name: user.name}, remarksStaffReferenceUrl:  req.body.reference}
        product.remarks = possibleRemarks
        await product.save()
        emitProductDeactivatedStatus({"_id":product._id,"deactivated":deactivate})
        AS.updateProductFromID(req.params.id)
        return res.status(200).json(product)
    }
    catch(e){next(e)}
})

router.put("/:id", verifyToken([G.Grants.staff]), async (req, res, next) => {
    try{
        var staff = await Staff.findById(req.user.id)
        var user = await User.findById(staff.user)
        var possibleRemarks = {remarksStaff: {remarks:req.body.remarks, by: req.user.id, phone: user.phone, name: user.name}, remarksStaffReferenceUrl:  req.body.reference}
        var product = await Product.findById(req.params.id)
        if(!product) return res.status(400).json({"message":"Sorry the product could not be found"})
        
        var name = product.name
        var barcode = product.barcode
        var tags = product.tags
        req.body.deactivated = false
        req.body.verificationOutlet = 1
        req.body.verificationAdmin = 1
        req.body.remarks = possibleRemarks
        await Product.findByIdAndUpdate(req.params.id, req.body)
        var mas = await MasterProduct.findById(product.master)

        //search master by product names
        for(var i in tags){
            mas.tags = personalFilter(mas.tags, tags[i])
        }
        mas.tags = personalFilter(mas.tags, name)
        mas.tags = personalFilter(mas.tags, barcode)
        mas.tags.push(req.body.barcode) 
        mas.tags.push(req.body.name)

        mas.tags = mas.tags.concat(req.body.tags)

        await mas.save()
        product = await Product.findById(req.params.id)
        AS.updateProductFromID(req.params.id)
        return res.status(200).json(product)
    }
    catch(e){next(e)}
})


router.delete("/:id", verifyToken([G.Grants.staff]), async (req, res, next) => {
    try{
        var prod = await Product.findById(req.params.id)
        if(!prod) return res.status(400).json({"message": "could not find product"})

        var mas = await MasterProduct.findById(prod.master)
        mas.tags = personalFilter(mas.tags, prod.name)
        mas.tags = personalFilter(mas.tags, prod.barcode)
        for(var i in prod.tags){
            mas.tags = personalFilter(mas.tags, prod.tags[i])
        }
        await mas.save()
        await Product.findByIdAndUpdate(req.params.id, {deactivated: true})
        AS.updateProductFromID(req.params.id)
        return res.status(200).json("success")
    }
    catch(e){next(e)}
})

router.post("/", verifyToken([G.Grants.staff]), async (req, res, next) => {
    try{
        if(!req.query.shop) return res.status(400).json("Please determine the shop")
        var staff = await Staff.findById(req.user.id)
        var user = await User.findById(staff.user)
        req.body.staff = staff._id
        var masterproduct = MasterProduct(req.body)

        //search master by product names in case name of master product gets changed, product should still be searchable
        masterproduct.tags.push(masterproduct.name)
        masterproduct.tags.push(masterproduct.barcode)
        await masterproduct.save()

        req.body.master = masterproduct._id
        req.body.shop = mongoose.Types.ObjectId(req.query.shop)
        req.body.staff = staff._id
        if(req.body.remarks && req.body.remarks != ""){
            req.body.remarks = {remarksStaff: {remarks:req.body.remarks, by: req.user.id, phone: user.phone, name: user.name}, remarksStaffReferenceUrl:  req.body.reference}
        }else{
            delete req.body.remarks
        }
        var product = Product(req.body)
        await product.save()
        AS.createProductFromID(product._id)
        
        return res.status(200).json(product)
    }
    catch(e){next(e)}
})

router.post("/:id", verifyToken([G.Grants.staff]),  async (req, res, next) => {
    try{
        if(!req.query.shop) return res.status(400).json("Please determine the shop")
        var staff = await Staff.findById(req.user.id)
        var user = await User.findById(staff.user)
        req.body.master = req.params.id
        req.body.shop = mongoose.Types.ObjectId(req.query.shop)
        req.body.staff = staff._id
        if(req.body.remarks && req.body.remarks != ""){
            req.body.remarks = {remarksStaff: {remarks:req.body.remarks, by: req.user.id, phone: user.phone, name: user.name}, remarksStaffReferenceUrl:  req.body.reference}
        }else{
            delete req.body.remarks
        }
        var product = Product(req.body)
        await product.save()
        var prod = await Product.find({master: product.master, shop: product.shop })
        if(prod.length > 1){
            await Product.findByIdAndDelete(product._id)
            return res.status(400).json({"message": "Sorry the product for this master has already been created"})
        }
        //search master by product names
        var mas = await MasterProduct.findById(req.params.id)
        mas.tags.push(product.name)
        mas.tags.push(product.barcode)
        await mas.save()
        AS.createProductFromID(product._id)

        return res.status(200).json(product)
    }
    catch(e){next(e)}
})

// comprehendOrRole([OR.ProductRoles.create, OR.ProductRoles.update]
router.get("/unit", verifyToken([G.Grants.staff,G.Grants.dashboardAdmin] ), async (req, res, next) => {
    try{
    return res.status(200).json(Unit.all)
    }
    catch(e){next(e)}
})

router.get("/subcategory",  verifyToken([G.Grants.staff,G.Grants.dashboardAdmin]), async (req, res, next) => {
    try {return res.status(200).json(await SubCategory.aggregate([{$match: {deactivated: {$ne: true}}}]))}
    catch (e) {
        next(e)
    }
})




router.get("/count", verifyToken([G.Grants.staff]), async (req, res, next) => {
    try{
        if(!req.query.shop) return res.status(400).json("Please determine the shop")
        if(!req.query.approved) req.query.approved = "1.2.3"
        var statusFilter = [{"$match": {"$or": req.query.approved.split(".").map((element) => {return {"verificationAdmin": parseInt(element)}})}}]
        // var prodActivated0 = await MasterProduct.aggregate([
        //     ...(await activatedSerialization(req)),
        //     {$group: {_id: "_id", count: {$sum: 1} }}
        // ])
        // var prodActivated1 = await MasterProduct.aggregate([
        //     ...(await activatedSerialization(req)),
        //     {$group: {_id: "_id", count: {$sum: 1} }}
        // ])
        var staff = (await Staff.aggregate([{$match: {_id: mongoose.Types.ObjectId(req.user.id)}}]))[0]
        staff.shop = mongoose.Types.ObjectId(req.query.shop)
        req.query.activated = 0
        var commong =  [ {$group: {_id: "$master"}}, {$lookup: {as: "master",from: "masterproducts", localField: "_id", foreignField: "_id", pipeline: [{$match: {verificationAdmin: 2}}]}}, {$unwind: "$master"}]
        var allProducts = await Product.aggregate([{$match: { shop: staff.shop }},...commong]) //allprods available activated or deactivated
        var productsFilterFalse = await Product.aggregate([{$match: { shop: staff.shop, deactivated: false}}, ...statusFilter,...commong]) //all available activated with filter
        var productsFilterTrue = await Product.aggregate([{$match: { shop: staff.shop, deactivated: true}}, ...statusFilter,...commong]) //all available deactivated with filter
        var masters = await MasterProduct.aggregate([{$match: {verificationAdmin: 2 }}]) //total prods

        var allProductNeverActivated = masters.length - allProducts.length
        var activatedProductCount = productsFilterFalse.length
        var deactivatedProductCount = productsFilterTrue.length
        if(req.query.approved.split(".").includes("1")) deactivatedProductCount += allProductNeverActivated
        var results = {activated: activatedProductCount, deactivated: deactivatedProductCount}
        console.log(results, req.query)
        return res.status(200).json(results)
    }
    catch(e){
        next(e)
    }
})


router.get("/subs", verifyToken([G.Grants.staff]), async (req, res, next) => {
    try{
        return await SC.logIt(
            async ()=>{
                if(!req.query.shop) return res.status(400).json("Please determine the shop")
                if(!req.query.skip) req.query.skip = "0"
                if(!req.query.limit) req.query.limit = "2000"
                var prods1
                var staff = (await Staff.aggregate([{$match: {_id: mongoose.Types.ObjectId(req.user.id)}}]))[0]
                staff.shop = mongoose.Types.ObjectId(req.query.shop)
                var midQueries = generateMatchqAndMidQueries(req)
                var prods
                
                var statuses
                if(req.query.approved) statuses = req.query.approved.split(".").map((element) => {return parseInt(element)})
                if(((statuses && statuses.includes(1)) || !statuses) && req.query.activated == false){
                    if(!statuses) statuses = [1,2,3]
                    var prodsShop = await Product.aggregate([{$match: {shop: staff.shop}}])
                    var masterShop = await MasterProduct.aggregate([{$match: {verificationAdmin:2}},])
                    var categories = await SubCategory.aggregate([{$project: {name: 1,image:1,id: 1}},])
        
                    var prodMap =  new Map()
                    var categoryMap = new Map()
        
                    for(var i in prodsShop){
                        prodMap.set(prodsShop[i].master.toString(), [prodsShop[i]])
                    }
                    for(var i in categories){
                        categoryMap.set(categories[i]._id.toString(), categories[i])
                    }
                    for(var i in masterShop){
                        var prod =  prodMap.get(masterShop[i]._id.toString())
                        if(prod) masterShop[i].product = prod
                        else masterShop[i].product = []
                    }
                    var status0 = statuses.includes(0)
                    var status2 = statuses.includes(2)
                    for(var i in masterShop){
                        var bool1 = true
                        var bool2 = true
                        if(masterShop[i].product.length != 0){
                            bool1 = masterShop[i]["product"][0]["deactivated"] == true
                            if( status0 && status2) {
                                // [ { '$match': { '$or': [ { 'product.0.deactivated': true }, { product: [] } ] } },{ '$match': { '$or': [{ 'product.0.verificationAdmin': 1 }, { 'product.0.verificationAdmin': 2 }, { product: [] }, ] } } ]
                                var bool2 = masterShop[i]["product"][0]["verificationAdmin"] == 1 || masterShop[i]["product"][0]["verificationAdmin"] == 2 || masterShop[i]["product"][0]["verificationAdmin"] == 0
                            }else if(status2){
                                //[ { 'product.0.deactivated': true }, { product: [] } ] [{ 'product.0.verificationAdmin': 1 },{ product: [] },{ 'product.0.verificationAdmin': 2 } ]
                                var bool2 = masterShop[i]["product"][0]["verificationAdmin"] == 1 || masterShop[i]["product"][0]["verificationAdmin"] == 2
                            }else if(status0){ 
                                //[{ 'product.0.verificationAdmin': 1 },{ product: [] }{ '$or': [ [{ 'product.0.verificationOutlet': 0 },{ 'product.0.verificationAdmin': 0 } ] }, ]
                                var bool2 = masterShop[i]["product"][0]["verificationAdmin"] == 1 || masterShop[i]["product"][0]["verificationAdmin"] == 0 || masterShop[i]["product"][0]["verificationOutlet"] == 0
                            }else{
                                var bool2 = masterShop[i]["product"][0]["verificationAdmin"] == 1
                                //[ { 'product.0.verificationAdmin': 1 }, { product: [] } ]
                            }
                        }
                        if(bool1 && bool2){
                            var cat = masterShop[i].category.toString()
                            var maybe = categoryMap.get(cat)
                            if(!maybe.skuCount) maybe.skuCount = 1
                            else maybe.skuCount += 1
                            categoryMap.set(cat, maybe)
                        }                
                    }
                    var categories = Array.from(categoryMap.values()).filter((e)=> e.skuCount)
                    var skip = parseInt(req.query.skip)
                    var end = parseInt(req.query.limit) + skip
                    if(end > categories.length) end = categories.length
                    prods = categories.slice(skip, end)
                }else{
                    prods = await Product.aggregate([
                        {$match: {shop: staff.shop}}, 
                        {$lookup: {as: "masterproduct", from: "masterproducts", localField: "master", foreignField: "_id", pipeline: [{$match: {verificationAdmin:2}},]}},
                        {$unwind: "$masterproduct"},
                        {$group: {_id: "$masterproduct._id",category: {$first: "$category"},
                            product: {$push: {_id: "$_id", verificationAdmin: "$verificationAdmin", verificationOutlet: "$verificationOutlet", deactivated:"$deactivated"} }
                        }},
                        ...midQueries,
                        {$group: {_id: "$category", count: {$sum: 1} }},
                        {$sort: {_id: 1}},
                        {$skip: parseInt(req.query.skip)}, 
                        {$limit: parseInt(req.query.limit)},
                        {$lookup: {as: "category", from: "subcategories", localField: "_id", foreignField: "_id", pipeline: [{$project: {name: 1,image:1,id: 1}},]}},
                        {$unwind: "$category"},
                        {$project: {name:"$category.name", image:"$category.image", id:"$category.id", skuCount: "$count"}}
                    ])
                }
                return res.status(200).json(prods)
            }, 
            [req.originalUrl, "on", "Staff -> { Subgroups }"]
        )
    }
    catch(e){next(e)}
})


const activatedSerialization = async (req)=>{
    var midQueries = generateMatchqAndMidQueries(req)
    var initialMatch = {deactivated: {$ne: true}}
    if(req.params.id) initialMatch.category = mongoose.Types.ObjectId(req.params.id)
    return [
        {$match: initialMatch},
        {$lookup: {as: "product", from: "products", localField: "_id", foreignField: "master", pipeline: [                    
            {$match: {shop: mongoose.Types.ObjectId(req.query.shop)}}, 
        ]}},
        ...midQueries,
    ]
}
router.get("/subs/:id", verifyToken([G.Grants.staff]), async (req, res, next) => {
    try{
        if(!req.query.shop) return res.status(401).json({"message": "Please use a later version"})
        if(!req.params.id) return res.status(401).json({"message": "Please use a later version"})
        if(!req.query.skip) req.query.skip = "0"
        if(!req.query.limit) req.query.limit = "2000"
        var queries = await activatedSerialization(req)
        var prods = await MasterProduct.aggregate([
            ...queries,
            {$sort: {updatedAt: -1}},
            {$skip: parseInt(req.query.skip)},
            {$limit: parseInt(req.query.limit)},
        ])
        return res.status(200).json(prods)
    }
    catch(e){next(e)}
}) 


router.get("/search",verifyToken([G.Grants.staff]),  comprehendOrRole([OR.ProductRoles.read]), async (req, res, next) => {
    try {
        var skip = 0
        var limit = 200
        if(!req.query.shop) return res.status(400).json("Please determine the shop")
        if(req.query.skip) skip = parseInt(req.query.skip)
        if(req.query.limit) limit = parseInt(req.query.limit)
        if (req.query.s) {
            var products = await search(MasterProduct, req.query.s,  [
                {$match: {deactivated: {$ne: true}}},
                {$sort: {createdAt: -1}},
                {$skip: skip},
                {$limit: limit},
                {$lookup: {as: "product", from: "products", localField: "_id", foreignField: "master", pipeline: [
                    {$match: {shop:  mongoose.Types.ObjectId(req.query.shop)}}
                ]}},
                {$lookup: {as: "category_info", from: "subcategories",localField: "category",foreignField:"_id", pipeline:[{$project:{name:1, _id:0}}]}},
                {$unwind: "$category_info"}
            ])
            return res.status(200).json(products)
        }
        else
            return res.status(400).json({ "message": "Invalid search query" })
    }
    catch (e) {
        console.log(e)
        next(e)
    }

})

router.get("/searchglobal", async (req, res, next) => {
    try {
        if(!req.query.skip) req.query.skip = 0
        if(!req.query.limit) req.query.limit = 200
        if (req.query.s) {
            var products = await search(MasterProduct, req.query.s,  [{$limit: 200}])
            return res.status(200).json(products)
        }
        else
            return res.status(400).json({ "message": "Invalid search query" })
    }
    catch (e) {
        console.log(e)
        next(e)
    }

})

const generateMatchqAndMidQueries = (req)=>{
    var midQueries = []
    var statuses
    if(req.query.approved) statuses = req.query.approved.split(".").map((element) => {return parseInt(element)})
    var matchOrSegment = []
    var shouldUnwind = false
    if(statuses){
        var rej = statuses.includes(0)
        var pend = statuses.includes(1)
        var app = statuses.includes(2)
        if(rej) matchOrSegment.push({$or: [{"product.0.verificationOutlet": 0},{"product.0.verificationAdmin": 0}]})
        if(pend){
            if(req.query.activated == 0) {
                matchOrSegment.push({"product.0.verificationAdmin": 1}),
                matchOrSegment.push({product: []})
            }else{
                matchOrSegment.push({"product.0.verificationAdmin": 1})
            }
        }else{
            if( rej || app) shouldUnwind = true
        }
        if(app) matchOrSegment.push({"product.0.verificationAdmin": 2})
    }
    if(req.query.activated == 0) midQueries.push({$match: {$or: [{"product.0.deactivated": true}, {product: []}]}},)
    if(req.query.activated == 1) {
        shouldUnwind = true
        midQueries.push({$match: {"product.0.deactivated": {$ne: true}}})
    } 
    if(matchOrSegment.length) midQueries.push({$match: {$or: matchOrSegment}})
    if(shouldUnwind) midQueries.push({$unwind: "$product"})
    
    return midQueries
}

module.exports = router