const router = require("express").Router();
const CryptoJS = require("crypto-js");
const jwt = require("jsonwebtoken");
const { User, Device} = require("../models/user")
const { DashboardAdmin , Staff, SuperAdmin} = require("../models/admin");
const { Shop } = require("../models/shop")
const G = require("../enums/grant");
const DR = require("../enums/dashboardRole");
const login = require("./login");

exports.getByPhone = async (phone, code, grant)=>{  
    var user
    if(grant != G.Grants.staff && grant != G.Grants.dashboardAdmin){ 
        user = await User.findOne({"phone": phone, "countryCode": code}).populate(["favourites.products","favourites.categories"])
        if(!user) return
    }
    var detail
    switch (grant) {
        case G.Grants.user:
            detail = user
            break
        case G.Grants.staff:
            user = await User.findOne({"phone": phone, "countryCode": code}).select( {_id: 1,name: 1,phone: 1, id: 1, password: 1})
            if(!user) return
            detail = await Staff.findOne({"user": user._id}).select({ available: 1,avgRating: 1,raterCount: 1,ratingStar: 1, _id: 1,shop: 1,role: 1,password: 1,devices: 1, support: 1})
            if(!detail) return
            var shops = []
            for(var i in detail.shop){
                shops.push(await Shop.findById(detail.shop[i]).select( {_id:1,name:1,phone: 1,location: 1,available: 1,id: 1,img:1, address: 1,timing: 1}))
            }
            detail.shop = shops
            break
        case G.Grants.dashboardAdmin:
            user = await User.findOne({"phone": phone, "countryCode": code}).select({ _id: 1, password: 1, devices: 1, name: 1, phone: 1, id: 1})
            detail = await DashboardAdmin.aggregate([{$match: {"user": user._id}},{$project :{roles: { _id: 0, roles:{_id:0}}}}]) 
            if(!detail) return
            detail = {...(detail[0]), "allRoles": DR.all}
            break
        case G.Grants.superAdmin:
            detail = await SuperAdmin.findOne({"user": user._id, "countryCode": code})
            if(!detail) return
            detail = {...(detail._doc), role: {"roles" :DR.all}}
            break
    }
    if(detail)return {user,detail}
}

exports.engageUserWithDevice = async (device, user)=>{
    var found = false
    if(user){
        for (var i in user.devices) {
            if (user.devices[i].deviceId == device.deviceId) {
                user.devices[i].fcmToken = device.fcmToken
                user.devices[i].notify = true
                found = true
            }
        }
        if (found == false)  user.devices.push(Device(device))
        await user.save()
    }
}

exports.removeOtherUsersEngagedInDevice = async (device, grant) => {
    var actions = [{$unwind: "$devices"},{$match: {"devices.deviceId": device.deviceId, "devices.notify": true}},{$group: {_id: "$_id"}}]
    var users  = await login.getByAggregate(grant, actions)
    for(var i in users){
        var userDevice
        userDevice = await login.getById(users[i]._id, grant)
        for (var j in userDevice.devices){
            if(userDevice.devices[j].deviceId == device.deviceId){
                userDevice.devices[j].notify = false
            }
        }
        await userDevice.save()
    }
}


exports.getById = async (id, grant)=>{
    var user
    switch (grant) {
        case G.Grants.user:
            user = await User.findById(id)
            break
        case G.Grants.staff:
            user = await Staff.findById(id)
            break
        case G.Grants.dashboardAdmin:
            user = await DashboardAdmin.findById(id)
            break
        case G.Grants.superAdmin:
            user = await SuperAdmin.findById(id)
            break
    }
    return user
}


exports.getUserById = async (id, grant)=>{
    var user
    switch (grant) {
        case G.Grants.user:
            user = await User.findById(id)
            break
        case G.Grants.staff:
            user = await Staff.findById(id)
            user = await User.findById(user.user)
            break
        case G.Grants.dashboardAdmin:
            user = await DashboardAdmin.findById(id)
            user = await User.findById(user.user)
            break
        case G.Grants.superAdmin:
            user = await SuperAdmin.findById(id)
            user = await User.findById(user.user)
            break
        default:
            throw "undefined grant"
    }
    return user
}
exports.getByAggregate = async (grant, actions)=>{
    var user
    switch (grant) {
        case G.Grants.user:
            user = await User.aggregate(actions)
            break
        case G.Grants.staff:
            user = await Staff.aggregate(actions)
            break
        case G.Grants.dashboardAdmin:
            user = await DashboardAdmin.aggregate(actions)
            break
        case G.Grants.superAdmin:
            user = await SuperAdmin.aggregate(actions)
            break
    }
    return user
}
