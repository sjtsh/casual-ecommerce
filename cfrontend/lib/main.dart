
import 'package:ezdelivershop/BackEnd/StaticService/StaticService.dart';
import 'package:flutter/material.dart';
import 'BackEnd/Enums/ServerService.dart';
import 'Pre/MyApp.dart';

void main() {
  ServerService.printAllUrls();
  StaticService.beforeMain();
  runApp(const MyApp());
}

//TODO: Order details, feed back screen product details