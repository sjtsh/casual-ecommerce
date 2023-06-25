const { MaintainanceValues } = require("../models/maintainanceValues")
const A = require('../jobs/agenda')
const V = require('../middleware/values')
const { Grants } = require("../enums/grant");
const OC = require("../sockets/onConnection");
const reg = require("../sockets/reg")

// maintainanceValues
var maintainanceValues = new Map()
var useMaintainanceWarnings = new Map()

const useMaintainanceWarning = (key)=>{
    return useMaintainanceWarnings.get(key)
}
const loadCurrentlyUnderMaintainance = async ()=>{
    var values = await MaintainanceValues.find()
    for(var i in values){
        var should = getShould(values[i])
        var warningShould = await getWarningShould(values[i])
        
        if(warningShould) warningShould = true
        else warningShould = false
        useMaintainanceWarnings.set(values[i].key, warningShould)

        if(should) startMaintainance(values[i].key)
        else endMaintainance(values[i].key)
    }
}

const getShould = (value) => value && value != null && value.when && value.when <= new Date() &&  new Date() < getEndAt(value.when, value.howLong)

const getWarningShould = async (value) => value && value != null && value.when && !getShould(value) && value.when >= new Date() &&  new Date() > getEndAt(value.when,  await calcPreDuration() , true)

const reload = async()=>{
    var values =  await MaintainanceValues.find()
    var local = new Map()
    for(var i in values){
        local.set(values[i].key, values[i])
    }
    return local
}

const loadPromise = new Promise((resolve, reject) => {
    reload().then( async (e)=>{
        await loadCurrentlyUnderMaintainance()
        resolve(e);
    })
})

const getList = async()=>{
    var keyValue = await reload()
    var res = []
    var keys = Array.from(keyValue.keys())
    for(var i in keys){
        res.push(await getOne(keys[i]))
    }
    return res
}

const getOne = async (key)=>{
    var keyValue = await reload()
    var should = getShould(keyValue.get(key))
    if(!should) should = false
    else should = true
    var figure = figureForKey(key, should)
    return {"key": key, "when": keyValue.get(key).when, "howLong": keyValue.get(key).howLong, ...figure}
}

const getMaintainance = async ()=> { 
    await loadPromise
    return maintainanceValues
}

const init = async ()=>{
    var keyValue = await loadPromise
    var storeDefaults = ["orderSystem","dashboardSystem","partnerSystem","userSystem"]
    for(var i in storeDefaults){
        var key = storeDefaults[i]
        if(!keyValue.get(key)) {
            var value = MaintainanceValues({"key": key})
            await value.save()
            keyValue.set(key, value)
            maintainanceValues.set(key, false)
        }
    }  
}

const start = async (key, when, howLong, rightNow)=>{
    await cancelAgendasFor(key)
    var maintainanceValue = await MaintainanceValues.findOne({key: key})
    if(!when) maintainanceValue.when = rightNow
    else maintainanceValue.when = new Date(when)
    maintainanceValue.howLong = howLong
    await maintainanceValue.save()

    var rightAway = rightNow.getTime() >= getEndAt(maintainanceValue.when, 10000, true).getTime()
    if(rightAway){
        startMaintainance(key, true)
    }else {
        A.scheduleStartMaintainance(key, maintainanceValue.when)
        var preDuration = await calcPreDuration()
        var to = getEndAt(maintainanceValue.when, preDuration, true)
        rightAway = rightNow.getTime() >= to.getTime()
        if(rightAway){
            notifyMaintainance(key, maintainanceValue.when, true)
        }else{
            A.scheduleNotifyMaintainance(key, to)
        }
    }
    if(howLong){
        A.scheduleEndMaintainance(key, getEndAt(maintainanceValue.when, howLong))
    }
}

const cancel = async (key)=>{
    var maintainanceValue = await MaintainanceValues.findOne({key: key})
    maintainanceValue.when = null
    maintainanceValue.howLong = null
    await maintainanceValue.save()
    await cancelAgendasFor(key)
}

const cancelAgendasFor = async (key)=>{
    await A.agenda.cancel({name: "notifyMaintainance" + key})
    await A.agenda.cancel({name: "startMaintainance" + key})
    await A.agenda.cancel({name: "endMaintainance" + key})
}

const calcPreDuration = async()=>{
    var dataMap = await V.get()
    possibleDeliveryTime = dataMap.get("possibleDeliveryTime")
    var max
    possibleDeliveryTime.split(",").map((element)=>{
        var val = parseInt(element)
        if(!max) max = val
        if(val > max) max = val
        return val
    })
    return max * 60000 + parseInt(dataMap.get("cancellationWaitTime")) + 10000
}

const getEndAt = (when1, howLong, subtract)=>{
    var when = new Date(when1)
    if (!howLong || howLong < 500) return when
    if(subtract) when.setMilliseconds(when.getMilliseconds() - howLong)
    else when.setMilliseconds(when.getMilliseconds() + howLong)
    return when
}

const startMaintainance = async (key, notify)=>{
    maintainanceValues.set(key, true)
    if(notify) await notifyMaintainanceStart(key)
}

const notifyMaintainance = async (key, when, notify)=>{
    if("dashboardSystem" != key) useMaintainanceWarnings.set(key, when)
    if(notify) await notifyMaintainanceWarning(key)
}

const endMaintainance = async (key, notify)=>{
    maintainanceValues.set(key, false)
    if(notify){
        await cancel(key)
        await notifyMaintainanceEnd(key)
    }
}

const getSocketsByGrant  = async (grant)=>{
    var sockets = []
    if(grant == Grants.staff){
        sockets = reg.staffToSocket.values()
    }else if(grant == Grants.user){
        sockets = reg.userToSocket.values()
    }
    // if(specificSocket)
    // else all
}

//TODO: Socket magic, socket when connected call the warning again with specific socket arg

const notifyMaintainanceWarning = async (key, specificSocket)=>{
    var grant = grantByKey(key)
    var sockets = getSocketsByGrant(grant)

    // if(specificSocket)
    // else all
}

const notifyMaintainanceStart = async (key, specificSocket)=>{
    var grant = grantByKey(key)
    // if(specificSocket)
    // else all
}

const notifyMaintainanceEnd = async (key, specificSocket)=>{
    var grant = grantByKey(key)
    // if(specificSocket)
    // else all
}

const emitIfMaintainance = async (specificSocket, grant)=>{
    //need to emit also if maintainance warning
    var maintainance = await getByGrant(grant)
    if(maintainance == true) {
        await notifyMaintainanceStart(getKeyByGrant(grant), specificSocket)
    }
}

//------------------------------------------------------------------

const getByGrant = async(grant)=>{
    var maintainanceMap = await getMaintainance()
    var key = getKeyByGrant(grant)
    if(!key) return false //for superadmin
    return maintainanceMap.get(key)
}

const getKeyByGrant = (grant)=>{
    if(grant == Grants.user) return "userSystem"
    if(grant == Grants.staff) return "partnerSystem"
    if(grant == Grants.dashboardAdmin) return "dashboardSystem"
    return //for superadmin
}

const grantByKey = (key)=>{ 
    if(key == "partnerSystem") return  Grants.staff
    if(key == "dashboardSystem") return  Grants.dashboardAdmin
    return  Grants.user //for userSystem || order system
}

const figureForKey = (key, should)=>{
    var nickname
    var group
    var type
    switch (key) {
        case "orderSystem":
            nickname = "Order System"
            group = "order"
            type = "duration"
            break;
        case "dashboardSystem":
            nickname = "Dashboard System"
            group = "dashboard"
            type = "duration"
            break;
        case "partnerSystem":
            nickname = "Partner System"
            group = "partner"
            type = "duration"
            break;
        case "userSystem":
            nickname = "User System"
            group = "user"
            type = "duration"
            break;
        default:
            break;
    }
    return {"nickname": nickname, "group": group, "type":type, "value": should}
}

module.exports = {
    init,
    getList,
    start,
    cancel,
    startMaintainance,
    endMaintainance,
    getMaintainance,
    notifyMaintainance, 
    getByGrant, 
    emitIfMaintainance,
    useMaintainanceWarning,
    getOne,
    maintainanceValues,
} 




