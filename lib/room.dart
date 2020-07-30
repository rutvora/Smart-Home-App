import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:iot_home/addSwitch.dart';
import 'package:iot_home/globals.dart';

import 'controllers.dart';

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

  List<Widget> getToggles(BuildContext context) {
    List<Widget> widgets = List<Widget>();
    Map room = GlobalVariables.rooms[GlobalVariables.currentRoom];
    List toggles = (room["toggles"]);
    if (toggles != null) {
      toggles.forEach((toggle) {
        widgets.add(Toggle(toggle["pin"], toggle["name"]));
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
        widgets.add(Dimmer(dimmer["pin"], dimmer["name"]));
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
            child: RaisedButton(
          child: Text("Add room"),
          onPressed: () {
            AddRoomDialog.show(context);
          },
        ));
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

class AddRoomDialog extends StatefulWidget {
  static show(BuildContext context) {
    showDialog(
      child: AddRoomDialog(),
      context: context,
    );
  }

  @override
  _AddRoomDialogState createState() => _AddRoomDialogState();
}

class _AddRoomDialogState extends State<AddRoomDialog> {
  TextEditingController _textBoxCtrl = TextEditingController();
  FocusNode _textBoxFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    return new AlertDialog(
      title: Text("Add Room"),
      content: TextField(
        controller: _textBoxCtrl,
        keyboardType: TextInputType.text,
        focusNode: _textBoxFocus,
        autofocus: true,
        decoration:
            InputDecoration(hintText: "Room Name (Same as configuration)"),
      ),
      actions: <Widget>[
        new FlatButton(
            onPressed: () {
              if (_textBoxCtrl.text == "") {
                _textBoxFocus.requestFocus();
                return;
              }
              Map room = Map<String, List>();
              room["toggles"] = List();
              room["dimmers"] = List();
              GlobalVariables.rooms[_textBoxCtrl.text] = room;
              String s = jsonEncode(GlobalVariables.rooms);
              GlobalVariables.prefs.setString("rooms", s);
              Navigator.of(context).pop();
              Room.changeRoom(_textBoxCtrl.text);
              //TODO: Make the snackBar work
//              Scaffold.of(context)
//                  .showSnackBar(SnackBar(content: Text("Room Added")));
            },
            child: Text("Add")),
        new FlatButton(
            onPressed: () => Navigator.of(context).pop(), child: Text("Cancel"))
      ],
    );
  }
}
