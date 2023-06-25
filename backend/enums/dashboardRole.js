
const { default: mongoose } = require("mongoose")
const DR = require("./dashboardRole")
const OR = require("./outletRole")

const buildElement = (label, roles) => {return {"label": label, "roles": roles, "group": this.getRoleGroup(label)}}
const getAll = (e) => Array.from(new Map(Object.entries(e)).values())

exports.DashboardRoles = {
    orders: "order",
    categories: "categories",
    subCategories: "subCategories",
    product: "product",
    master: "master",
    customers: "customers",
    staff: "staff",
    admin: "admin",
    returns: "returns",
    notifications: "notifications",
    outlets: "outlet",
    banner: "banner",
    role:"role",
    suggestions:"suggestions",
    global: "global",
    maintainance: "maintainance"
}

exports.OrdersRoles = {read: "orderRolesRead"}
exports.CustomersRoles = {read: "customersRolesRead"}
exports.ReturnsRoles = {read: "returnsRolesRead",update: "returnsRolesUpdate"}
exports.NotificationsRoles = {read: "notificationsRolesRead",create: "notificationsRolesCreate"}
exports.StaffsRoles = {create: "staffsRolesCreate",read: "staffsRolesRead",update: "staffsRolesUpdate",delete: "staffsRolesDelete"}
exports.AdminsRoles = {create: "adminsRolesCreate",read: "adminsRolesRead",update: "adminsRolesUpdate",delete: "adminsRolesDelete"}
exports.OutletsRoles = {create: "outletsRolesCreate",read: "outletsRolesRead",update: "outletsRolesUpdate",delete: "outletsRolesDelete",approve: "outletsRolesApprove"}
exports.ProductRoles = {create: "productRolesCreate",read: "productRolesRead",update: "productRolesUpdate",delete: "productRolesDelete",approve: "productRolesApprove"}
exports.MasterRoles = {create: "masterRolesCreate",read: "masterRolesRead",update: "masterRolesUpdate",delete: "masterRolesDelete",approve: "masterRolesApprove"}
exports.SubCategoriesRoles = {create: "subCategoriesRolesCreate",read: "subCategoriesRolesRead",update: "subCategoriesRolesUpdate",delete: "subCategoriesRolesDelete"}
exports.CategoriesRoles = {create: "categoriesRolesCreate",read: "categoriesRolesRead",update: "categoriesRolesUpdate",delete: "categoriesRolesDelete"}
exports.BannerRoles = {create: "bannerRolesCreate",read: "bannerRolesRead",update: "bannerRolesUpdate",delete: "bannerRolesDelete"}
exports.RoleRoles = {create: "roleRolesCreate",read: "roleRolesRead",update: "roleRolesUpdate",delete: "roleRolesDelete"}
exports.SuggestionRoles = {read: "suggestionRolesRead"}
exports.GlobalRoles = {read: "globalRolesRead", update: "globalRolesUpdate"}
exports.MaintainanceRoles = {read: "maintainanceRolesRead", update: "maintainanceRolesUpdate", delete: "maintainanceRolesDelete"}

exports.getAllOrdersRoles = getAll(this.OrdersRoles)
exports.getAllReturnsRoles = getAll(this.ReturnsRoles)
exports.getAllCustomersRoles = getAll(this.CustomersRoles)
exports.getAllNotificationsRoles = getAll(this.NotificationsRoles)
exports.getAllStaffsRoles = getAll(this.StaffsRoles)
exports.getAllAdminsRoles = getAll(this.AdminsRoles)
exports.getAllProductRoles = getAll(this.ProductRoles)
exports.getAllMasterRoles = getAll(this.MasterRoles)
exports.getAllSubCategoriesRoles = getAll(this.SubCategoriesRoles)
exports.getAllCategoriesRoles = getAll(this.CategoriesRoles)
exports.getAllOutletsRoles = getAll(this.OutletsRoles)
exports.getAllBannerRoles = getAll(this.BannerRoles)
exports.getAllSuggestionRoles = getAll(this.SuggestionRoles)
exports.getAllRoles = getAll(this.RoleRoles)
exports.getAllGlobalRoles = getAll(this.GlobalRoles)
exports.getAllMaintainanceRoles = getAll(this.MaintainanceRoles)

exports.getRoleGroup = (label)=>{
    switch (label) {
        case this.DashboardRoles.orders:
            return "Order"
        case this.DashboardRoles.outlets:
            return "Outlets"
        case this.DashboardRoles.categories:
            return "Products"
        case this.DashboardRoles.subCategories:
            return "Products"
        case this.DashboardRoles.product:
            return "Products"
        case this.DashboardRoles.master:
            return "Products"
        case this.DashboardRoles.admin:
            return "Users"
        case this.DashboardRoles.staff:
            return "Users"
        case this.DashboardRoles.customers:
            return "Users"
        case this.DashboardRoles.role:
            return "Users"
        case this.DashboardRoles.returns:
            return "Returns"
        case this.DashboardRoles.notifications:
            return "Notification"
        case this.DashboardRoles.banner:
            return "Banners"
        case this.DashboardRoles.suggestions:
            return "Suggestions"
        case this.DashboardRoles.global:
            return "Settings"
        case this.DashboardRoles.maintainance:
            return "Settings"
        case OR.OutletRoles.product:
            return "Outlets"
        case OR.OutletRoles.order:
            return "Outlets"
        case OR.OutletRoles.delivery:
            return "Outlets"
        default:
            return "Dashboard"
    }
}


exports.providable = [
    buildElement(this.DashboardRoles.orders, this.getAllOrdersRoles),
    buildElement(this.DashboardRoles.outlets, this.getAllOutletsRoles),
    buildElement(this.DashboardRoles.categories, this.getAllCategoriesRoles),
    buildElement(this.DashboardRoles.subCategories, this.getAllSubCategoriesRoles),
    buildElement(this.DashboardRoles.product, this.getAllProductRoles),
    buildElement(this.DashboardRoles.master, this.getAllMasterRoles),
    buildElement(this.DashboardRoles.admin, this.getAllAdminsRoles),
    buildElement(this.DashboardRoles.staff, this.getAllStaffsRoles),
    buildElement(this.DashboardRoles.customers, this.getAllCustomersRoles),
    buildElement(this.DashboardRoles.returns, this.getAllReturnsRoles),
    buildElement(this.DashboardRoles.notifications, this.getAllNotificationsRoles),
    ...OR.all,
]


exports.all = [
    ...this.providable,
    buildElement(this.DashboardRoles.banner, this.getAllBannerRoles),
    buildElement(this.DashboardRoles.role, this.getAllRoles),
    buildElement(this.DashboardRoles.suggestions, this.getAllSuggestionRoles),
    buildElement(this.DashboardRoles.global, this.getAllGlobalRoles),
    buildElement(this.DashboardRoles.maintainance, this.getAllMaintainanceRoles),
    ...OR.all,
]

exports.allSubs = [
    ...DR.getAllOrdersRoles,
    ...DR.getAllOutletsRoles,
    ...DR.getAllCategoriesRoles,
    ...DR.getAllSubCategoriesRoles,
    ...DR.getAllProductRoles,
    ...DR.getAllMasterRoles,
    ...DR.getAllAdminsRoles,
    ...DR.getAllStaffsRoles,
    ...DR.getAllCustomersRoles,
    ...DR.getAllReturnsRoles,
    ...DR.getAllNotificationsRoles,
    ...DR.getAllSuggestionRoles,
    ...DR.getAllGlobalRoles,
    ...DR.getAllMaintainanceRoles,
    ...OR.allSubs
]