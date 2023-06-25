const mongoose = require("mongoose")
const {User, Address, Device} =require ("../../models/user")
const router = require("express").Router();
const {verifyToken} =require("../../controllers/verifyToken")
const CryptoJS = require("crypto-js")
const {search}=require("../../middleware/search")
const G = require("../../enums/grant")

router.get("/",  verifyToken([G.Grants.user]),  async (req, res, next) => {
    try {
        if (req.query.s) {
            var shops= await search(User,req.query.s)
            return res.status(200).json(shops)
        }
        else
            return res.status(400).json({ "message": "Invalid search query" })
    }
    catch (e) {
        console.log(e)
        next(e)
    }

})

module.exports = router