const { Shop } = require("../models/shop")
const { Product, Detail, MasterProduct } = require("../models/product")
const { Category, SubCategory } = require("../models/category")
const { User, Address } = require("../models/user")
const XLSX = require("xlsx")
const router = require("express").Router();
const CryptoJS = require("crypto-js");
const { Order, RequestedShop } = require("../models/order")
const {verifyToken} = require("../controllers/verifyToken");
const { readdirSync, readFileSync, rename } = require("fs")
const fs = require('fs');
const { x64 } = require("crypto-js")
const { ProductSuggestion } = require("../models/productSuggestion")
const OR = require("../enums/outletRole")
const { Staff, DashboardAdmin, SuperAdmin } = require("../models/admin")
const { ProductItem } = require("../models/productItem")
const { default: mongoose } = require("mongoose")
const { Console } = require("console")
const { Banner } = require("../models/banner")


router.get("/loadmaster", async(req, res, next) => {
    return res.status(200).json("success")
    await Order.deleteMany()
    await RequestedShop.deleteMany()
    await Product.deleteMany()
    await MasterProduct.deleteMany() 
    await Category.deleteMany()
    await SubCategory.deleteMany()
    var user = User({password: "U2FsdGVkX1/fFkxF073oRsL/OLm254lMa4ydJg+zy1A=", phone: "9808405273", name: "Sanims"})
    await user.save()
    var admin = SuperAdmin({user: user._id})
    await admin.save()
    var url ="data/Product_master_faasto_30_MAR_23.xlsx"
    var contents = XLSX.readFile(url)
    var subcategory
    var category 
    contents.SheetNames.forEach(async function(sheetName) {
        var XL_row_object = XLSX.utils.sheet_to_json(contents.Sheets[sheetName])
        for(var i in XL_row_object){
            if(!category){
                category = Category({name: XL_row_object[i]['groups/name'], image: "https://uploads.faasto.co/products/" + XL_row_object[i]['groups/image']})
                await category.save()
            }
            if(!subcategory){
                subcategory = SubCategory({category: category._id, name: XL_row_object[i]['subgroups/name'], image: "https://uploads.faasto.co/products/" + XL_row_object[i]['subgroups/image'], })
                await subcategory.save()
            }
            var product = MasterProduct({
                name: XL_row_object[i]['name'], 
                price: XL_row_object[i]['price'], 
                return: 7, 
                verificationAdmin: 2, 
                verificationOutlet: 2, 
                limit: XL_row_object[i]['limit'], 
                image: "https://uploads.faasto.co/products/"+ XL_row_object[i]['image'] , 
                category: subcategory._id, 
                unit: XL_row_object[i]['Unit'], 
                sku: XL_row_object[i]['SKU']
            })
            await product.save()
            if(XL_row_object.length == (parseInt(i) + 1).toString()) break
            if(XL_row_object[(parseInt(i) + 1).toString()]['groups/_id'] != XL_row_object[i]['groups/_id']){
                category = undefined
            }
            if(XL_row_object[(parseInt(i) + 1).toString()]['subgroups/_id'] != XL_row_object[i]['subgroups/_id']){
                subcategory = undefined
            }
        }
    })
    return res.status(200).json("success")
})


router.get("/backup", async(req, res, next) => {
    return res.status(200).json("success")
    var urlPrefix = "https://techwol.com/pasalko/products/"
    var url = "data/refactorImages"
    var jsonUrl = "data/refactorImage.txt"
    var jsonData
    try{
        jsonData = fs.readFileSync(jsonUrl)
    }catch(E){
        fs.writeFileSync(jsonUrl, JSON.stringify({}))
        jsonData = fs.readFileSync(jsonUrl)
    }
    var refactorMap = new Map(Object.entries(JSON.parse(jsonData)))
    var filedirectories = getFiles(url)
    for (var k of filedirectories) {
       var supposedID = k.replaceAll(".png", "")
       var product = await Product.findById(supposedID)
       var previousUrl = product.image
       var imageUrl = urlPrefix + k
       if(product && previousUrl && !refactorMap.has(previousUrl)) {
            refactorMap.set(previousUrl, imageUrl)
        }
    }
    var mergeMap = new Map([...readMap, ...refactorMap])
    fs.writeFileSync(jsonUrl, JSON.stringify(Object.fromEntries(mergeMap)))
    return res.status(200).json("success")
})

router.get("/restore", async(req, res, next) => {
    return res.status(200).json("success")
    var jsonUrl = "data/refactorImage.txt"
    var jsonData = fs.readFileSync(jsonUrl)
    var parsed = new Map(Object.entries(JSON.parse(jsonData)));
    for(var i of parsed){
        var prods = await Product.find({image: i[0]})
        for(var j in prods){
            prods[j].image = i[1]
            await prods[j].save()
        }
    }
    return res.status(200).json("success")
})
router.get("/", async (req, res, next) => {
    var users = await User.find()
    for(var i in users){
        users[i].countryCode = "+977"
        await users[i].save()
    }
    return res.status(200).json("success")
    await DashboardAdmin.deleteMany()
    await Staff.deleteMany()
    await Product.deleteMany()
    await Order.deleteMany()
    await RequestedShop.deleteMany()
    await ProductItem.deleteMany()
    return res.status(200).json("success")
    //
    var staffs = await Staff.find()
    console.log(staffs.length)
    for(var i in staffs){
        staffs[i].role = {roles: [ {label: OR.OutletRoles.order, roles: [OR.OrderRoles.read]}]}
        await staffs[i].save()
    }
    var users = await User.find()
    for(var i in users){
        users[i].favourites = {products : [], categories : []}
        await users[i].save()
    }
    return res.status(200).json("success")
    var prods = await Product.find()
    for(var i in prods){
        prods[i].remarks = null
        prods[i].verificationOutlet = 1
        prods[i].verificationAdmin = 1
        await prods[i].save()
    }
    return res.status(200).json("success")
    var masterProduct = await MasterProduct.find()
    var products = await Product.find()
    for(var i in masterProduct){
        masterProduct[i].remarks = null
        await masterProduct[i].save()
    }
    for(var j in products){
        products[j].remarks = null
        await products[j].save()
    }
    return res.status(200).json("success")
    return res.status(200).json("success")
    await MasterProduct.deleteMany({id: null})
    var prods = await Product.find()
    for(var i in prods){
        var master = await MasterProduct.findById(prods[i].master)
        if(!master){
           await Product.findByIdAndDelete(prods[i]._id)
        }
    }
    return res.status(200).json("success")
    var shops = await Staff.find()
    for(var i in shops){
        if(shops[i].devices != []){
            shops[i].devices = []
            await shops[i].save()
        }
    }
    
    return res.status(200).json("success")
    // for(var i in bigMartJson){
    //     var img = [bigMartJson[i].Photo]
    //     var address = bigMartJson[i].Area
    //     var name = bigMartJson[i].Name
    //     var owner = bigMartJson[i].Name
    //     var phone = "9818173521"
    //     var info = {}
    //     var loc = bigMartJson[i].Gps.split(", ")
    //     var location = {"coordinates": [parseFloat(loc[1]), parseFloat(loc[0])]}
    //     console.log(loc)
    //     var deliveryRadius = 1000
    //     var timing = {start: {hour:8,minute:0}, end: {hour:18,minute:0}, closedOn: [7]}
    //     var shop = Shop({img: img, address: address, name: name, owner: owner, phone: phone, info: info, location: location, deliveryRadius: deliveryRadius, timing:timing})
    //     await shop.save()
    // }
    var shop = await Shop.find()
    for(var i in shop){
        
        shop[i].timing = {start: {hour:8,minute:0}, end: {hour:18,minute:0}, closedOn: [7]}
        await shop[i].save()
    }
    return res.status(200).json("success")

    // await Unit.deleteMany()
    // var unit =  Unit({"unit":"gm"})
    // await unit.save()
    // unit = await Unit({"unit":"kg"})
    // await unit.save()
    // unit = await Unit({"unit":"ml"})
    // await unit.save()
    // unit = await Unit({"unit":"ltr"})
    // await unit.save()
    // unit = await Unit({"unit":"pcs"})
    // await unit.save()
    // unit = await Unit({"unit":"box"})
    // await unit.save()
    // var workbook = XLSX.readFile("data/ezdeliver.xlsx")
    // var sheet_name_list = workbook.SheetNames
    // var xlData = XLSX.utils.sheet_to_json(workbook.Sheets[sheet_name_list[0]])
    // for (var j in xlData) {
    //         var i = xlData[j]
    //         if (j % 100 == 0) {
    //             console.log(j)
    //         }
    // }

    // var products = await Product.find()
    // for(var i in products){
    //     products[i].unit = await Unit.findOne()
    //     products[i].master = true;
    //     products[i].save()
    // }
    
    var staff = await Staff.findOne()
    var str = staff._id.toString()
    console.log("mongoose.Types.ObjectId(str) == mongoose.Types.ObjectId(str)", mongoose.Types.ObjectId(str) == mongoose.Types.ObjectId(str))
    console.log("mongoose.Types.ObjectId(str) === mongoose.Types.ObjectId(str)", mongoose.Types.ObjectId(str) === mongoose.Types.ObjectId(str))
    console.log("str === str", str === str)
    console.log("str == str", str == str)
    return res.status(200).json("success")
    var products = await Product.find()
    var subcategories = await SubCategory.find()
    var categories = await Category.find()
    for(var i in products){
        products[i].tags = []
        await products[i].save()
    }
    for(var i in subcategories){
        subcategories[i].tags = []
        await subcategories[i].save()
    }
    for(var i in categories){
        categories[i].tags = []
        await categories[i].save()
    }
    return res.status(200).json("success")
    var suggs =  await ProductSuggestion.find()
    for(var i in suggs){
        suggs[i].isShop = false
        await suggs[i].save()
    }
    return res.status(200).json("success")
    await RequestedShop.deleteMany()
    await Order.deleteMany()
    var users = await User.find()
    var shops = await Shop.find()
    for(var i in users){
        users[i].raterCount = 0
        users[i].avgRating = 0
        users[i].ratingStar = [0,0,0,0,0]
        await users[i].save()
    }
    var users = await User.find()
    for(var i in shops){
        shops[i].raterCount = 0
        shops[i].avgRating = 0
        shops[i].ratingStar = [0,0,0,0,0]
        await shops[i].save()
    }
    return res.status(200).json("success")
    var shops = await Shop.find()
    for(var i in shops){
        if(shops[i].devices != []){
            shops[i].devices = []
            await shops[i].save()
        }
    }
    return res.status(200).json("success")
    var users = await User.find()
    var shops = await Shop.find()
    for(var i in users){
        users[i].avgRating = 0
        users[i].raterCount = 0
        await users[i].save()
    }
    for(var i in shops){
        shops[i].avgRating = 0
        shops[i].raterCount = 0
        await shops[i].save()
    }
    return res.status(200).json("success")
    var users = await User.find()
    for(var i in users){
        users[i].address = []
        users[i].save()
    }
    return res.status(200).json("success")
    var shops = await Shop.find()
    for(var i in shops){
        if(shops[i].devices != []){
            shops[i].devices = []
            await shops[i].save()
        }
    }
    return res.status(200).json("success")
    var shops = await Shop.find()
    for(var i in shops){
        shops[i].owner = shops[i].name
        await shops[i].save()
    }
    return res.status(200).json("success")
    var shops = await Shop.find()
    for(var i in shops){
        shops[i].ringtone = true
        await shops[i].save()
    }

    return res.status(200).json("success")
    var shops = await Shop.find()
    for(var i in shops){
        if(shops[i].categories.length){
            shops[i].categories = []
            await shops[i].save()
        }
    }
})


var bigMartJson = [
    {
     "Name": "Big Mart",
     "Area": "Baluwatar 3",
     "Gps": "27.7309700, 85.3297000"
    },
    {
     "Name": "Big Mart",
     "Area": "Baluwatar 2",
     "Gps": "27.7241830, 85.3313720"
    },
    {
     "Name": "Big Mart",
     "Area": "Baluwatar ",
     "Gps": "27.7236910, 85.3313160",
     "Photo": "https:\/\/lh5.googleusercontent.com\/p\/AF1QipObhQKLnGvBenglomR7ftmGNiPTBB89-CyraeBB=w408-h544-k-no"
    },
    {
     "Name": "Big Mart",
     "Area": "Chandol",
     "Gps": "27.7342470, 85.3414740",
     "Photo": "https:\/\/lh5.googleusercontent.com\/p\/AF1QipNA3py5Y5aq0aFuNQD4eb1cUZxl9PouYh3bc2jR=w408-h306-k-no"
    },
    {
     "Name": "Big Mart",
     "Area": "Bishalnagar",
     "Gps": "27.7190470, 85.3335440",
     "Photo": "https:\/\/lh5.googleusercontent.com\/p\/AF1QipPozLX_0npcdsxzFkFxkJlTzo9zICqivrVc9NuC=w408-h306-k-no"
    },
    {
     "Name": "Big Mart",
     "Area": "Lazimpat",
     "Gps": "27.7206540, 85.3196200",
     "Photo": "https:\/\/lh5.googleusercontent.com\/p\/AF1QipPvr5gMsVIy1k5d3jpLQ7dilprXjIMTlnEJSWQ2=w408-h544-k-no"
    },
    {
     "Name": "Big Mart",
     "Area": "Chappal Karkhana",
     "Gps": "27.7407370, 85.3445010",
     "Photo": "https:\/\/lh5.googleusercontent.com\/p\/AF1QipPG8J3sQlz1-bUWiq0zvWKa5DKwQQTYo8LLWOf5=w408-h306-k-no"
    },
    {
     "Name": "Big Mart",
     "Area": "Tokha Road",
     "Gps": "27.7406030, 85.3214080",
     "Photo": "https:\/\/lh5.googleusercontent.com\/p\/AF1QipPjN4qPXsiHrXd-SrMieEf1cE6kbwhTmbtwtY9h=w408-h299-k-no"
    },
    {
     "Name": "Big Mart",
     "Area": "Samakhusi",
     "Gps": "27.7321390, 85.3165300",
     "Photo": "https:\/\/lh5.googleusercontent.com\/p\/AF1QipMeRxZcCxA26U7K1UD6aLr-G83-qjDf3sd9ETI9=w426-h240-k-no"
    },
    {
     "Name": "Big Mart",
     "Area": "Sano Gaucharan",
     "Gps": "27.7109050, 85.3313110",
     "Photo": "https:\/\/lh5.googleusercontent.com\/p\/AF1QipMFgMok4H2mabvltT2UJB6kiwm0R9KdMeDy0NT3=w408-h306-k-no"
    },
    {
     "Name": "Big Mart",
     "Area": "Janachowk",
     "Gps": "27.7358710, 85.3516220"
    },
    {
     "Name": "Big Mart",
     "Area": "Mandikatar",
     "Gps": "27.7393410, 85.3489410",
     "Photo": "https:\/\/lh5.googleusercontent.com\/p\/AF1QipP-Kl8cIqDDexssAnuwBG5krISBHMN-Lt8qmvZl=w408-h306-k-no"
    },
    {
     "Name": "Big Mart",
     "Area": "Tokha Road 2",
     "Gps": "27.7430560, 85.3224170"
    },
    {
     "Name": "Big Mart",
     "Area": "Kapan",
     "Gps": "27.7268610, 85.3556930",
     "Photo": "https:\/\/lh5.googleusercontent.com\/p\/AF1QipOZqpTEfV12t7d0i1Jtgnr6zU1xYU65z0uXzW1n=w567-h240-k-no"
    },
    {
     "Name": "Big Mart",
     "Area": "City Center",
     "Gps": "27.7096260, 85.3263610",
     "Photo": "https:\/\/lh5.googleusercontent.com\/p\/AF1QipOFGsEvpW7eyjq3nEbjSghAuS1AKruPT-RzIspH=w408-h306-k-no"
    },
    {
     "Name": "Big Mart",
     "Area": "Tusal Boudha",
     "Gps": "27.7170400, 85.3550280",
     "Photo": "https:\/\/lh5.googleusercontent.com\/p\/AF1QipMsPudVSrTPi5fUEWTDdmg3LYMybcRNNesECV6Y=w408-h544-k-no"
    },
    {
     "Name": "Big Mart",
     "Area": "Ganesh Chowk ",
     "Gps": "27.7380590, 85.3139490",
     "Photo": "https:\/\/lh5.googleusercontent.com\/p\/AF1QipMEIZ56SluSJAfPd7j1FoFKH5_tYEIi-RQhzzow=w408-h910-k-no"
    },
    {
     "Name": "Big Mart",
     "Area": "Baluwakhani",
     "Gps": "27.7446930, 85.3557550",
     "Photo": "https:\/\/lh5.googleusercontent.com\/p\/AF1QipMc9zPyzgb6TgmE4GclC4bbJMqwwoCjai_ilgXJ=w408-h306-k-no"
    },
    {
     "Name": "Big Mart",
     "Area": "Nayabasti",
     "Gps": "27.7180070, 85.3605980"
    },
    {
     "Name": "Big Mart",
     "Area": "Tokha Grandee",
     "Gps": "27.7543440, 85.3279750",
     "Photo": "https:\/\/lh5.googleusercontent.com\/p\/AF1QipOqsdt4aDKh6AZkkzQVhskafcvaI4jl_c189o5A=w408-h544-k-no"
    },
    {
     "Name": "Big Mart",
     "Area": "Sorhakhutte",
     "Gps": "27.7207510, 85.3054860"
    },
    {
     "Name": "Big Mart",
     "Area": "Tokha Grandee",
     "Gps": "27.7543480, 85.3280140"
    },
    {
     "Name": "Big Mart",
     "Area": "Machhapokhari",
     "Gps": "27.7378850, 85.3058380",
     "Photo": "https:\/\/lh5.googleusercontent.com\/p\/AF1QipPrI87dxFpf3qk5xjhrAnN3LGJtTs5TnjDYwvz2=w408-h306-k-no"
    },
    {
     "Name": "Big Mart",
     "Area": "Sundarbasti",
     "Gps": "27.7486860, 85.3548580",
     "Photo": "https:\/\/lh5.googleusercontent.com\/p\/AF1QipN4mp0WS_3GldBwIXuQo8jiSDZO__9sRISuVZjt=w426-h240-k-no"
    },
    {
     "Name": "Big Mart",
     "Area": "Golfutar",
     "Gps": "27.7530860, 85.3464720"
    },
    {
     "Name": "Big Mart",
     "Area": "Tinchuli",
     "Gps": "27.7262020, 85.3679350",
     "Photo": "https:\/\/lh5.googleusercontent.com\/p\/AF1QipMKXu1jY7qoCiqXssX4fMuq-1c-ZNk8odcMLnl_=w408-h306-k-no"
    },
    {
     "Name": "Big Mart",
     "Area": "Boudha",
     "Gps": "27.7212920, 85.3680860",
     "Photo": "https:\/\/lh5.googleusercontent.com\/p\/AF1QipP4uw6bdcBlE9sr49QLb3VeOrL2KzED6U0uMYHH=w426-h240-k-no"
    },
    {
     "Name": "Big Mart",
     "Area": "Anamnagar",
     "Gps": "27.6988200, 85.3287600",
     "Photo": "https:\/\/lh5.googleusercontent.com\/p\/AF1QipObh5uXOePXZYoQpHUOKC40_DdHkjvaiS25TvtU=w426-h240-k-no"
    },
    {
     "Name": "Big Mart",
     "Area": "Khusibu",
     "Gps": "27.7153730, 85.3034450",
     "Photo": "https:\/\/lh5.googleusercontent.com\/p\/AF1QipOdSWs-qY49Xw-V7l1MyHY6gfrE27Qv8uBPaMwK=w532-h240-k-no"
    },
    {
     "Name": "Big Mart",
     "Area": "Mid-Baneshwor 2",
     "Gps": "27.6951300, 85.3373900",
     "Photo": "https:\/\/lh3.googleusercontent.com\/p\/AF1QipMfepLUZew7VtunChh5z91Vtq0cHp05Pk9GPq5v=s680-w680-h510"
    },
    {
     "Name": "Big Mart",
     "Area": "Sunakothi",
     "Gps": "27.6951300, 85.3373900",
     "Photo": "https:\/\/lh3.googleusercontent.com\/p\/AF1QipMfepLUZew7VtunChh5z91Vtq0cHp05Pk9GPq5v=s680-w680-h510"
    },
    {
     "Name": "Big Mart",
     "Area": "Yerarhity",
     "Gps": "27.7238890, 85.2934510"
    },
    {
     "Name": "Big Mart",
     "Area": "Italitar",
     "Gps": "27.7626260, 85.3529090",
     "Photo": "https:\/\/lh5.googleusercontent.com\/p\/AF1QipMHn5y3kh-vzIvBwG3bu7xnYIJSApXPDp8uLu54=w408-h248-k-no"
    },
    {
     "Name": "Big Mart",
     "Area": "Santinagar",
     "Gps": "27.6873090, 85.3426260",
     "Photo": "https:\/\/lh5.googleusercontent.com\/p\/AF1QipNcy3zdbrZdey0pD7qtHhd71k22Evitln0SS4mW=w408-h306-k-no"
    },
    {
     "Name": "Big Mart",
     "Area": "Attarkhel",
     "Gps": "27.7359480, 85.3836310",
     "Photo": "https:\/\/lh5.googleusercontent.com\/p\/AF1QipMLlQ_6sxdSQxxYUEhmVeMXXXyZcU_onLfZfTi8=w408-h306-k-no"
    },
    {
     "Name": "Big Mart",
     "Area": "Subidhanagar",
     "Gps": "27.6832910, 85.3452650",
     "Photo": "https:\/\/lh5.googleusercontent.com\/p\/AF1QipPD8SAwdQNOOVWf3IcTOHifjpbVn1qEtVUvDSdj=w426-h240-k-no"
    },
    {
     "Name": "Big Mart",
     "Area": "Kupondole",
     "Gps": "27.6871790, 85.3138760",
     "Photo": "https:\/\/lh5.googleusercontent.com\/p\/AF1QipMCChgbCpdRjjTdkxaXKJkF38rWpd4YCH4-15CC=w408-h544-k-no"
    },
    {
     "Name": "Big Mart",
     "Area": "Pepsi Cola 1",
     "Gps": "27.6926940, 85.3672390",
     "Photo": "https:\/\/lh5.googleusercontent.com\/p\/AF1QipNmZQeTL6mGN1aKLzTkZRowlOkB1sPDHuA72Q9t=w426-h240-k-no"
    },
    {
     "Name": "Big Mart",
     "Area": "Sitapaila",
     "Gps": "27.7219220, 85.2845600"
    },
    {
     "Name": "Big Mart",
     "Area": "Sano Bharyang",
     "Gps": "27.7242370, 85.2849980"
    },
    {
     "Name": "Big Mart",
     "Area": "Sankhamul",
     "Gps": "27.6818520, 85.3325630",
     "Photo": "https:\/\/lh5.googleusercontent.com\/p\/AF1QipN0wHhBEob2eRxPt0GZwTyc4TMjJuCnnMpGlfgU=w408-h306-k-no"
    },
    {
     "Name": "Big Mart",
     "Area": "Pepsi Cola 2",
     "Gps": "27.6946580, 85.3722310"
    },
    {
     "Name": "Big Mart",
     "Area": "Thulobharyang",
     "Gps": "27.7208940, 85.2845610"
    },
    {
     "Name": "Big Mart",
     "Area": "Bakundole",
     "Gps": "27.6832610, 85.3131960",
     "Photo": "https:\/\/lh5.googleusercontent.com\/p\/AF1QipMXaYa-RoS9Nutso1neOMG7ti4cdlkBAJhA-muh=w408-h306-k-no"
    },
    {
     "Name": "Big Mart",
     "Area": "Tahachal",
     "Gps": "27.6999260, 85.2893440"
    },
    {
     "Name": "Big Mart",
     "Area": "Sahayoginagar",
     "Gps": "27.6781660, 85.3391550",
     "Photo": "https:\/\/lh5.googleusercontent.com\/p\/AF1QipNpDjY17W5WByyUqi3qoiGO-aQygMaU7RFWyW-L=w408-h306-k-no"
    },
    {
     "Name": "Big Mart",
     "Area": "Naryanthan",
     "Gps": "27.7719820, 85.3592710",
     "Photo": "https:\/\/lh5.googleusercontent.com\/p\/AF1QipPBlKQBSMSUPBIXlS9fXmOaUuCblSu7sXfsg71v=w408-h306-k-no"
    },
    {
     "Name": "Big Mart",
     "Area": "Naryanthan 2",
     "Gps": "27.7727940, 85.3597300"
    },
    {
     "Name": "Big Mart",
     "Area": "Sanepa",
     "Gps": "27.6855700, 85.3027000"
    },
    {
     "Name": "Big Mart",
     "Area": "Kuleshwor",
     "Gps": "27.6910540, 85.2952470",
     "Photo": "https:\/\/lh5.googleusercontent.com\/p\/AF1QipNcqMvxZIRPQkFk3zC1000v1BJYKdAzZ_CIUpTq=w408-h544-k-no"
    },
    {
     "Name": "Big Mart",
     "Area": "Jhamsikhel",
     "Gps": "27.6794700, 85.3077680"
    },
    {
     "Name": "Big Mart",
     "Area": "Lokanthali",
     "Gps": "27.6778440, 85.3625790"
    },
    {
     "Name": "Big Mart",
     "Area": "Balkumari",
     "Gps": "27.6727840, 85.3332110",
     "Photo": "https:\/\/lh5.googleusercontent.com\/p\/AF1QipOW4pwhP--zcylltPoZ6sMmS4ibPUf5ibNDaQfG=w408-h544-k-no"
    },
    {
     "Name": "Big Mart",
     "Area": "Gattha Ghar",
     "Gps": "27.6772490, 85.3756480",
     "Photo": "https:\/\/lh5.googleusercontent.com\/p\/AF1QipOgS0heqCi4nq4lV8qfchQ0JX3IvzOgj_-qHVY7=w408-h725-k-no"
    },
    {
     "Name": "Big Mart",
     "Area": "Manbhawan",
     "Gps": "27.6681840, 85.3164250",
     "Photo": "https:\/\/lh5.googleusercontent.com\/p\/AF1QipNHK49Zp0ePPEXhF-gvHhlT-87VWeLZA6sY4gbt=w408-h725-k-no"
    },
    {
     "Name": "Big Mart",
     "Area": "Purano Thimi",
     "Gps": "27.6827370, 85.3847490",
     "Photo": "https:\/\/lh5.googleusercontent.com\/p\/AF1QipNUFxzJRHlTsplF702TIFAikquVPH8BdMFAVx3P=w408-h544-k-no"
    },
    {
     "Name": "Big Mart",
     "Area": "Bhani Mandal",
     "Gps": "27.6696980, 85.3100450",
     "Photo": "https:\/\/lh5.googleusercontent.com\/p\/AF1QipMU1du600qokcIIbrcRIhqlc3SKooPcBhVBffz7=w408-h306-k-no"
    },
    {
     "Name": "Big Mart",
     "Area": "Tikathali",
     "Gps": "27.6649600, 85.3572400",
     "Photo": "https:\/\/lh5.googleusercontent.com\/p\/AF1QipMnXXbG2mtyEMK2cARMx1BsSFwUQKbY2V1YQqZc=w408-h544-k-no"
    },
    {
     "Name": "Big Mart",
     "Area": "Tanglafaat",
     "Gps": "27.6807450, 85.2792280",
     "Photo": "https:\/\/lh5.googleusercontent.com\/p\/AF1QipMTWFf_6PQ17xphnlwAltBH28fj8pTfoyBWxczo=w408-h305-k-no"
    },
    {
     "Name": "Big Mart",
     "Area": "Tinthana",
     "Gps": "27.6874500, 85.2692200",
     "Photo": "https:\/\/lh5.googleusercontent.com\/p\/AF1QipOhcDQolmYyJSgboVjLrkeAfTiWo7h12IJ3JjfU=w408-h544-k-no"
    },
    {
     "Name": "Big Mart",
     "Area": "Nakkhu",
     "Gps": "27.6611330, 85.3022900"
    },
    {
     "Name": "Big Mart",
     "Area": "Nakhipot",
     "Gps": "27.6558760, 85.3171110",
     "Photo": "https:\/\/lh5.googleusercontent.com\/p\/AF1QipNiB70FFiNFKQFV4B_Yd-cQtqEX4TV3VWq25_Yw=w426-h240-k-no"
    },
    {
     "Name": "Big Mart",
     "Area": "Dhapakhel",
     "Gps": "27.6462700, 85.3255900",
     "Photo": "https:\/\/lh5.googleusercontent.com\/p\/AF1QipPRRI920RIH5rwExHfssfs_0aYqJDy4TPQIjtAz=w426-h240-k-no"
    },
    {
     "Name": "Big Mart",
     "Area": "Dolahity",
     "Gps": "27.6463130, 85.3199500",
     "Photo": "https:\/\/lh5.googleusercontent.com\/p\/AF1QipNfjH62gDawKVEeS77vX1NQCRTizspKY60Ivbzk=w408-h306-k-no"
    },
    {
     "Name": "Big Mart",
     "Area": "Harishiddhi",
     "Gps": "27.6444430, 85.3378830",
     "Photo": "https:\/\/lh5.googleusercontent.com\/p\/AF1QipNk-O9tOUgByuHrJumOq-_RljqBmMtjabAoySt3=w408-h306-k-no"
    },
    {
     "Name": "Big Mart",
     "Area": "Bhaisepati",
     "Gps": "27.6488880, 85.3051510",
     "Photo": "https:\/\/lh5.googleusercontent.com\/p\/AF1QipO-oxnNuqlka60zowCb8iFrkrXfcA68PqJZtMo-=w408-h306-k-no"
    },
    {
     "Name": "Big Mart",
     "Area": "Dhapakhel",
     "Gps": "27.6432490, 85.3256970"
    },
    {
     "Name": "Big Mart",
     "Area": "Satungal",
     "Gps": "27.6878140, 85.2498080",
     "Photo": "https:\/\/lh5.googleusercontent.com\/p\/AF1QipOZzD1ZdET9Fj3NSW19QQdDZER8sGrhCxJcKyu7=w408-h306-k-no"
    },
    {
     "Name": "Big Mart",
     "Area": "Sunakhoti",
     "Gps": "27.6295010, 85.3183830",
     "Photo": "https:\/\/lh5.googleusercontent.com\/p\/AF1QipNuhQ1WMcZ4PPTx5TVbsuE5JoPDsQ_iPp7Kv3p9=w408-h544-k-no"
    },
    {
     "Name": "Big Mart",
     "Area": "Thaiba",
     "Gps": "27.6280900, 85.3462100",
     "Photo": "https:\/\/lh5.googleusercontent.com\/p\/AF1QipN4ND7Jq6BaIcB7e_CIGDjEFDzAbikMOvD0iA9y=w408-h306-k-no"
    },
    {
     "Name": "Big Mart",
     "Area": "Kamal Vinayak",
     "Gps": "27.6771200, 85.4368100",
     "Photo": "https:\/\/lh5.googleusercontent.com\/p\/AF1QipPuVi8EDMXkbLCuByoDYGI9RCd_2IhMY78c4Z0c=w523-h240-k-no"
    },
    {
     "Name": "Big Mart",
     "Area": "Chitwan",
     "Gps": "27.6688300, 84.4341300",
     "Photo": "https:\/\/lh5.googleusercontent.com\/p\/AF1QipMbaGjo3p7S-zcYZ6knW3Z7GxzpTj0wi9ZgYnfq=w426-h240-k-no"
    }
   ]

const getDirectories = source =>
    readdirSync(source, { withFileTypes: true })
        .filter(dirent => dirent.isDirectory())
        .map(dirent => dirent.name)

const getFiles = source =>
    readdirSync(source, { withFileTypes: true })
        .filter(dirent => dirent.isFile())
        .map(dirent => dirent.name)

const renameAllDirs = (directories) => {
    for (var i in directories) {
        var directoryUrl = url + "/" + directories[i]
        var subdirectories = getDirectories(directoryUrl)
        for (var j in subdirectories) {
            var oldname = subdirectories[j]
            var newname = oldname.replaceAll("All ", "")
            var currPath = directoryUrl + "/" + oldname
            var newPath = directoryUrl + "/" + newname
            rename(currPath, newPath)
        }
    }
}

router.delete("/", verifyToken(), async (req, res, next) => {
    return res.status(200).json("success")
    try{
    await Order.deleteMany()
    await RequestedShop.deleteMany()
    res.status(200).json("success")}catch(e){next(e)}
})
//

// var shops = await Shop.find()
// for (var i in shops) {
//     shops[i].devices = []
//     await shops[i].save()
// }

// return res.status(200).json("success")
// // return res.status(200).json("success")
// var category = await Category.findOne()
// var shops = await Shop.find()
// for (var i in shops) {
//     shops[i].categories = [category._id]
//     await shops[i].save()
// }

// return res.status(200).json("success")

// var category = Category({ "name": "Groceries" })
// var categories = await Category.find()
// for (var i in categories) {
//     if (categories[i]._id != category._id) {
//         var sub = SubCategory({ "name": categories[i].name, "image": categories[i].image, "category": category._id })
//         var products = await Product.find({ "category": categories[i]._id })
//         for (var j in products) {
//             products[j].category = sub._id
//             await products[j].save()
//         }
//         await sub.save()
//         await categories[i].delete()
//     }
// }
// await category.save()



// var category1 = Category({ "name": "Groceries" })
// await category1.save()
// var categories1 = await SubCategory.find()
// for (var i in categories1) {
//     categories1[i].category = category1._id
//     await categories1[i].save()
// }

// res.status(200).json("success")
// return
// var workbook = XLSX.readFile("data/ezdeliver.xlsx");
// var sheet_name_list = workbook.SheetNames;
// var xlData = XLSX.utils.sheet_to_json(workbook.Sheets[sheet_name_list[0]]);
// // var user = User({
// //     "name": "sajat", "phone": "9818173521", "password":
// //         CryptoJS.AES.encrypt(
// //             "12345678",
// //             process.env.PASS_SEC
// //         ).toString(), "address": [Address({ "fullName": "name", "phone": "9818173521", "address": "address", "label": "label", "location": { "coordinates": [87.2677008, 26.4508133] } })]
// // })
// // user.save()
// // return
// for (var j in xlData) {
//     var i = xlData[j]
//     if (j % 100 == 0) {
//         console.log(j)
//     }
//     var shop = Shop({
//         name: i["name"],
//         password: CryptoJS.AES.encrypt(
//             i["num"],
//             process.env.PASS_SEC
//         ).toString(),
//         phone: i["num"],
//         pan: "123456789",
//         location: { coordinates: [i["lon"], i["lat"]] },
//         deliveryRadius: i["radius"]
//     })
//     await shop.save()
// }
// console.log("shops upload complete")

// var category = Category({ "name": "My", "img": "" })
// category.save()
// for (var i = 0; i < products.length; i++) {
//     var product = Product({
//         name: products[i]["name"],
//         price: products[i]["price"],
//         category: category._id.toString(),
//         image: products[i]["url"]
//     })
//     await product.save()
// }

// console.log("products upload complete")
// return res.status(200).json("success")


router.get("/zerobyzero", async (req, res, next) => {
    return res.status(200).json( {
        card_lists: [
          {
            id: 1,
            title: "Im Schlosstal",
            location: "91322 Grafenberg, Bayern, DE",
            price: "13$ Nacht",
            geheimtipp: true,
            images: [
              "https://images.pexels.com/photos/9000153/pexels-photo-9000153.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
              "https://images.pexels.com/photos/16486236/pexels-photo-16486236.jpeg",
              "https://images.pexels.com/photos/16469319/pexels-photo-16469319.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
              "https://images.pexels.com/photos/13525587/pexels-photo-13525587.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
              "https://images.pexels.com/photos/15909375/pexels-photo-15909375.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
            ],
            likes: "100%",
            tags: [
              {
                icon: "https://png.pngtree.com/png-vector/20190326/ourmid/pngtree-vector-clock-icon-png-image_865317.jpg",
                name: "Zeit",
              },
              {
                icon: "https://e7.pngegg.com/pngimages/185/628/png-clipart-caravan-campervans-computer-icons-car-angle-van.png",
                name: "Wohnmobil & Van",
              },
              {
                icon: "https://cdn3.iconfinder.com/data/icons/camping-party/512/tent-rooftop-camping-travel-car-512.png",
                name: "Dachzelt",
              },
              {
                icon: "https://w7.pngwing.com/pngs/485/971/png-transparent-taxi-car-computer-icons-uber-taxi-driver-car-vehicle-black.png",
                name: "Uber 7m",
              },
              {
                icon: "https://cdn-icons-png.flaticon.com/512/3181/3181102.png",
                name: "Wohnwagen",
              },
            ],
            features: [
              {
                icon: "https://icon-library.com/images/water-drop-png-icon/water-drop-png-icon-2.jpg",
                name: "Wasser",
              },
              {
                icon: "https://cdn-icons-png.flaticon.com/512/2797/2797775.png",
                name: "WC",
              },
              {
                icon: "https://www.pngfind.com/pngs/m/312-3123165_png-file-strom-icon-png-transparent-png.png",
                name: "Strom,",
              },
              {
                icon: "https://png.pngtree.com/png-vector/20190223/ourmid/pngtree-wifi-vector-icon-png-image_696445.jpg",
                name: "WLAN",
              },
              {
                icon: "https://icon-library.com/images/dog-icon-png/dog-icon-png-7.jpg",
                name: "Tier",
              },
            ],
          },
          {
            id: 2,
            title: "Idyllisches See Camping",
            location: "91322 Grafenberg, Bayern, DE",
            price: "18$ Nacht",
            geheimtipp: false,
            images: [
              "https://images.pexels.com/photos/8527370/pexels-photo-8527370.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
              "https://images.pexels.com/photos/15909375/pexels-photo-15909375.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
              "https://images.pexels.com/photos/16486236/pexels-photo-16486236.jpeg",
              "https://images.pexels.com/photos/13525587/pexels-photo-13525587.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
            ],
            likes: "100%",
            tags: [
              {
                icon: "https://png.pngtree.com/png-vector/20190326/ourmid/pngtree-vector-clock-icon-png-image_865317.jpg",
                name: "Zeit",
              },
              {
                icon: "https://e7.pngegg.com/pngimages/185/628/png-clipart-caravan-campervans-computer-icons-car-angle-van.png",
                name: "Wohnmobil & Van",
              },
              {
                icon: "https://cdn3.iconfinder.com/data/icons/camping-party/512/tent-rooftop-camping-travel-car-512.png",
                name: "Dachzelt",
              },
              {
                icon: "https://w7.pngwing.com/pngs/485/971/png-transparent-taxi-car-computer-icons-uber-taxi-driver-car-vehicle-black.png",
                name: "Uber 7m",
              },
              {
                icon: "https://cdn-icons-png.flaticon.com/512/3181/3181102.png",
                name: "Wohnwagen",
              },
            ],
            features: [
              {
                icon: "https://icon-library.com/images/water-drop-png-icon/water-drop-png-icon-2.jpg",
                name: "Wasser",
              },
              {
                icon: "https://cdn-icons-png.flaticon.com/512/2797/2797775.png",
                name: "WC",
              },
              {
                icon: "https://www.pngfind.com/pngs/m/312-3123165_png-file-strom-icon-png-transparent-png.png",
                name: "Strom,",
              },
              {
                icon: "https://png.pngtree.com/png-vector/20190223/ourmid/pngtree-wifi-vector-icon-png-image_696445.jpg",
                name: "WLAN",
              },
              {
                icon: "https://icon-library.com/images/dog-icon-png/dog-icon-png-7.jpg",
                name: "Tier",
              },
            ],
          },
          {
            id: 3,
            title: "Im See Camp",
            location: "38395 Grafenberg, Bayern, ED",
            price: "53$ Nacht",
            geheimtipp: true,
            images: [
              "https://images.pexels.com/photos/12131159/pexels-photo-12131159.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
              "https://images.pexels.com/photos/16486236/pexels-photo-16486236.jpeg",
              "https://images.pexels.com/photos/16469319/pexels-photo-16469319.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
              "https://images.pexels.com/photos/13525587/pexels-photo-13525587.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
              "https://images.pexels.com/photos/15909375/pexels-photo-15909375.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
            ],
            likes: "100%",
            tags: [
              {
                icon: "https://png.pngtree.com/png-vector/20190326/ourmid/pngtree-vector-clock-icon-png-image_865317.jpg",
                name: "Zeit",
              },
              {
                icon: "https://e7.pngegg.com/pngimages/185/628/png-clipart-caravan-campervans-computer-icons-car-angle-van.png",
                name: "Wohnmobil & Van",
              },
              {
                icon: "https://cdn3.iconfinder.com/data/icons/camping-party/512/tent-rooftop-camping-travel-car-512.png",
                name: "Dachzelt",
              },
              {
                icon: "https://w7.pngwing.com/pngs/485/971/png-transparent-taxi-car-computer-icons-uber-taxi-driver-car-vehicle-black.png",
                name: "Uber 7m",
              },
              {
                icon: "https://cdn-icons-png.flaticon.com/512/3181/3181102.png",
                name: "Wohnwagen",
              },
            ],
            features: [
              {
                icon: "https://icon-library.com/images/water-drop-png-icon/water-drop-png-icon-2.jpg",
                name: "Wasser",
              },
              {
                icon: "https://cdn-icons-png.flaticon.com/512/2797/2797775.png",
                name: "WC",
              },
              {
                icon: "https://www.pngfind.com/pngs/m/312-3123165_png-file-strom-icon-png-transparent-png.png",
                name: "Strom,",
              },
              {
                icon: "https://png.pngtree.com/png-vector/20190223/ourmid/pngtree-wifi-vector-icon-png-image_696445.jpg",
                name: "WLAN",
              },
              {
                icon: "https://icon-library.com/images/dog-icon-png/dog-icon-png-7.jpg",
                name: "Tier",
              },
            ],
          },
          {
            id: 4,
            title: "Schlosstal See",
            location: "454 Bayern, DE",
            price: "90$ Nacht",
            geheimtipp: true,
            images: [
              "https://images.pexels.com/photos/15056108/pexels-photo-15056108.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
              "https://images.pexels.com/photos/16469319/pexels-photo-16469319.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
              "https://images.pexels.com/photos/13525587/pexels-photo-13525587.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
              "https://images.pexels.com/photos/15909375/pexels-photo-15909375.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
            ],
            likes: "100%",
            tags: [
              {
                icon: "https://png.pngtree.com/png-vector/20190326/ourmid/pngtree-vector-clock-icon-png-image_865317.jpg",
                name: "Zeit",
              },
              {
                icon: "https://e7.pngegg.com/pngimages/185/628/png-clipart-caravan-campervans-computer-icons-car-angle-van.png",
                name: "Wohnmobil & Van",
              },
              {
                icon: "https://cdn3.iconfinder.com/data/icons/camping-party/512/tent-rooftop-camping-travel-car-512.png",
                name: "Dachzelt",
              },
              {
                icon: "https://w7.pngwing.com/pngs/485/971/png-transparent-taxi-car-computer-icons-uber-taxi-driver-car-vehicle-black.png",
                name: "Uber 7m",
              },
              {
                icon: "https://cdn-icons-png.flaticon.com/512/3181/3181102.png",
                name: "Wohnwagen",
              },
            ],
            features: [
              {
                icon: "https://icon-library.com/images/water-drop-png-icon/water-drop-png-icon-2.jpg",
                name: "Wasser",
              },
              {
                icon: "https://cdn-icons-png.flaticon.com/512/2797/2797775.png",
                name: "WC",
              },
              {
                icon: "https://www.pngfind.com/pngs/m/312-3123165_png-file-strom-icon-png-transparent-png.png",
                name: "Strom,",
              },
              {
                icon: "https://png.pngtree.com/png-vector/20190223/ourmid/pngtree-wifi-vector-icon-png-image_696445.jpg",
                name: "WLAN",
              },
              {
                icon: "https://icon-library.com/images/dog-icon-png/dog-icon-png-7.jpg",
                name: "Tier",
              },
            ],
          },
          {
            id: 5,
            title: "Im IDYllisches",
            location: "91345 Bayern, DE",
            price: "903$ Nacht",
            geheimtipp: true,
            images: [
              "https://images.pexels.com/photos/9000157/pexels-photo-9000157.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
              "https://images.pexels.com/photos/16486236/pexels-photo-16486236.jpeg",
              "https://images.pexels.com/photos/16469319/pexels-photo-16469319.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
              "https://images.pexels.com/photos/13525587/pexels-photo-13525587.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
              "https://images.pexels.com/photos/15909375/pexels-photo-15909375.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
            ],
            likes: "50%",
            tags: [
              {
                icon: "https://png.pngtree.com/png-vector/20190326/ourmid/pngtree-vector-clock-icon-png-image_865317.jpg",
                name: "Zeit",
              },
              {
                icon: "https://e7.pngegg.com/pngimages/185/628/png-clipart-caravan-campervans-computer-icons-car-angle-van.png",
                name: "Wohnmobil & Van",
              },
              {
                icon: "https://cdn3.iconfinder.com/data/icons/camping-party/512/tent-rooftop-camping-travel-car-512.png",
                name: "Dachzelt",
              },
              {
                icon: "https://w7.pngwing.com/pngs/485/971/png-transparent-taxi-car-computer-icons-uber-taxi-driver-car-vehicle-black.png",
                name: "Uber 7m",
              },
              {
                icon: "https://cdn-icons-png.flaticon.com/512/3181/3181102.png",
                name: "Wohnwagen",
              },
            ],
            features: [
              {
                icon: "https://icon-library.com/images/water-drop-png-icon/water-drop-png-icon-2.jpg",
                name: "Wasser",
              },
              {
                icon: "https://cdn-icons-png.flaticon.com/512/2797/2797775.png",
                name: "WC",
              },
              {
                icon: "https://www.pngfind.com/pngs/m/312-3123165_png-file-strom-icon-png-transparent-png.png",
                name: "Strom,",
              },
              {
                icon: "https://png.pngtree.com/png-vector/20190223/ourmid/pngtree-wifi-vector-icon-png-image_696445.jpg",
                name: "WLAN",
              },
              {
                icon: "https://icon-library.com/images/dog-icon-png/dog-icon-png-7.jpg",
                name: "Tier",
              },
            ],
          },
          {
            id: 6,
            title: "See Im Schlosstal",
            location: "91322 Dortmund, DE",
            price: "90$ Nacht",
            geheimtipp: false,
            images: [
              "https://images.pexels.com/photos/9917006/pexels-photo-9917006.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
              "https://images.pexels.com/photos/15909375/pexels-photo-15909375.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
              "https://images.pexels.com/photos/13525587/pexels-photo-13525587.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
              "https://images.pexels.com/photos/16486236/pexels-photo-16486236.jpeg",
              "https://images.pexels.com/photos/16469319/pexels-photo-16469319.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
            ],
            likes: "90%",
            tags: [
              {
                icon: "https://png.pngtree.com/png-vector/20190326/ourmid/pngtree-vector-clock-icon-png-image_865317.jpg",
                name: "Zeit",
              },
              {
                icon: "https://e7.pngegg.com/pngimages/185/628/png-clipart-caravan-campervans-computer-icons-car-angle-van.png",
                name: "Wohnmobil & Van",
              },
              {
                icon: "https://cdn3.iconfinder.com/data/icons/camping-party/512/tent-rooftop-camping-travel-car-512.png",
                name: "Dachzelt",
              },
              {
                icon: "https://w7.pngwing.com/pngs/485/971/png-transparent-taxi-car-computer-icons-uber-taxi-driver-car-vehicle-black.png",
                name: "Uber 7m",
              },
              {
                icon: "https://cdn-icons-png.flaticon.com/512/3181/3181102.png",
                name: "Wohnwagen",
              },
            ],
            features: [
              {
                icon: "https://icon-library.com/images/water-drop-png-icon/water-drop-png-icon-2.jpg",
                name: "Wasser",
              },
              {
                icon: "https://cdn-icons-png.flaticon.com/512/2797/2797775.png",
                name: "WC",
              },
              {
                icon: "https://www.pngfind.com/pngs/m/312-3123165_png-file-strom-icon-png-transparent-png.png",
                name: "Strom,",
              },
              {
                icon: "https://png.pngtree.com/png-vector/20190223/ourmid/pngtree-wifi-vector-icon-png-image_696445.jpg",
                name: "WLAN",
              },
              {
                icon: "https://icon-library.com/images/dog-icon-png/dog-icon-png-7.jpg",
                name: "Tier",
              },
            ],
          },
        ],
      }.card_lists)
})

module.exports = router