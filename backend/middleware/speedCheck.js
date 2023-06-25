

exports.logIt = async (func, logs) =>{
    var start = new Date()
    var response = await func()
    var diff = ( new Date()).getTime() - start.getTime()
    var important = "(OK)"
    if(diff >= 500) important = "(!)"
    if(diff >= 1000) important = "(!!)"
    if(diff >= 10000) important = "(!!!)"

    var length = response.length
    if(!length && response.data) length = response.data.length
    if(!length) length = "-"
    console.log(...logs, "->", length, "entries in" , diff, "ms", important,)
    return response
}