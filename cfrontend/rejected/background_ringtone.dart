
// //------------Testing shared prefs
// SharedPreferences prefs0 = await SharedPreferences.getInstance();
// prefs0.setString("test", "this is now working");
//
//
// //------------Shared prefs Implementation
// SharedPreferences prefs = await SharedPreferences.getInstance();
// print("prefs ringtone: ${prefs.getBool("ringtone")}");
// print("test: ${prefs.getString("test")}");
//
// //------------Testing date time instance
// print("dateTime: ${DateTime.now()}");
//
// //------------Hive Implementation
// Directory dir = await getApplicationDocumentsDirectory();
// Hive.init(dir.path);
// await Hive.openBox("box");
// await Hive.openBox("box");
// Box boxGet = Hive.box('box');
// print('hiveRingtone:: ${boxGet.get('ringtone')}');
//
// //------------Http Implementation
// Response? success = (await ApiService.get("connection", withToken: false));
// print('httpRingtone:: ${success?.body}');