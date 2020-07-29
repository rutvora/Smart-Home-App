import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:iot_home/dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splashscreen/splashscreen.dart';

import 'globalVariables.dart';

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => new _SplashState();
}

class _SplashState extends State<Splash> {
  Future<void> initialize(BuildContext context) async {
    Future<SharedPreferences> sharedPrefsFuture =
        SharedPreferences.getInstance();
    sharedPrefsFuture.then((preferences) {
      GlobalVariables.prefs = preferences;
      GlobalVariables.prefs.setString("rooms",
          '{"room name": {"toggles": [{"name": "name", "pin": 1, "type": "bulb"}, {"name": "name", "pin": 2, "type": "bulb"}], "dimmers": [{"name": "name", "pin": 2, "type": "dimmable LED"}]}}');
      String rooms = GlobalVariables.prefs.getString("rooms");
      if (rooms != null) {
        GlobalVariables.rooms = jsonDecode(rooms);
        GlobalVariables.currentRoom = GlobalVariables.rooms.keys.first;
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    initialize(context);
    return new SplashScreen(
        seconds: 0,
        navigateAfterSeconds:
            GlobalVariables.prefs == null ? new Splash() : Dashboard(),
        title: new Text(
          'SplashScreen',
          style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
        ),
        loaderColor: Colors.red);
  }
}
