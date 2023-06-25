
const { default: mongoose } = require("mongoose");
const { Order } = require("../models/order");
const WL = require("./withLength");

const DH = require("../middleware/dashboard_helper")
const SG = require("../middleware/ShopGrants")
const SC = require("../middleware/speedCheck")
const Q = require("../enums/query")

exports.withLength = async(Collection, query, projectList, req)=>{
    if(!query) query = []
    var results = await Collection.aggregate([...query, WL.withLengthQueries(projectList, req)])
    return this.handle(results)
}

exports.handle = (results)=>{
    if(!results.length) return {data: [], count: 0}
    return results[0]
}

exports.serializerProject = (projectList)=>{
    var projectorWithBool = new Map()
    for(var i in projectList){
        projectorWithBool.set(projectList[i], 1)
    }
    return projectorWithBool
}


exports.withLengthQueries = (projectList, req)=>{
    if(!projectList.includes("createdAt")) projectList.push("createdAt")

    var projectorWithDollar = new Map()
    var projectorWithBool = new Map()
    var projectorWithBoolNoCount = new Map()
    for(var i in projectList){
        projectorWithDollar.set(projectList[i], "$" + projectList[i])
        projectorWithBool.set(projectList[i], 1)
        projectorWithBoolNoCount.set(projectList[i], 1)
    }
    projectorWithBool.set("count", "$count")
    return [
        ...withDateFilterQueries(req),
        ...withSearchQueries(req),
        {$project:{"dummy": projectorWithDollar,}}, 
        {$group: { _id: 1, count: { $sum: 1 }, dummy: {$push: "$dummy"} } },
        {$project: {dummy: projectorWithBool}},
        {$unwind: "$dummy"},
        ...withSortQueries(req),
        ...withSkipLimitQueries(req),
        {$group: {_id: "$dummy.count", data: {$push: "$dummy"}}},
        {$project:{count:"$_id", data:1, _id:0}},
        {$project:{count:1, data: projectorWithBoolNoCount}},
    ]
}

const handleQueriesWithCountLocal = async (Collection, req, queries, m) => {
    if(!m) m = {}
    var q = m.q
    if(!q) q = Q.all

    var qs = []
    var ps = []
    var qc = []

    var {qs, qc} = handleSearch(qs, qc, q, req)
    var {qs, qc} = handleSpecificPre(qs, qc, m)
    var {qs, qc} = handleSpecificParam(qs, qc, m, req)
    var {qs, qc, ps} = handleSpecificQuery(q, qs, qc, ps, req)
    // var {qs, ps} = handleReport(qs, ps, req.query.report) //when using report mode

    var data = await Collection.aggregate([...qs, ...queries, ...ps])
    if(!q.includes(Q.Queries.length)) return data

    var count = {}
    if(qc.length) count = await Collection.aggregate(qc)
    else count.length = await Collection.count()

    return {"data": data, "count": count.length}
}

exports.handleQueriesWithCount = async (Collection, req, queries, m) => {
    return await SC.logIt(
        async ()=> await handleQueriesWithCountLocal(Collection, req, queries, m), 
        [req.baseUrl, "on", Collection]
    )
}


const withSkipLimitQueries = (req)=>{
    var skip = req.query.skip ? parseInt(req.query.skip ): 0
    var limit = req.query.limit ? parseInt(req.query.limit) : 20
    if(req.query.s) return [{$limit: limit},]
    return [{$skip: skip},{$limit: limit},]
}

const withSortQueries = (req) => {
    var field = req.query.sortField
    if(field){
        var fieldWithAsc = {}
        if(!req.query.asc || req.query.asc == "true") fieldWithAsc[field] = 1
        else fieldWithAsc[field] = -1
        return [{$sort: fieldWithAsc}]
    }
    if(req.query.s && !req.query.sp) return [{$sort: {score: { $meta: "textScore" }}}]
    return [{$sort: {createdAt:-1}},]   
}

const withSearchQueries = (req) =>{
    if(!req.query.s) return []
    var field = req.query.sp
    if(field){ 
        field = field.split(",")
        var queries = []
        for(var i in field){
            var map = new Map()
            map.set(field[i],  new RegExp(req.query.s, "gi"))
            queries.push(map)
        }
        return [{$match: {$or: queries}},]
    }
    return [{$match: {$text: {$caseSensitive: false, $search: req.query.s}}},]
}

const withDateFilterQueries = (req)=>{
    if(req.query.s) return []
    if(!req.query.startDate || !req.query.endDate) return []
    // if(process.env.ISPRODUCTION === "false"){
    //     startDate = new Date(dateWithTime.getFullYear(), dateWithTime.getMonth(), dateWithTime.getDate(),  dateWithTime.getHours() + 5, dateWithTime.getMinutes() + 45, dateWithTime.getSeconds(), 0) // true for non production server
    //     endDate = new Date(dateWithTime.getFullYear(), dateWithTime.getMonth(), dateWithTime.getDate() - 1,  dateWithTime.getHours() + 5, dateWithTime.getMinutes() + 45, dateWithTime.getSeconds(), 0)
    // }else{
    //     startDate = new Date(dateWithTime.getFullYear(), dateWithTime.getMonth(), dateWithTime.getDate(),  dateWithTime.getHours(), dateWithTime.getMinutes() , dateWithTime.getSeconds() , 0) // true for production server
    //     endDate = new Date(dateWithTime.getFullYear(), dateWithTime.getMonth(), dateWithTime.getDate() - 1,dateWithTime.getHours(), dateWithTime.getMinutes() , dateWithTime.getSeconds() , 0) // true for production server
    // }
    var q =  [{$match: {"createdAt": {$gt: new Date(req.query.startDate), $lte: new Date(req.query.endDate)}}}]
    return q
}

const handleSpecificQuery = (q, qs, qc, ps, req) =>{
    for(var i in q){
        switch (q[i]) {
            case Q.Queries.date:
                qs = [...qs, ...withDateFilterQueries(req)]
                qc = [...qc, ...withDateFilterQueries(req)]
                break
            case Q.Queries.sort:
                ps = [...ps, ...withSortQueries(req)]
                break
            case Q.Queries.skip:
                ps = [...ps, ...withSkipLimitQueries(req)]
                break
            default:
                break
        }
    }
    return {qs, qc, ps} 
}

const handleSpecificParam = (qs, qc, m, req)=>{
    var param = m.param
    if(param){
        qs = [...qs, ...SG.filterQueryGet(req, param)]
        qc = [...qc, ...SG.filterQueryGet(req, param)]
    }
    return {qs, qc}
}

const handleSearch = (qs, qc, q, req)=>{
    if(q.includes(Q.Queries.search)){
        qs = [...qs, ...withSearchQueries(req)]
        qc = [...qc, ...withSearchQueries(req)]
    }
    return {qs, qc}
}

const handleSpecificPre = (qs, qc, m)=>{
    var pre = m.pre
    if(pre){
        qs = [...qs, ...pre]
        qc = [...qc, ...pre]
    }
    return {qs, qc}
}

const handleReport = (qs, ps, report) =>{
    if(!report || report == "false"){ 
        qs = [...qs, ...ps]
        ps = []
    }
    return {qs, ps}
}

exports.dtFilter = (req)=>{
    return withDateFilterQueries(req)
}