const { Shop} = require("../../models/shop")
const { Device, User, } = require("../../models/user")
const router = require("express").Router();
const XLSX = require('xlsx');
const app = require("../../urls");
const {verifyToken} = require("../../controllers/verifyToken");
const CryptoJS = require("crypto-js");
const { default: mongoose } = require("mongoose");
// import {map} from "../sockets/onConnection";
const G = require("../../enums/grant")
const {search}=require("../../middleware/search")


router.get("/search", verifyToken([G.Grants.user, G.Grants.staff]), async (req, res, next) => {
    try {
        if (req.query.s) {
            var shops= await search(Shop,req.query.s)
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