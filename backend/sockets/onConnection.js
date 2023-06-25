const jwt = require("jsonwebtoken");
const app = require("../urls");
const { default: mongoose } = require("mongoose");
const US = require("./userSocket");
const SS = require("./staffSocket");
const reg = require("./reg")
const OC = require("./onConnection");
const { Grants } = require("../enums/grant");
const { NotifyPage } = require("../models/notifyPage");
const MV = require("../middleware/maintainanceValues")
let io1

exports.io = io1

exports.onConnection = (httpsocket) => {
    OC.io = require("socket.io")(httpsocket)
    OC.io.use(async function(socket, next) {
        var token = socket.handshake.auth["x-access-token"]
        if(!token) return next(new Error(401))
        var deviceId = socket.handshake.auth["device-id"]
        if (token) {
            jwt.verify(token, process.env.JWT_SEC, async (err, userResult) => {
                if (err) return next(new Error(403))
                socket.user = userResult
                socket.grant = userResult.grant
                socket.device = deviceId
                if(socket.grant != Grants.staff && socket.grant != Grants.user){
                    var notifyPage = NotifyPage({admin: socket.user.id, socket: socket.id, grant: socket.grant})
                    await notifyPage.save()
                    socket.notifyPageID = notifyPage._id.toString()
                }
                next();
            });
        }
    }).on('connection', async(socket) => {
        reg.registerSocket(socket)
        MV.emitIfMaintainance(socket.grant, socket.id)
        socket.conn.on("close", await reg.unregisterSocket(socket))
        if(socket.grant == Grants.staff) socket.on('stamp', await SS.handleStamp(socket))  
        if(socket.grant == Grants.user) socket.on('stamp', await US.handleStamp(socket))
        socket.on('end_delivery', await US.handleEndDelivery(socket))
    })
}

const deleteNotifyMany = async ()=> await NotifyPage.deleteMany()
deleteNotifyMany()