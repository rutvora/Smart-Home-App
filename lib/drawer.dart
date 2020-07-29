import 'package:flutter/material.dart';
import 'package:iot_home/globalVariables.dart';
import 'package:iot_home/room.dart';

class MyDrawer extends StatefulWidget {
  @override
  _MyDrawerState createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  IconData getIcon(String room) {
    if (room.toLowerCase().contains("bed"))
      return Icons.local_hotel;
    else if (room.toLowerCase().contains("hall") ||
        room.toLowerCase().contains("living") ||
        room.toLowerCase().contains("drawing"))
      return Icons.tv;
    else if (room.toLowerCase().contains("dining"))
      return Icons.local_dining;
    else if (room.toLowerCase().contains("kitchen"))
      return Icons.kitchen;
    else
      return Icons.arrow_forward_ios;
  }

  List<Widget> getChildren() {
    List<Widget> widgets = List<Widget>();

    //Drawer Header
    var drawerHeader = DrawerHeader(
      decoration: BoxDecoration(
        color: Colors.blue,
      ),
      child: Text(
        (GlobalVariables.prefs.getString("deviceName") == null
            ? "Null"
            : "DeviceName"),
        style: TextStyle(
          color: Colors.white,
          fontSize: 24,
        ),
      ),
    );
    widgets.add(drawerHeader);

    // Add rooms
    var rooms = GlobalVariables.rooms.keys;
    for (String room in rooms) {
      var icon = getIcon(room);
      var listTile = ListTile(
        title: Text(room),
        leading: Icon(icon),
        onTap: () {
          Room.changeRoom(room);
          Navigator.pop(context);
        },
      );
      widgets.add(listTile);
    }

    // Add "add Room" option
    var addRoom = ListTile(
      title: Text("Add Room"),
      leading: Icon(Icons.add),
      onTap: () {
        Navigator.of(context).pop();
        AddRoomDialog.show(context);
      },
    );
    widgets.add(addRoom);
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    while (GlobalVariables.prefs == null) {}
    return Drawer(
        child: ListView(
      padding: EdgeInsets.zero,
      children: getChildren(),
    ));
  }
}
