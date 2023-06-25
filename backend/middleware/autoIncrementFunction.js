const { Counters } = require("../models/counter")

var counterMap = new Map()
var dateMap = new Map()

var initRan= false

const possibleWrecklessCounterFields = ["order", "master", "product"]
const possiblyNot = ["category", "shop", "order_item", "order", "user", "sub_category", "ProductSuggestion", "staff", "dashboardAdmin", "banner"]

const autoIncrementID =async (next) => {
    try{
        var sequenceDocument = counterMap.get(next)
        if(!sequenceDocument) sequenceDocument = 0
        sequenceDocument += 1
        counterMap.set(next, sequenceDocument)
        updateSequence(next)
        return sequenceDocument.toString()
    }
    catch(e){next(e)}
}

const init = async ()=>{ 
    if(initRan == false){
        initRan = true
        await handleWrecklessCounters()
        var countersDB = await Counters.find()
        for(var i in countersDB){
            counterMap.set(countersDB[i].field, countersDB[i].sequence_value)
        }
    }
}

const updateSequence = async (next) =>{
    var rightNow = (new Date()).getSeconds()
    dateMap.set(next, rightNow)
    setTimeout(async () => {
        if(rightNow == dateMap.get(next)){
            await justUpdate(next)
        }        
    }, 100);
}

const handleWrecklessCounters = async ()=>{
    for(var i in possibleWrecklessCounterFields){
        var entry = await Counters.findOne({"field": possibleWrecklessCounterFields[i]})
        if(!entry){ 
            var c = Counters({ field: possibleWrecklessCounterFields[i], sequence_value: 0})
            await c.save()
        }
    }
}


const justUpdate = async (next)=>{
    var sequenceDocument = await Counters.findOne({ field: next })
    if(sequenceDocument){
        sequenceDocument.sequence_value = counterMap.get(next)
        await sequenceDocument.save()
    }else{
        var sequenceDocument = Counters({ field: next, sequence_value: counterMap.get(next)})
        await sequenceDocument.save()
    }
} 


module.exports = {autoIncrementID, init};
