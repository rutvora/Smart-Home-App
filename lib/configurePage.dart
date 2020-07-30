import 'package:flutter/material.dart';

import 'globals.dart';

class Configure extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ConfigureState();
}

class _ConfigureState extends State<Configure> {
  @override
  Widget build(BuildContext context) {
    TextEditingController _ssid = TextEditingController();
    TextEditingController _password = TextEditingController();
    TextEditingController _hostname = TextEditingController();
    return Scaffold(
      body: ListView(
        children: [
          TextField(
            controller: _ssid,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(hintText: "Wifi SSID"),
          ),
          TextField(
            controller: _password,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(hintText: "Wifi Password"),
          ),
          TextField(
            controller: _hostname,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(hintText: "Room Name (Case Sensitive)"),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: Icon(Icons.settings),
        label: Text("Save Configuration"),
        onPressed: () {
//                AddController().show();
          GlobalVariables.prefs.clear();
        },
      ),
    );
//    return ListView(
//      children: [
//        TextField(
//          controller: _ssid,
//          keyboardType: TextInputType.text,
//          decoration: InputDecoration(hintText: "Wifi SSID"),
//        ),
//        TextField(
//          controller: _password,
//          keyboardType: TextInputType.text,
//          decoration: InputDecoration(hintText: "Wifi Password"),
//        ),
//        TextField(
//          controller: _hostname,
//          keyboardType: TextInputType.text,
//          decoration: InputDecoration(hintText: "Room Name (Case Sensitive)"),
//        )
//      ],
//    );
  }
}
