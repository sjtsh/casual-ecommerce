const router = require("express").Router()
const { Category } = require("../models/category")
const { Product } = require("../models/product")
const { SubCategory } = require("../models/category")

//--body--
//{category: {id: ["tag_strings"]}, subCategory: {id: ["tag_strings"]}, product: {id: ["tag_strings"]}}

router.post("/", async (req, res, next) => {
    try{
        var categoryTags = req.body.category
        var subCategoryTags = req.body.subCategory
        var productTags = req.body.product
        
        categoryTags=  new Map(Object.entries(categoryTags))
        if(categoryTags && categoryTags.size){
            var keys = Array.from(categoryTags.keys())
            for(var i in keys){
                var category = await Category.findById(keys[i])
                category.tags.push(...categoryTags.get(keys[i]))
                await category.save()
            }
        }
        subCategoryTags=  new Map(Object.entries(subCategoryTags))
        if(subCategoryTags && subCategoryTags.size){
            var keys = Array.from(subCategoryTags.keys())
            for(var i in keys){
                var category = await SubCategory.findById(keys[i])
                category.tags.push(...subCategoryTags.get(keys[i]))
                await category.save()
            }
        }
        productTags=  new Map(Object.entries(productTags))
        if(productTags && productTags.size){
            var keys = Array.from(productTags.keys())
            for(var i in keys){
                var category = await Product.findById(keys[i])
                category.tags.push(...productTags.get(keys[i]))
                await category.save()
            }
        }
        return res.status(200).json("success")
    }
    catch(e){
        next(e)
    }
})

//VERSION DOCUMENTATION
//"0.0.0" -> 0 -> fLyzNzcNpfzjINY51QxizA==
// BaxAKd3lv2oS5/7IasjmMA==
module.exports = router