const dotenv = require("dotenv")
dotenv.config()
const Agenda = require("agenda");
const CS = require("../middleware/change_status");
const { Order, RequestedShop } = require("../models/order");

const agenda = new Agenda({ db: { address: process.env.ISPRODUCTION === "false" ? process.env.MONGO_URL_LOCAL : process.env.MONGO_URL_PRODUCTION, collection: "agendajobs" } , maxConcurrency: 40000, lockLimit: 40000, defaultLockLifetime: 1000});

function processTime(time) {
    if (!time || time < 500) return new Date()
    const dt = new Date();
    dt.setMilliseconds(dt.getMilliseconds() + time);
    return dt;
}

agenda.on('ready', async () =>{ 
    await agenda.start()
})

agenda.on('error', () => console.log("agenda failed!"))


agenda.define("test", async(job,done) => {
    done()
    job.remove()
})

agenda.define("processOrder", async(job,done) => {    
    await CS.failIfNoFeedback(job.attrs.data.orderID, job.attrs.data.userID)
    done()
    job.remove()
})

agenda.define("notifyAsEmergency", async(job, done) => {
    await CS.notifyAsEmergency(job.attrs.data.requestForId, job.attrs.data.user)
    done()
    job.remove()
})

agenda.define("failDeliveryRequest", async(job, done) => {
    await CS.failDeliveryRequest(job.attrs.data.request, job.attrs.data.user)
    done()
    job.remove()
})

agenda.define("urgentCancellation", async(job, done) => {
    await CS.urgentCancellation(job.attrs.data.request)
    done()
    job.remove()
})

const scheduleStartMaintainance = async (key, when)=>{
    const MV = require("../middleware/maintainanceValues");

    await agenda.define("startMaintainance" + key, async(job, done) => {
        await MV.startMaintainance(job.attrs.data.key, true)
        done() 
        job.remove()
        // job.remove()
    })
    console.log("Date()",new Date(), "when", when)
    agenda.schedule(when, "startMaintainance" + key, {key: key})
}

const scheduleEndMaintainance = async (key, when)=>{
    const MV = require("../middleware/maintainanceValues");

    agenda.define("endMaintainance" + key, async(job, done) => {
        await MV.endMaintainance(job.attrs.data.key, true)
        done() 
        job.remove()
        // job.remove()
    })
    agenda.schedule(when, "endMaintainance" + key, {key: key})
}

const scheduleNotifyMaintainance = async (key, when)=>{
    const MV = require("../middleware/maintainanceValues");

    await agenda.define("notifyMaintainance" + key, async(job, done) => {
        await MV.notifyMaintainance(job.attrs.data.key, true)
        done() 
        job.remove()
        // job.remove()
    })
    agenda.schedule(when, "notifyMaintainance" + key, {key: key})
}

agenda.define("fixStuck", async(job, done) => {
    await CS.urgentCancellation(job.attrs.data.request)
    done() 
    job.remove()
    // job.remove()
})


module.exports = { agenda, processTime, scheduleStartMaintainance, scheduleEndMaintainance, scheduleNotifyMaintainance }