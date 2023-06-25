const router = require("express").Router()

router.get("/", async (req, res, next) => {
    try{
    return res.status(402).json({"message": "BaxAKd3lv2oS5/7IasjmMA=="})
}
catch(e){next(e)}
})

//VERSION DOCUMENTATION
//"0.0.0" -> 0 -> fLyzNzcNpfzjINY51QxizA==
// BaxAKd3lv2oS5/7IasjmMA==
module.exports = router