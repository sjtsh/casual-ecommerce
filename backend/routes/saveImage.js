const fs = require("fs")
const router = require("express").Router()
const formidable = require('formidable');
const { response } = require("../urls");

const assetDirectory="/var/www/vhosts/hilifefoods.com.np/uploads/uploads/";
router.post('/', async (req, res, next) => {
    try {
        const form = formidable({ multiples: true })
        var root = process.env.ISPRODUCTION == "false" ? "static/" : assetDirectory

        // var id
        // if (req.distributor) {
        //     id = req.distributor.id
            
        // } else {
        //     id = req.user.id
        // }
    
        // if (!id) {
        //     return res.status(403).json({ "error": "Couldnt find id in access token" })
        // }
        var thisUploadDir = root + "/temp/"
        if (!fs.existsSync(thisUploadDir)) {
            fs.mkdirSync(thisUploadDir, { recursive: true })
        }
        form.uploadDir = thisUploadDir
        if (!fs.existsSync(root)) {
            fs.mkdirSync(root, { recursive: true })
        }
        form.keepExtensions = true;

        form.on('fileBegin', function (name, file) {
            file.filepath = form.uploadDir + name;
        })
        form.parse(req, async(err, fields, files) => {

            if (err) {
                next(err);
                return;
            }
            let response = {}
    
            // New promise based loop to upload multiple files 
            const entries= [...Object.entries(files)].map(async([key,value])=>{
                
                var downloadUrl =  await saveImage({ image: value.filepath, path: fields[key], filename: value.originalFilename, })
                response[value.originalFilename]=downloadUrl
            })
            await Promise.all(entries);
            //
            // single file approach 
            // Object.entries(files).forEach(async ([key, value]) => {

            //     var downloadUrl = saveImage({ image: value.filepath, path: fields[key], filename: value.originalFilename, })
            //     response.set(value.originalFilename,downloadUrl ) ;
            // })
         
                // console.log(response)
            return res.status(200).json(response);
        })
    }
    catch (e) {
        next(e)
    }
})

async function saveImage({
    image,
    path,
    filename,
}) {
    var root = process.env.ISPRODUCTION == "false" ? "static/" :assetDirectory

    if (!fs.existsSync(root  + path)) {
        fs.mkdirSync(root  + path, { recursive: true })
    }
    fs.rename(image, root  + path + "/" + filename, (err) => {
        if (err) {
            console.log("Error Found:", err);
            console.log("unsuccessful");
        }
    });

    var accessibleRoot = process.env.ISPRODUCTION == "false" ? "http://localhost:10000/static/" : "https://uploads.faasto.co/uploads/"
    return accessibleRoot + path + "/" + filename;
}

module.exports = {
    saveImage
};

module.exports = router


// async function resizeImage(options,op,filename){

//     return new Promise((resolve,reject)=>{
//       // console.log(filename)
//       sharp(op).resize(options).toFile(filename).then((detail)=>{
//         // console.log(op,filename)
//        resolve()
    
    
//        }).catch((err)=>{
//         console.log(err)
//         reject(err)
    
//        })
//     })
  
//   }