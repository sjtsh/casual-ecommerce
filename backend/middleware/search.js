
const { default: mongoose } = require("mongoose");

exports.search = async(Collection, query, postQuery)=>{
    var items=[]
    if(!postQuery) postQuery = []
    if (query) {
        var items = await Collection.aggregate([
            {
                $match: {
                    $text: {
                        $caseSensitive: false,
                        $search: query
                    }
                }
            },
            ...postQuery,
            { $sort: {score: { $meta: "textScore" }}},
        ]);
        
        if(items.length==0)
        {
            var items = await Collection.aggregate([
                {
                    $match: {
                        $or: [ {name: new RegExp(query, "gi")}, {tags: new RegExp(query, "gi")}, {barcode: new RegExp(query, "gi")}]
                    }
                },
                ...postQuery,
            ]);
        }
        return items;
    }
}