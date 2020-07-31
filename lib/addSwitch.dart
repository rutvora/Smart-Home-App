import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:iot_home/controllers.dart';
import 'package:iot_home/globals.dart';

/// Menu to select available toggles and add them to the room's list.
/// Note: A single device may be added as both a toggle and a dimmer.
class AddToggles extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AddTogglesState();
}

class _AddTogglesState extends State<AddToggles> {
  final double padding = 10;

  // Toggles selected to be added
  List<bool> selected = List.filled(9, false);

  //Toggles currently supposed to be on
  List<bool> on = List.filled(9, false);

  /// Shows the arduino pin numbers not currently added to a room.
  List<Widget> getAvailableToggles() {
    List widgets = List<Widget>();
    List<bool> pins = List.filled(9, false);
    List toggles =
        GlobalVariables.rooms[GlobalVariables.currentRoom]["toggles"];
    for (var toggle in toggles) {
      pins[toggle["pin"]] = true;
    }
    for (int i = 0; i < 9; i++) {
      if (!pins[i])
        widgets.add(Card(
            child: ListView(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          children: [
            Toggle(i, "Pin " + i.toString(),
                Key("Add Toggle Pin " + i.toString()), false, (isOn) {
              setState(() {
                on[i] = isOn;
              });
            }),
            FlatButton(
                color: selected[i]
                    ? Colors.lightGreen
                    : on[i] ? Colors.lightBlue : Theme.of(context).cardColor,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                onPressed: () {
                  setState(() {
                    selected[i] = !selected[i];
                  });
                },
                child: Row(children: [
                  Icon(
                    selected[i] ? Icons.check : Icons.add,
                    color: selected[i] || on[i]
                        ? Colors.white
                        : Theme.of(context).iconTheme.color,
                  ),
                  Flexible(
                      child: Center(
                          child: Text(selected[i] ? "Added" : "Add",
                              style: TextStyle(
                                  fontSize: 18,
                                  color: selected[i] || on[i]
                                      ? Colors.white
                                      : Theme
                                      .of(context)
                                      .textTheme
                                      .bodyText1
                                      .color))))
                ])),
          ],
        )));
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Add Toggles"),
        ),
        body: GridView.count(
          crossAxisCount:
          MediaQuery
              .of(context)
              .orientation == Orientation.portrait
              ? 2
              : 4,
          childAspectRatio:
          MediaQuery
              .of(context)
              .orientation == Orientation.portrait
              ? 1
              : 1.05,
          children: getAvailableToggles(),
          padding: EdgeInsets.all(padding),
          shrinkWrap: true,
        ),
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              List toggles =
              GlobalVariables.rooms[GlobalVariables.currentRoom]["toggles"];

              for (int i = 0; i < selected.length; i++) {
                if (selected[i]) {
                  Map map = Map();
                  map["name"] = "Pin " + i.toString();
                  map["pin"] = i;
                  map["type"] = "default";
                  toggles.add(map);
                }
              }
              GlobalVariables.rooms[GlobalVariables.currentRoom]["toggles"] =
                  toggles;
              GlobalVariables.prefs
                  .setString("rooms", jsonEncode(GlobalVariables.rooms));
              Navigator.of(context).pop();
            },
            child: Icon(Icons.check, color: Colors.white)));
  }
}

/// Menu to select available dimmers and add them to the room's list.
/// Note: A single device may be added as both a toggle and a dimmer.
class AddDimmers extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AddDimmersState();
}

class _AddDimmersState extends State<AddDimmers> {
  final double padding = 10;

  // Dimmers currently selected to be added to the room
  List<bool> selected = List.filled(9, false);

  /// Shows the arduino pin numbers not currently added to a room.
  List<Widget> getAvailableDimmers() {
    List widgets = List<Widget>();
    List<bool> pins = List.filled(9, false);
    List dimmers =
    GlobalVariables.rooms[GlobalVariables.currentRoom]["dimmers"];
    for (var dimmer in dimmers) {
      pins[dimmer["pin"]] = true;
    }
    for (int i = 0; i < 9; i++) {
      if (!pins[i])
        widgets.add(Card(
            child: ListView(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              children: [
                Dimmer(i, "Pin " + i.toString(),
                    Key("Add Dimmer Pin " + i.toString()), false),
                FlatButton(
                    color: selected[i]
                        ? Colors.lightGreen
                        : Theme
                        .of(context)
                        .cardColor,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    onPressed: () {
                      setState(() {
                        selected[i] = !selected[i];
                      });
                    },
                    child: Row(children: [
                      Icon(
                        selected[i] ? Icons.check : Icons.add,
                        color: selected[i]
                            ? Colors.white
                            : Theme
                            .of(context)
                            .iconTheme
                            .color,
                  ),
                  Expanded(
                      child: Center(
                          child: Text(selected[i] ? "Added" : "Add",
                              style: TextStyle(
                                  fontSize: 18,
                                  color: selected[i]
                                      ? Colors.white
                                      : Theme
                                      .of(context)
                                      .textTheme
                                      .bodyText1
                                      .color))))
                ])),
          ],
        )));
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Add Dimmers"),
        ),
        body: GridView.count(
          crossAxisCount:
              MediaQuery.of(context).orientation == Orientation.portrait
                  ? 1
                  : 2,
          childAspectRatio:
              MediaQuery.of(context).orientation == Orientation.portrait
                  ? 2.4
                  : 2.5,
          children: getAvailableDimmers(),
          padding: EdgeInsets.all(padding),
          shrinkWrap: true,
        ),
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              List dimmers =
              GlobalVariables.rooms[GlobalVariables.currentRoom]["dimmers"];

              for (int i = 0; i < selected.length; i++) {
                if (selected[i]) {
                  Map map = Map();
                  map["name"] = "Pin " + i.toString();
                  map["pin"] = i;
                  map["type"] = "default";
                  dimmers.add(map);
                }
              }
              GlobalVariables.rooms[GlobalVariables.currentRoom]["dimmers"] =
                  dimmers;
              GlobalVariables.prefs
                  .setString("rooms", jsonEncode(GlobalVariables.rooms));
              Navigator.of(context).pop();
            },
            child: Icon(Icons.check, color: Colors.white)));
  }
}
