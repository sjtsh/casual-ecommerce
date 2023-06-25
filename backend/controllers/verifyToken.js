const jwt = require("jsonwebtoken");
const { default: mongoose } = require("mongoose");
const { Grants } = require("../enums/grant");
const { Staff, DashboardAdmin, SuperAdmin } = require("../models/admin");
const { RequestedShop } = require("../models/order");
const { User } = require("../models/user");
//{outletPermissions = [], shops = []}

function verifyToken(grants) {
    try{
        return (req, res, next) => {
            const token = req.headers["x-access-token"]
            if (token) {
                jwt.verify(token, process.env.JWT_SEC, async (err, userResult) => {
                    if(err) return res.status(401).json({ "message": "Invalid token" })
                    if(grants && grants[0] && userResult.grant != Grants.superAdmin && !grants.includes(userResult.grant) && grants != userResult.grant){
                        return res.status(401).json({ "message": "The function cannot be accessed by you" })
                    }
                    var main = await checkForMaintainance(userResult.grant)
                    if(main) return res.status(400).json({ "message": "The system is currently under maintainance" })
                    var notDe = await checkIfDeactivated(userResult)
                    if(!notDe)  return res.status(401).json({ "message": "Sorry you have been deactivated" })
                    req.user = userResult
                    req.grant = userResult.grant
                    next()
                })
            } else {
                return res.status(401).json({ "message": "A token is required for authentication" })
            }
        }
    }catch(E){
        console.log(E)
        next(E)
    }
}

const checkForMaintainance = async (grant)=>{
    const MV = require("../middleware/maintainanceValues")
    return await MV.getByGrant(grant)
}

const checkIfDeactivated = async (user) => {
    switch (user.grant) {
        case Grants.user:
            var user = await User.findById(user.id)
            return user && !user.deactivated
        case Grants.staff:
            var staff = await Staff.findById(user.id)
            if(!staff) return staff
            var user = await User.findById(staff.user)
            return staff && user && !staff.deactivated && !user.deactivated
        case Grants.dashboardAdmin:
            var dashboardAdmin = await DashboardAdmin.findById(user.id)
            if(!dashboardAdmin) return dashboardAdmin
            var user = await User.findById(dashboardAdmin.user)
            return dashboardAdmin && user && !dashboardAdmin.deactivated && !user.deactivated
        case Grants.superAdmin:
            var superAdmin = await SuperAdmin.findById(user.id)
            if(!superAdmin) return superAdmin
            var user = await User.findById(superAdmin.user)
            return superAdmin && user && !superAdmin.deactivated && !user.deactivated
        default:
            break;
    }
}

function comprehendRole(permission){
    try{
        return async (req, res, next) => {
            if(req.grant != Grants.superAdmin){
                var grantedToShops = await getPermissionList(req.grant, req.user.id, permission)
                if(!grantedToShops.length){
                    console.log(req.user.id, "does not have access to following permissions ( ", permission.toString() +" )")
                    return res.status(401).json({ "message": "The required role has not been granted" })
                }
                var commonGrants = []
                if(req.shopAuthority){
                    var mongooseAuthority = req.shopAuthority.map((e)=> e.toString())
                    for(var i in mongooseAuthority){
                        if(grantedToShops.includes(req.shopAuthority[i])) commonGrants.push(req.shopAuthority[i])
                    }
                } else commonGrants = grantedToShops
                req.shopAuthority = commonGrants
                req.shopAuthorityObject = commonGrants.map((e)=> mongoose.Types.ObjectId(e))
            }
            next()
        }
    }catch(E){
        next(E)
    }
}

const comprehendRoleStaff = async (permission, userID) => {
    var grantedToShops = await getPermissionList(Grants.staff, userID, permission)
    return grantedToShops.length
}

function comprehendOrRole(permissions){
    try{
        return async (req, res, next) => {
            if(req.grant != Grants.superAdmin){
                var mySet = new Set()
                for(var i in permissions){
                    (await getPermissionList(req.grant, req.user.id, permissions[i])).forEach(item => mySet.add(item.toString()))
                }
                var grantedToShops = Array.from(mySet)
                if(!grantedToShops.length){ 
                    console.log(req.user.id, "does not have access to following permissions ( ", permissions.toString() +" )")
                    return res.status(401).json({ "message": "The required role has not been granted" })
                }
                var commonGrants = []
                if(req.shopAuthority){
                    for(var i in req.shopAuthority){
                        if(grantedToShops.includes(req.shopAuthority[i])) commonGrants.push(req.shopAuthority[i])
                    }
                } else commonGrants = grantedToShops
                req.shopAuthority = commonGrants
            }
            next()
        }
    }catch(E){
        next(E)
    }
}

function authorityWithParam(paramKey){
    try{
        return async (req, res, next) => {
            if(req.grant != Grants.superAdmin){
                if(!req.shopAuthority.includes(req.params[paramKey])){
                    return res.status(401).json({ "message": "The required role has not been granted" })
                }
            }
            next()
        }
    }catch(E){
        next(E)
    }
}

function authorityForDelivery(paramKey){
    try{
        return async (req, res, next) => {
            if(req.grant != Grants.superAdmin){
                var request = await RequestedShop.findById(req.body[paramKey])
                if(request.feedback.deliveredBy != req.user.id) return res.status(401).json({ "message": "The required role has not been granted" })
            }
            next()
        }
    }catch(E){
        next(E)
    }
}


const getPermissionList = async(grant, userID, permission)=>{
    var user
    var permissions
    var grantedToShops = []
    switch (grant) {
        case Grants.staff:
            user = await Staff.findById(userID)
            permissions = [user.role]
            break;
        case Grants.dashboardAdmin:
            user = await DashboardAdmin.findById(userID)
            permissions = user.roles
            break;
    }
    for(var k in permissions){
        for(var i in permissions[k].roles){
            for(var j in permissions[k].roles[i].roles){
                if(permission.includes(permissions[k].roles[i].roles[j]) || permission == permissions[k].roles[i].roles[j]){
                    switch (grant) {
                        case Grants.staff:
                            return user.shop;
                        case Grants.dashboardAdmin:
                            grantedToShops.push(permissions[k].shop.toString())
                            break;
                    }
                }
            }
        }
    }
    return grantedToShops
}

module.exports = {verifyToken, comprehendRole, comprehendOrRole, comprehendRoleStaff, authorityWithParam, authorityForDelivery}