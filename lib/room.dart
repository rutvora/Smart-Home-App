import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:iot_home/addSwitch.dart';
import 'package:iot_home/globals.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:progress_dialog/progress_dialog.dart';

import 'controllers.dart';
import 'loadingAnimations.dart';
import 'network.dart';

/// Returns the room screen with toggles and dimmers.
/// Provides a static function [changeRoom] to change the room when browsing rooms
class Room extends StatefulWidget {
  static var _roomState;

  static bool changeRoom(String room) {
    if (_roomState == null)
      return false;
    else {
      _roomState.updateState(() {
        GlobalVariables.currentRoom = room;
      });
      return true;
    }
  }

  @override
  _RoomState createState() {
    _roomState = _RoomState();
    return _roomState;
  }
}

class _RoomState extends State<Room> {
  void updateState(Function() fun) {
    setState(fun);
  }

  final double padding = 10;

  /// Connects to broker and sets callback for connection change status
  void initialize() async {
    ProgressDialog progressDialog;
    progressDialog = pleaseWait(context, "Connecting to broker...");
    await progressDialog.show();
    InternetAddress broker;
    while (broker == null) {
      broker = await resolveMDNS('broker');
    }
    GlobalVariables.localBroker = MQTT(broker, (connected) async {
      if (!connected && !progressDialog.isShowing()) {
        await progressDialog.show();
      } else if (connected && progressDialog.isShowing()) {
        // Hacky fix as directly calling hide doesn't work when the status changes too quickly
        await progressDialog.hide();
      }
    });
    GlobalVariables.localBroker.connectToBroker();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => initialize());
  }

  List<Widget> getToggles(BuildContext context) {
    List<Widget> widgets = List<Widget>();
    Map room = GlobalVariables.rooms[GlobalVariables.currentRoom];
    List toggles = (room["toggles"]);
    if (toggles != null) {
      toggles.forEach((toggle) {
        print(toggle["name"]);
        widgets.add(Toggle(toggle["pin"], toggle["name"],
            Key(GlobalVariables.currentRoom + toggle["pin"].toString())));
      });
    }
    widgets.add(Card(
        child: FlatButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddToggles()),
              );
              setState(() {});
            },
            child: Row(children: [
              Icon(
                Icons.add_circle,
              ),
              Expanded(
                  child: Center(
                      child: Text("Add Switch",
                          style: TextStyle(
                            fontSize: 18,
                          ))))
            ])),
        margin: EdgeInsets.all(padding)));
    return widgets;
  }

  List<Widget> getDimmers(BuildContext context) {
    List<Widget> widgets = List<Widget>();
    Map room = GlobalVariables.rooms[GlobalVariables.currentRoom];
    List dimmers = (room["dimmers"]);
    if (dimmers != null) {
      dimmers.forEach((dimmer) {
        widgets.add(Dimmer(dimmer["pin"], dimmer["name"],
            Key(GlobalVariables.currentRoom + dimmer["pin"].toString())));
      });
    }
    widgets.add(Card(
        child: FlatButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddDimmers()),
              );
              setState(() {});
            },
            child: Row(children: [
              Icon(
                Icons.add_circle,
              ),
              Expanded(
                  child: Center(
                      child: Text("Add Dimmer",
                          style: TextStyle(
                            fontSize: 18,
                          ))))
            ])),
        margin: EdgeInsets.all(padding)));
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    if (GlobalVariables.currentRoom == null) {
      if (GlobalVariables.rooms.length == 0)
        return Center(
            child: Card(
                color: Theme.of(context).buttonColor,
                child: FlatButton(
                  child: Text(
                    "Find New Rooms",
                    style: TextStyle(fontSize: 20),
                  ),
                  onPressed: () {
                    discoverRooms(context);
                  },
                )));
      else
        GlobalVariables.currentRoom = GlobalVariables.rooms.keys.first;
    }
    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        GridView.count(
          crossAxisCount:
              MediaQuery.of(context).orientation == Orientation.portrait
                  ? 2
                  : 4,
          children: getToggles(context),
          padding: EdgeInsets.all(padding),
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
        ),
        GridView.count(
          crossAxisCount:
              MediaQuery.of(context).orientation == Orientation.portrait
                  ? 1
                  : 2,
          childAspectRatio: 3,
          children: getDimmers(context),
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
        )
      ],
    );
  }
}

class EditRoomNameDialog extends StatefulWidget {
  final String _room;

  EditRoomNameDialog(this._room);

  static show(BuildContext context, String room) {
    showDialog(
      child: EditRoomNameDialog(room),
      context: context,
    );
  }

  @override
  _EditRoomNameDialogState createState() => _EditRoomNameDialogState(_room);
}

class _EditRoomNameDialogState extends State<EditRoomNameDialog> {
  TextEditingController _textBoxCtrl = TextEditingController();
  FocusNode _textBoxFocus = FocusNode();
  String room;

  _EditRoomNameDialogState(this.room);

  @override
  Widget build(BuildContext context) {
    return new AlertDialog(
      title: Center(child: Text(GlobalVariables.rooms[room]["name"])),
      content: TextField(
        controller: _textBoxCtrl,
        keyboardType: TextInputType.text,
        focusNode: _textBoxFocus,
        autofocus: true,
        decoration: InputDecoration(hintText: "New Room Name"),
      ),
      actions: <Widget>[
        new FlatButton(
            onPressed: () {
              if (_textBoxCtrl.text == "") {
                _textBoxFocus.requestFocus();
                return;
              }
              GlobalVariables.rooms[room]["name"] = _textBoxCtrl.text;
              String s = jsonEncode(GlobalVariables.rooms);
              GlobalVariables.prefs.setString("rooms", s);
              Navigator.of(context).pop();
            },
            child: Text("OK")),
        new FlatButton(
            onPressed: () => Navigator.of(context).pop(), child: Text("Cancel"))
      ],
    );
  }
}

void discoverRooms(BuildContext context) {
  ProgressDialog progressDialog = pleaseWait(context);
  progressDialog.show();
  GlobalVariables.localBroker.subscribe("/discoverRooms/response", (c) {
    final MqttPublishMessage recMess = c[0].payload;
    final pt =
    MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
    print(pt);
    if (GlobalVariables.rooms.containsKey(pt)) return;
    Map emptyRoom = Map();
    emptyRoom["toggles"] = List();
    emptyRoom["dimmers"] = List();
    emptyRoom["name"] = pt;
    GlobalVariables.rooms[pt] = emptyRoom;
    GlobalVariables.prefs.setString("rooms", jsonEncode(GlobalVariables.rooms));
  });
  MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
  builder.addString("Get rooms"); //Just to have a non-null message
  GlobalVariables.localBroker.publish("/discoverRooms", builder);
  Future.delayed(Duration(seconds: 10)).then((_) {
    GlobalVariables.localBroker.unsubscribe("/discoverRooms/response");
    progressDialog.hide();
  });
}
