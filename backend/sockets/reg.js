
const { default: mongoose } = require("mongoose");
const reg = require("./reg")

const OC = require("./onConnection");
const { Grants } = require("../enums/grant");
const { User } = require("../models/user");
const { DashboardAdmin, Staff } = require("../models/admin");
const { NotifyPage } = require("../models/notifyPage");

exports.staffToSocket = new Map()
exports.socketToStaff = new Map()
exports.userToSocket = new Map()
exports.socketToUser = new Map()
exports.staffToDevice = new Map()


exports.waitTime = 120000
exports.unregisterSocket = async(socket) => {
    try{
        const close = async(data) => {
            if (socket.user.grant == Grants.staff) {
                updateD(Staff, socket.user.id)
                if(reg.staffToDevice.get(socket.user.id) == socket.device) reg.staffToDevice.delete(socket.user.id)
                if(reg.staffToSocket.get(socket.user.id) == socket.id) reg.staffToSocket.delete(socket.user.id)
                reg.socketToStaff.delete(socket.id)
            } else if (socket.user.grant == Grants.user)  {
                updateD(User, socket.user.id)
                if(reg.userToSocket.get(socket.user.id) == socket.id) reg.userToSocket.delete(socket.user.id)
                reg.socketToUser.delete(socket.id)
            }
            if(socket.user.grant == Grants.dashboardAdmin) updateD(DashboardAdmin, socket.user.id)
            if(socket.notifyPageID) await NotifyPage.findByIdAndDelete(socket.notifyPageID)
        }
        return close
    }catch(e){
        console.log(e)
    }
}

exports.registerSocket = async (socket) => {
    try{
        var socketUser = socket.user.id.toString()
        switch (socket.user.grant) {
            case Grants.staff:
                updateC(Staff, socket.user.id)
                var deviceID = reg.staffToDevice.get(socketUser)
                if (deviceID && deviceID != socket.device) OC.io.to(reg.staffToSocket.get(socketUser)).emit('session_expired', 'Another device is trying to login')
                if(socket.device) reg.staffToDevice.set(socketUser, socket.device)
                reg.staffToSocket.set(socketUser, socket.id)
                reg.socketToStaff.set(socket.id, socketUser)
                break
            case Grants.user:
                updateC(User, socket.user.id)
                if (reg.userToSocket.has(socketUser)) OC.io.to(reg.userToSocket.get(socketUser)).emit('session_expired', 'Another device is trying to login')
                socket.join("banner")
                reg.userToSocket.set(socketUser, socket.id)
                reg.socketToUser.set(socket.id, socketUser)
                break
            case Grants.superAdmin:
                socket.join("SA")
                break
            default:
                updateC(DashboardAdmin, socket.user.id)
                var admin = await DashboardAdmin.findById(socketUser)
                if(!admin) return
                socket.join("DA")
                for(var i in admin.roles){
                    socket.join(admin.roles[i].shop.toString())
                }
                break
        }
    }catch(e){
        console.log(e)
    }
}

const updateC = async (Collection, id)=>{
    var staff = await Collection.findById(id)
    if(!staff) return
    staff.lastConnected = new Date()
    await staff.save()
}

const updateD = async (Collection, id)=>{
    var staff = await Collection.findById(id)
    if(!staff) return
    staff.lastDisconnected = new Date()
    await staff.save()
}
