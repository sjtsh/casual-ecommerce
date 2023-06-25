const express = require("express")
const app = express()
const compression = require("compression")
const cors = require("cors")
const errorController = require("./controllers/errorController")

app.use(compression())
app.use(express.json())
app.use(cors({ origin: "*" }))
app.use(express.static("static"))
app.use(express.static("data"))
// app.use(errorController)

//----------------------------Helpers----------------------------------------------------
app.use("/upload/", require("./routes/saveImage"))
app.use("/notify/", require("./routes/notify"))
app.use("/developer/", require("./routes/developer"))


//----------------------------Development----------------------------------------------------
app.use("/bulkupload/", require("./routes/bulkupload"))


//----------------------------Dashboard----------------------------------------------------
app.use("/dashboard/analytics/summary/", require("./routes/Dashboard/AnalyticsManagement/summary"))
app.use("/dashboard/analytics/order/", require("./routes/Dashboard/AnalyticsManagement/order"))
app.use("/dashboard/user/staff/", require("./routes/Dashboard/UserManagement/staff"))
app.use("/dashboard/user/customer/", require("./routes/Dashboard/UserManagement/customer"))
app.use("/dashboard/user/role/", require("./routes/Dashboard/UserManagement/role"))
app.use("/dashboard/user/dashboardadmin/", require("./routes/Dashboard/UserManagement/dashboardadmin"))
app.use("/dashboard/outlet/shop/", require("./routes/Dashboard/OutletManagement/shop"))
app.use("/dashboard/outlet/order/", require("./routes/Dashboard/OutletManagement/order"))
app.use("/dashboard/product/sku/", require("./routes/Dashboard/ProductManagement/sku"))
app.use("/dashboard/product/master/", require("./routes/Dashboard/ProductManagement/master"))
app.use("/dashboard/product/subcategory/", require("./routes/Dashboard/ProductManagement/subcategory"))
app.use("/dashboard/product/category/", require("./routes/Dashboard/ProductManagement/category"))
app.use("/dashboard/banner/", require("./routes/Dashboard/BannerManagement/banner"))
app.use("/dashboard/suggestion/", require("./routes/Dashboard/Suggestion/suggestion"))
app.use("/dashboard/settings/values/", require("./routes/Dashboard/Settings/values"))
app.use("/dashboard/settings/maintainance/", require("./routes/Dashboard/Settings/maintainanceValues"))


//----------------------------Staff----------------------------------------------------
app.use("/staff/feedback/", require("./routes/Staff/feedback"))
app.use("/staff/delivery/", require("./routes/Staff/delivery"))
app.use("/staff/order/", require("./routes/Staff/order"))
app.use("/staff/product/", require("./routes/Staff/product"))
app.use("/staff/edit/", require("./routes/Staff/edit"))
app.use("/staff/", require("./routes/Staff/staff"))


//----------------------------User----------------------------------------------------
app.use("/user/search/", require("./routes/User/search"))
app.use("/user/address/", require("./routes/User/address"))
app.use("/user/favourite/", require("./routes/User/favourite"))
app.use("/user/subcategory/", require("./routes/User/subcategory"))
app.use("/user/category/", require("./routes/User/category"))
app.use("/user/product/", require("./routes/User/product"))
app.use("/user/order/", require("./routes/User/order"))
app.use("/user/suggestion/", require("./routes/User/suggestion"))
app.use("/user/feedback/", require("./routes/User/feedback"))
app.use("/user/banner/", require("./routes/User/banner"))
app.use("/user/", require("./routes/User/user"))



//----------------------------Common----------------------------------------------------
app.use("/faasto/product/", require("./routes/StaffUser/product"))
app.use("/faasto/shop/", require("./routes/StaffUser/shop"))
app.use("/auth/", require("./routes/UserManagement/auth"))
app.use("/auth/", require("./routes/UserManagement/login"))

//-------------------------Developer---------------------

// app.use("/developer/", require("./routes/developer"))

//----------------------------Lens----------------------------------------------------
app.use("/lens/", require("./routes/lens/lens_track"))
app.use("/mail/", require("./routes/mail"))



//----------------------------Z-Disposable----------------------------------------------------
// app.use("/user/", require("./routes/user"))
// app.use("/shop/", require("./routes/z-disposable/shop"))
// app.use("/category/", require("./routes/z-disposable/category"))
// app.use("/suggestion/", require("./routes/z-disposable/suggestion"))
// app.use("/product/", require("./routes/z-disposable/products"))
// app.use("/order/", require("./routes/z-disposable/order"))
// app.use("/feedback/", require("./routes/z-disposable/feedback"))
// app.use("/connection/", require("./routes/Staff/connection"))
// app.use("/test/", require("./routes/test"))
// app.use("/subcategory/", require("./routes/z-disposable/subcategory"))
// app.use("/version/", require("./routes/version"))
// app.use("/lens/", require("./routes/lens/lens_track"))
// app.use("/tags/", require("./routes/tags"))
// app.use("/productcrud/", require("./routes/z-disposable/products_partner"))


//----------------------------Always Commented----------------------------------------------------
// app.use("/thread/", require("./routes/thread"))
// app.use("/conversation/", require("./routes/conversation"))

// app.use("/space/", require("./routes/space"))
// app.use("/group_conversation/", require("./routes/group_conversation"))


app.use(errorController)
module.exports = app