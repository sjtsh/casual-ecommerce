const { Staff } = require("../models/admin")
const { Values } = require("../models/values")

const min = 60000
var keyValue = new Map()

const reload = async ()=>{
    var values = await Values.find()
    var local = new Map()
    for(var i in values){
        local.set(values[i].key, values[i].value)
    }
    return local
}

const loadPromise = new Promise((resolve, reject) => {
    reload().then((e)=>{
        
        resolve(e);
    })
})


const set = async (key, value)=>{
    keyValue.set(key, value)
    var updatable = await Values.findOne({"key": key})
    updatable.value = value
    await updatable.save()
}

const init = async ()=>{ 
    keyValue = await loadPromise
    await storeDefault("failAfter", min * 5) //order response timeout
    await storeDefault("failDeliveryRequestAfter",  10 * min) //delivery response timeout
    await storeDefault("cancellationWaitTime", 10 * min) // delivery completed response timeout
    await storeDefault("deliveryCost", 10 * 10)
    await storeDefault("support", 9801022530)
    await storeDefault("signUp", false)
    await storeDefault("possibleDeliveryTime", "10,20,30")
    
}


const get = async () => keyValue
const getFromKey = (key) => keyValue.get(key)

const getList = async()=>{
    keyValue = await loadPromise
    var res = []
    var keys = Array.from(keyValue.keys())
    for(var i in keys){
        var figure = figureForKey(keys[i])
        res.push({"key": keys[i], "value": keyValue.get(keys[i]), ...figure})
    }
    return res
}

const storeDefault = async (key, value)=>{
    if(!keyValue.get(key)) {
        var value
        value = Values({"key": key,"value": value})
        await value.save()
        keyValue.set(key, value)
    }
}

const test = async()=>{
    await reload()
    var staffs = await Staff.find({support: null})
    for (var i in  staffs){
        if(!staffs[i].support){
            staffs[i].support = await getFromKey("support")
            await staffs[i].save()
        }
    }
}

// test()

const figureForKey = (key)=>{
    var nickname
    var group
    var type
    switch (key) {
        case "failAfter":
            nickname = "Order Response Timeout"
            group = "order"
            type = "duration"
            break;
        case "failDeliveryRequestAfter":
            nickname = "Delivery Response Timeout"
            group = "order"
            type = "duration"
            break;
        case "cancellationWaitTime":
            nickname = "Delivery Completed Response Timeout"
            group = "delivery"
            type = "duration"
            break;
        case "deliveryCost":
            nickname = "Delivery Cost"
            group = "delivery"
            type = "cost"
            break;
        case "possibleDeliveryTime":
            nickname = "Delivery Time"
            group = "delivery"
            type = "listInt"
            break;
        case "support":
            nickname = "Support"
            group = "support"
            type = "phone"
            break;
        case "signUp":
            nickname = "New Registration"
            group = "user"
            type = "boolean"
            break;
        default:
            break;
    }
    return {"nickname": nickname, "group": group, "type":type}
}

module.exports = {init, get, set, getList, getFromKey};




