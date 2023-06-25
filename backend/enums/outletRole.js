
const { default: mongoose } = require("mongoose");
const OR = require("./outletRole");


exports.OutletRoles = {
    delivery: 'ORdelivery',
    order: 'ORorder',
    product: 'ORproduct',
}

exports.OrderRoles = {
    receive: 'ORorderRolesReceive',
    cancellation: "ORorderRolesCancellation",
    read: "ORorderRolesRead",
}

exports.DeliveryRoles = {
    delivery: "ORdeliveryRolesDelivery",
}

exports.ProductRoles = {
    create: "ORproductRolesCreate",
    read: "ORproductRolesRead",
    update: "ORproductRolesUpdate",
    delete: "ORproductRolesDelete",
}

exports.required =  {
    "ORproductRolesCreate": [ OR.ProductRoles.read],
    "ORproductRolesUpdate": [ OR.ProductRoles.read],
    "ORproductRolesDelete": [ OR.ProductRoles.read],
    "ORorderRolesReceive": [ OR.OrderRoles.read],
    "ORorderRolesCancellation": [ OR.OrderRoles.read],
    "ORdeliveryRolesDelivery": [ OR.OrderRoles.read],
}

exports.getAllOrderRoles = Array.from((new Map(Object.entries(OR.OrderRoles))).values())

exports.getAllDeliveryRoles =  Array.from((new Map(Object.entries(OR.DeliveryRoles))).values())

exports.getAllProductRoles =  Array.from((new Map(Object.entries(OR.ProductRoles))).values())

exports.allSubs = [...OR.getAllOrderRoles,...OR.getAllDeliveryRoles,...OR.getAllProductRoles]

exports.all = [
    {"label": OR.OutletRoles.product, "roles": OR.getAllProductRoles, "group": "Outlets"},
    {"label": OR.OutletRoles.order, "roles": OR.getAllOrderRoles, "group": "Outlets"},
    {"label": OR.OutletRoles.delivery, "roles": OR.getAllDeliveryRoles, "group": "Outlets"},
]