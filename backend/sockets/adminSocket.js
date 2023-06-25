const { default: mongoose, Collection } = require("mongoose");
const { RequestedShop, Order } = require("../models/order");
const OC = require("./onConnection")
const DSKU = require("../middleware/serialization/dashboardSKU")
const DR = require("../enums/dashboardRole").DashboardRoles
const DOrder = require("../middleware/serialization/dashboardOrder.js");
const DCustomer = require("../middleware/serialization/dashboardCustomer");
const DSuggestion = require("../middleware/serialization/dashboardSuggestion");
const { Product } = require("../models/product");
const { Staff } = require("../models/admin");
const { User } = require("../models/user");
const { ProductSuggestion } = require("../models/productSuggestion");


exports.updateOrder = async(message, socketID) => await emitAdmins(DR.orders, concatU(message), await findShop(Order, message), socketID)
exports.createOrder = async(message, socketID) => await emitAdmins(DR.orders, concatC(message), await findShop(Order, message), socketID)

exports.updateShop = async(message, socketID) => await emitAdmins(DR.outlets, concatU(message), message._id, socketID)
exports.createShop = async(message, socketID) => await emitAdmin(DR.outlets, concatC(message), "SA", socketID)

exports.updateBanner = async(message, socketID) => await emitAdmins(DR.banner, concatU(message), "SA", socketID)
exports.createBanner = async(message, socketID) => await emitAdmin(DR.banner, concatC(message), "SA", socketID)

exports.updateCategory = async(message, socketID) => await emitAdmins(DR.categories, concatU(message), "DA", socketID)
exports.createCategory = async(message, socketID) => await emitAdmins(DR.categories, concatC(message), "DA", socketID)

exports.updateSubcategory = async(message, socketID) => await emitAdmins(DR.subCategories, concatU(message), "DA", socketID)
exports.createSubcategory = async(message, socketID) => await emitAdmins(DR.subCategories, concatC(message), "DA", socketID)

exports.updateMaster = async(message, socketID) => await emitAdmins(DR.master, concatU(message), "DA", socketID) 
exports.createMaster = async(message, socketID) => await emitAdmins(DR.master, concatC(message), "DA", socketID)

exports.updateCustomer = async(message) => await emitAdmin(DR.customers, concatU(message), "SA") 
exports.createCustomer = async(message) => await emitAdmin(DR.customers, concatC(message), "SA")

exports.updateSuggestion = async(message) => await emitAdmin(DR.suggestions, concatU(message), "SA") 
exports.createSuggestion = async(message) => await emitAdmin(DR.suggestions, concatC(message), "SA")

exports.updateCustomer = async(message) => await emitAdmins(DR.customers, concatU(message), "DA") 
exports.createCustomer = async(message) => await emitAdmins(DR.customers, concatC(message), "DA")

exports.updateProductFromID = async(message, socketID) => await this.updateProduct(await DSKU.getSKU(message), socketID)
exports.createProductFromID = async(message, socketID) => await this.createProduct(await DSKU.getSKU(message), socketID)
exports.updateProduct = async(message, socketID) => await emitAdmins(DR.product, concatU(message), await findShop(Product, message), socketID)
exports.createProduct = async(message, socketID) => await emitAdmins(DR.product, concatC(message), await findShop(Product, message), socketID)

exports.updateStaff = async(message, socketID) => await emitAdmins(DR.staff, concatU(message), await findShop(Staff, message), socketID)
exports.createStaff = async(message, socketID) => await emitAdmins(DR.staff, concatC(message), await findShop(Staff, message), socketID)

exports.updateRoleProfile = async(message, socketID) => await emitAdmin(DR.role, concatU(message), "SA", socketID)
exports.createRoleProfile = async(message, socketID) =>  await emitAdmin(DR.role, concatC(message), "SA", socketID)

exports.createCustomerById = async(id) =>{
    var results = await User.aggregate([{$match: {_id: id}}, ...DCustomer.serialization])
    await this.createCustomer(results[0])
}

exports.createSuggestionById = async(id) =>{
    var results = await ProductSuggestion.aggregate([{$match: {_id: id}}, ...DSuggestion.serialization])
    await this.createSuggestion(results[0])
}

exports.createOrderById = async(id, socketID)=>{
    var results = await Order.aggregate([{$match: {_id: id}}, ...DOrder.serialization])
    results = results[0]
    await this.createOrder(results, socketID)
}

exports.updateOrderById =  async (id, socketID) =>{
    var results = await Order.aggregate([{$match: {_id: mongoose.Types.ObjectId(id.toString())}}, ...DOrder.serialization])
    results = results[0]
    await this.updateOrder(results, socketID)
}

exports.updateDashboardAdmin = async(message, prevRoles, currentRoles) => {
    var prevOutlets = generateOutletsToNotify(prevRoles, new Set())
    var notifyShops = generateOutletsToNotify(currentRoles, prevOutlets)
    for(var i in notifyShops){
        emitAdmin(DR.admin, concatU(message), notifyShops[i])
    }
    emitSA(DR.admin, concatU(message))
}

exports.createDashboardAdmin = async(message) => {
    var notifyShops = generateOutletsToNotify(message.roles, new Set())
    for(var i in notifyShops){
        emitAdmin(DR.admin, concatC(message), notifyShops[i])
    }
    emitSA(DR.admin, concatC(message))
}

exports.emitBanner = async(message) => await emitSA("banner", message)

//-------------------------------EMITS------------------------------------------------------

const emitAdmins = async (group, message, shop, socketID) =>{
    if(shop) await emitAdmin(group, message, shop, socketID)
    await emitAdmin(group, message, "SA", socketID)
}

const emitSA = async (group, message) => await emitAdmin(group, message, "SA")

//-------------------------------HELPER------------------------------------------------------

const emitAdmin = async (group, message, shop, socketID)=>{
    if(!socketID || socketID == null) return await OC.io.in(shop.toString()).emit(group, message)
    await OC.io.in(shop.toString()).except(socketID).emit(group, message)
}


const concatU = (message) => concat(message, "u")
const concatC = (message) => concat(message, "c")

const concat = (message, mode) => {
    if(!message) message = {} 
    message["mode"] = mode
    return message
}

const findShop = async(Collection, message) =>{
    if(message.shop) return message.shop
    var prod = await Collection.findById(message._id)
    if(prod) return prod.shop
}

const generateOutletsToNotify = (roles, returnable) => {
    for(var i in roles){
        returnable.add(roles[i].shop.toString())
    }
    return returnable
}

const comprehendAdminSocketRole = () =>{
    
}