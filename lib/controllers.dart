import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:iot_home/globals.dart';
import 'package:mqtt_client/mqtt_client.dart';

import 'room.dart';

/// Card representing a toggle switch to control the electrical device.
/// [_pin] is the Arduino pin number the toggle is representing.
/// [_name] is the user given name of that toggle.
/// [_isRoom] determines the padding and other parameters of the card to change
/// it's outlook based on the UI it is a child of. Defaults to true.
/// [_changeListener] is an optional argument for a function to be notified of
/// value change in the toggle's state.
class Toggle extends StatefulWidget {
  final int _pin;
  final String _name;
  final bool _isRoom;
  final Function _changeListener;

  Toggle(this._pin, this._name, [this._isRoom = true, this._changeListener]);

  @override
  State<Toggle> createState() =>
      _ToggleState(_pin, _name, _isRoom, _changeListener);
}

class _ToggleState extends State<Toggle> {
  int _pin;
  String _name;
  bool _on = false;
  final bool _isRoom;
  final Function changeListener;
  final double padding = 10;

  _ToggleState(this._pin, this._name, this._isRoom, this.changeListener);

  void showEditNameDialogBox() {
    TextEditingController _textBoxCtrl = TextEditingController();
    FocusNode _textBoxFocus = FocusNode();
    showDialog(
        context: context,
        child: AlertDialog(
          title: Text("Change Switch Name"),
          content: TextField(
            controller: _textBoxCtrl,
            keyboardType: TextInputType.text,
            focusNode: _textBoxFocus,
            autofocus: true,
            decoration: InputDecoration(hintText: "New switch name"),
          ),
          actions: <Widget>[
            new FlatButton(
                onPressed: () {
                  if (_textBoxCtrl.text == "") {
                    _textBoxFocus.requestFocus();
                    return;
                  }
                  List toggles = GlobalVariables
                      .rooms[GlobalVariables.currentRoom]["toggles"];
                  for (int i = 0; i < toggles.length; i++) {
                    if (toggles[i]["pin"] == _pin) {
                      toggles[i]["name"] = _textBoxCtrl.text;
                      break;
                    }
                  }
                  GlobalVariables.rooms[GlobalVariables.currentRoom]
                      ["toggles"] = toggles;
                  GlobalVariables.prefs
                      .setString("rooms", jsonEncode(GlobalVariables.rooms));
                  Navigator.of(context).pop();
                  //TODO: Not refreshing the page for some reason
                  Room.changeRoom(GlobalVariables.currentRoom);
                },
                child: Text("OK")),
            new FlatButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text("Cancel"))
          ],
        ));
  }

  /// Returns the longPress Context Menu containing Edit and Delete Options
  void onLongPressToggle() {
    showDialog(
        context: context,
        child: AlertDialog(
            title: Center(child: Text(_name)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                    child: FlatButton(
                  child: Text("Delete"),
                  onPressed: () {
                    List toggles = GlobalVariables
                        .rooms[GlobalVariables.currentRoom]["toggles"];
                    for (var toggle in toggles) {
                      if (toggle["pin"] == _pin) {
                        toggles.remove(toggle);
                        break;
                      }
                    }
                    GlobalVariables.rooms[GlobalVariables.currentRoom]
                        ["toggles"] = toggles;
                    GlobalVariables.prefs
                        .setString("rooms", jsonEncode(GlobalVariables.rooms));
                    Navigator.of(context).pop();
                    Room.changeRoom(
                        GlobalVariables.currentRoom); //Redraw the room
                  },
                )),
                Card(
                    child: FlatButton(
                  child: Text("Edit name"),
                  onPressed: () {
                    Navigator.of(context).pop();
                    showEditNameDialogBox();
                  },
                )),
              ],
            )));
  }

  /// Makes the actual toggle MQTT call
  void toggleSwitch() {
    MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addByte(_pin); //pin number
    builder.addBool(val: false); //isPWM
    builder.addBool(val: _on); //State
    //TODO: Set topic
    GlobalVariables.localBroker.publish("/test", builder);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        child: InkWell(
          child: Container(
              color: _on ? Colors.lightBlue : Theme.of(context).cardColor,
              child: ListView(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  Center(
                      child: Container(
                          padding: EdgeInsets.all(padding),
                          child: Text(
                            _name,
                            style: TextStyle(
                                fontSize: 20,
                                color: _on
                                    ? Colors.white
                                    : Theme
                                    .of(context)
                                    .textTheme
                                    .bodyText1
                                    .color),
                          ))),
                  Center(
                      child: Container(
                          padding: EdgeInsets.all(padding),
                          child: FittedBox(
                              fit: BoxFit.none,
                              alignment: Alignment.topCenter,
                              child: Icon(
                                Octicons.light_bulb,
                                size: 80,
                                color: _on
                                    ? Colors.yellow
                                    : Theme
                                    .of(context)
                                    .textTheme
                                    .bodyText1
                                    .color,
                              ))))
                ],
              )),
          onTap: () {
            setState(() {
              _on = !_on;
            });
            if (changeListener != null) changeListener(_on);
            toggleSwitch();
          },
          onLongPress: () => onLongPressToggle(),
        ),
        margin: EdgeInsets.all(_isRoom ? padding : 0));
  }
}

/// Card representing a dimmer to control the electrical device
/// [_pin] is the Arduino pin number the dimmer is representing
/// [_name] is the user given name of that dimmer
/// [_isRoom] determines padding and other parameters of the card to change it's
/// outlook based on the UI it is a child of. Defaults to true
class Dimmer extends StatefulWidget {
  final int _pin;
  final String _name;
  final bool _isRoom;

  Dimmer(this._pin, this._name, [this._isRoom = true]);

  @override
  State<Dimmer> createState() => _DimmerState(_pin, _name, _isRoom);
}

class _DimmerState extends State<Dimmer> {
  int _pin;
  String _name;
  final double padding = 10;
  double val = 0;
  final bool _isRoom;

  _DimmerState(this._pin, this._name, this._isRoom);

  void showEditNameDialogBox() {
    TextEditingController _textBoxCtrl = TextEditingController();
    FocusNode _textBoxFocus = FocusNode();
    showDialog(
        context: context,
        child: AlertDialog(
          title: Text("Change Switch Name"),
          content: TextField(
            controller: _textBoxCtrl,
            keyboardType: TextInputType.text,
            focusNode: _textBoxFocus,
            autofocus: true,
            decoration: InputDecoration(hintText: "New switch name"),
          ),
          actions: <Widget>[
            new FlatButton(
                onPressed: () {
                  if (_textBoxCtrl.text == "") {
                    _textBoxFocus.requestFocus();
                    return;
                  }
                  List dimmers = GlobalVariables
                      .rooms[GlobalVariables.currentRoom]["dimmers"];
                  for (int i = 0; i < dimmers.length; i++) {
                    if (dimmers[i]["pin"] == _pin) {
                      dimmers[i]["name"] = _textBoxCtrl.text;
                      break;
                    }
                  }
                  GlobalVariables.rooms[GlobalVariables.currentRoom]
                  ["dimmers"] = dimmers;
                  GlobalVariables.prefs
                      .setString("rooms", jsonEncode(GlobalVariables.rooms));
                  Navigator.of(context).pop();
                  //TODO: Not refreshing the page for some reason
                  Room.changeRoom(GlobalVariables.currentRoom);
                },
                child: Text("OK")),
            new FlatButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text("Cancel"))
          ],
        ));
  }

  /// Returns the longPress Context Menu containing Edit and Delete Options
  void onLongPress() {
    showDialog(
        context: context,
        child: AlertDialog(
            title: Center(child: Text(_name)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                    child: FlatButton(
                      child: Text("Delete"),
                      onPressed: () {
                        List dimmers = GlobalVariables
                            .rooms[GlobalVariables.currentRoom]["dimmers"];
                        for (var dimmer in dimmers) {
                          if (dimmer["pin"] == _pin) {
                            dimmers.remove(dimmer);
                            break;
                          }
                        }
                        GlobalVariables.rooms[GlobalVariables.currentRoom]
                        ["dimmers"] = dimmers;
                        GlobalVariables.prefs
                            .setString(
                            "rooms", jsonEncode(GlobalVariables.rooms));
                        Navigator.of(context).pop();
                        Room.changeRoom(
                            GlobalVariables.currentRoom); //Redraw the room
                      },
                    )),
                Card(
                    child: FlatButton(
                      child: Text("Edit name"),
                      onPressed: () {
                        Navigator.of(context).pop();
                        showEditNameDialogBox();
                      },
                    )),
              ],
            )));
  }

  /// Makes the actual MQTT call
  void operateDimmer() {
    MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addByte(_pin); //pin number
    builder.addBool(val: false); //isPWM
    builder.addByte(val ~/ 4); //Dimmer value in range 0-255 to fit in a byte
    //TODO: Set topic
    GlobalVariables.localBroker.publish("test", builder);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Card(
            child: InkWell(
              child: ListView(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  Container(
                      padding: EdgeInsets.all(padding),
                      child: Center(
                          child: Text(
                        _name,
                        style: TextStyle(fontSize: 20),
                      ))),
                  Container(
                      padding:
                          EdgeInsets.fromLTRB(padding, 0, padding, padding * 2),
                      child: Slider(
                          value: val,
                          min: 0,
                          max: 1023,
                          onChanged: (double val) {
                            setState(() {
                              this.val = val;
                              print(val);
                            });
                            operateDimmer();
                          }))
                ],
              ),
            ),
            margin: EdgeInsets.all(_isRoom ? padding : 0)));
  }
}
