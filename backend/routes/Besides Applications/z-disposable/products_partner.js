const router = require("express").Router()
const { Product } = require("../../models/product")

router.put("/:id", async (req, res, next) => {
    try{
    var product = await Product.findByIdAndUpdate(req.params.id, req.body)
    return res.status(200).json(product)
    }
    catch(e){next(e)}
})

router.get("/:id", async (req, res, next) => {
    try{
    var product = await Product.findById(req.params.id)
    return res.status(200).json(product)
    }
    catch(e){next(e)}
})


router.post("/", async (req, res, next) => {
    try{
        var product = Product(req.body)
        await product.save()
        return res.status(200).json(product)
    }
    catch(e){next(e)}
})

module.exports = router