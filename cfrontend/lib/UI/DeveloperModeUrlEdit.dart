
import 'package:ezdelivershop/Components/AppDivider/Appdivider.dart';
import 'package:ezdelivershop/Components/Constants/SpacePalette.dart';
import 'package:ezdelivershop/Components/Widgets/ButtonOutline.dart';
import 'package:ezdelivershop/Components/snackbar/customsnackbar.dart';
import 'package:flutter/material.dart';

import '../BackEnd/Enums/Roles.dart';
import '../BackEnd/Services/DeveloperService.dart';
import '../BackEnd/StaticService/StaticService.dart';

class DeveloperModeUrlEdit extends StatefulWidget {
  @override
  State<DeveloperModeUrlEdit> createState() => _DeveloperModeUrlEditState();
}

class _DeveloperModeUrlEditState extends State<DeveloperModeUrlEdit> {
  List<Map<String, dynamic>> updatable = [];

  addToUpdatable(String key, String value) {
    int? index;
    for (int i = 0; i < updatable.length; i++) {
      if (updatable[i]["label"].toString() == key) {
        index = i;
      }
    }
    if (index == null) {
      updatable.add({
        "label": key,
        "roles": [value]
      });
    } else {
      updatable[index]["roles"].add(value);
    }
  }

  removeFromUpdatable(String key, String value) {
    int? index;
    for (int i = 0; i < updatable.length; i++) {
      if (updatable[i]["label"].toString() == key) {
        index = i;
      }
    }
    if (index != null) {
      updatable[index]["roles"].remove(value);
      if (updatable[index]["roles"] == []) updatable.removeAt(index);
    }
  }

  containsInUpdatable(String key, String value) {
    int? index;
    for (int i = 0; i < updatable.length; i++) {
      if (updatable[i]["label"].toString() == key) {
        index = i;
      }
    }
    if (index != null) return updatable[index]["roles"].contains(value);
    return false;
  }

  @override
  void initState() {
    super.initState();
    setState(() => updatable = Roles.rolesParsable!);
  }

  Widget buildRolesWidget(List<dynamic> data) {
    Map<String, List<dynamic>> display = {};
    for (var element in data) {
      display[element["label"]] = element["roles"];
    }

    return Column(
      children: [
        Row(
          children: display.entries
              .map((e) => Expanded(
                      child: Column(
                    children: [
                      Text(e.key.capitalize()),
                      SizedBox(
                        height: 12,
                      ),
                      ...e.value
                          .map((f) => Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 1.0, horizontal: 3),
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: Checkbox(
                                          value: containsInUpdatable(e.key, f),
                                          onChanged: (bool? boolean) {
                                            if (boolean == null) return;
                                            if (boolean) {
                                              addToUpdatable(e.key, f);
                                            } else {
                                              removeFromUpdatable(e.key, f);
                                            }
                                            setState(() {});
                                          }),
                                    ),
                                    Expanded(
                                        child: Text(
                                      f,
                                      maxLines: 3,
                                    ))
                                  ],
                                ),
                              ))
                          .toList()
                    ],
                  )))
              .toList(),
        ),
        SizedBox(
          height: 12,
        ),
        AppButtonOutline(
            onPressedFunction: () async {
              bool success = await DeveloperService().updateRoles(updatable);
              if (success) {
                Roles.setRoles(updatable);
                CustomSnackBar().success("Roles Updated");
                return;
              }
              setState(() => updatable = Roles.rolesParsable!);
              CustomSnackBar().error("Could not update roles");
            },
            text: "Update Roles")
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
          Column(
            children: [
              AppDivider(),
              SpacePalette.spaceLarge,
              FutureBuilder(
                  future: DeveloperService().getRoles(),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.hasData) {
                      return buildRolesWidget(snapshot.data);
                    }
                    return CircularProgressIndicator();
                  }),
              SpacePalette.spaceLarge,
              AppDivider(),
              SizedBox(
                height: 20,
              ),
            ],
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: TextField(
            controller: StaticService.localhost,
            decoration:
                const InputDecoration(labelText: "Localhost (192.168.101.10)"),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: StaticService.httpPort,
                  decoration:
                      const InputDecoration(labelText: "http port (10000)"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: StaticService.socketPort,
                  decoration:
                      const InputDecoration(labelText: "socket port (10001)"),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
