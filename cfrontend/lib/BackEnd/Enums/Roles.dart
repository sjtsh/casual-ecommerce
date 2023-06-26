

enum Roles {
  order,
  delivery,
  product;

  static Map<Roles, List<dynamic>>? myRoles;
  static List<Map<String, dynamic>>? rolesParsable;

  subRoles() {
    switch (this) {
      case Roles.order:
        return OrderRoles.values;
      case Roles.delivery:
        return DeliveryRoles.values;
      case Roles.product:
        return ProductRoles.values;
    }
  }

  static bool cont(a) {
    return [...getOrderRoles(), ...getDeliveryRoles(), ...getProductRoles()]
        .contains(a);
  }

  // static bool isMyDeliveryRole(MyFeedBack? feedback) {
  //   if (feedback == null) return false;
  //   bool isMyDelivery= feedback.deliveredById ==
  //       CustomKeys.context!.read<SignInManagement>().loginData?.staff.id;
  //   return isMyDelivery;
  // }

  static Map<Roles, List>? setRoles(List<dynamic> json) {
    try {
      rolesParsable = json.map((e) => e as Map<String, dynamic>).toList();
      myRoles ??= {};
      for (Map<String, dynamic> i in json) {
        if (i["label"] == "ORorder") {
          myRoles?[Roles.order] = _recieveRoles(i["roles"], i["label"]);
        }
        if (i["label"] == "ORdelivery") {
          myRoles?[Roles.delivery] = _recieveRoles(i["roles"], i["label"]);
        }
        if (i["label"] == "ORproduct") {
          myRoles?[Roles.product] = _recieveRoles(i["roles"], i["label"]);
        }
      }
      return myRoles;
    } catch (e) {
      print(e);
      return null;
    }
  }

  static List<OrderRoles> getOrderRoles() {
    List? value = myRoles?[Roles.order];
    if (value == null) return [];
    return value as List<OrderRoles>;
  }

  static List<DeliveryRoles> getDeliveryRoles() {
    List? value = myRoles?[Roles.delivery];
    if (value == null) return [];
    return value as List<DeliveryRoles>;
  }

  static List<ProductRoles> getProductRoles() {
    List? value = myRoles?[Roles.product];
    if (value == null) return [];
    return value as List<ProductRoles>;
  }

  static List _recieveRoles(List<dynamic> roles, String label) {
    switch (label) {
      case "ORorder":
        List<OrderRoles> rolesReturnable = [];
        for (var i in roles) {
          for (var element in OrderRoles.values) {
            if (element.name == i.toString()) {
              rolesReturnable.add(element);
            }
          }
        }
        return rolesReturnable;
      case "ORdelivery":
        List<DeliveryRoles> rolesReturnable = [];
        for (var i in roles) {
          for (var element in DeliveryRoles.values) {
            if (element.name == i.toString()) {
              rolesReturnable.add(element);
            }
          }
        }
        return rolesReturnable;
      case "ORproduct":
        List<ProductRoles> rolesReturnable = [];
        for (var i in roles) {
          for (var element in ProductRoles.values) {
            if (element.name == i.toString()) {
              rolesReturnable.add(element);
            }
          }
        }
        return rolesReturnable;
    }
    return [];
  }
}

enum OrderRoles {
  ORorderRolesReceive,
  ORorderRolesCancellation,
  ORorderRolesRead;
}

enum DeliveryRoles {
  ORdeliveryRolesDelivery;
}

enum ProductRoles {
  ORproductRolesCreate,
  ORproductRolesRead,
  ORproductRolesUpdate,
  ORproductRolesDelete;
}
