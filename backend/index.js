const cors = require("cors")
const dotenv = require("dotenv")
const express = require("express")
const mongoose = require("mongoose")
const http = require("http")

const socket = require('./sockets/onConnection')

const app = require('./urls')

const socketApp = express()
dotenv.config()

mongoose.connect(process.env.ISPRODUCTION === "false" ? process.env.MONGO_URL_LOCAL : process.env.MONGO_URL_PRODUCTION, {
    useNewUrlParser: true,
    useUnifiedTopology: true
}).then(() => console.log("connection secured")).catch((e) => console.log(`connection unsucessful: ${e}`))

const agenda = require('./jobs/agenda')
app.set("agenda", agenda)
app.use("/static/", express.static("./static/"))
app.use("/data/", express.static("./data/"))

var httpsocket = http.createServer(socketApp)
var httpserver = http.createServer(app)

socket.onConnection(httpsocket)

const AIF = require('./middleware/autoIncrementFunction')
AIF.init()

const V = require('./middleware/values')
V.init()

const MV = require('./middleware/maintainanceValues')
MV.init()

httpserver.listen(process.env.PORT, () => console.log("server started"))
httpsocket.listen(process.env.SOCKET, () => console.log("socket started"))