const { Category, SubCategory } = require("../../models/category")
const router = require("express").Router();
const {verifyToken} = require("../../controllers/verifyToken")
const {getSubCategory}=require("../../middleware/productCat")
router.post("/", verifyToken(), async (req, res, next) => {
    try{
    var category = SubCategory(req.body)
    await category.save()
    return res.status(200).json(category)
}
catch(e){next(e)}
})




router.get("/:id", async (req, res, next) => {
    try {
        var categories = await SubCategory.find({category: req.params.id});
        return res.status(200).json(categories)
    }
    catch (e) {
        next(e)
    }
})

module.exports = router