import 'package:flutter/material.dart';
import 'package:iot_home/globals.dart';
import 'package:iot_home/room.dart';

class MyDrawer extends StatefulWidget {
  @override
  _MyDrawerState createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  /// Returns icon based on the room name
  /// Currently works for rooms containing the following names:
  /// Bed: Icons.local_hotel
  /// Hall/Living/Drawing: Icons.tv
  /// Dining: Icons.local_dining
  /// Kitchen: Icons.kitchen
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
        padding: EdgeInsets.all(0),
        decoration: BoxDecoration(
          color: Colors.blue,
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            child: IconButton(
              icon: Icon(
                Icons.edit,
                color: Colors.white,
              ),
              onPressed: () {
//                Navigator.of(context).pop();
                editHostName();
              },
            ),
            alignment: Alignment.bottomRight,
          ),
          Row(children: [
            Icon(Icons.person, size: 80, color: Colors.white),
            Expanded(
                child: Center(
                    child: Text(
              (GlobalVariables.prefs.getString("deviceName") == null
                  ? "Null"
                  : GlobalVariables.prefs.getString("deviceName")),
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ))),
          ])
        ]));
    widgets.add(drawerHeader);

    // Add rooms
    var rooms = GlobalVariables.rooms.keys;
    for (String room in rooms) {
      var icon = getIcon(GlobalVariables.rooms[room]["name"]);
      var listTile = ListTile(
        title: Text(GlobalVariables.rooms[room]["name"]),
        leading: Icon(icon),
        trailing: IconButton(
          icon: Icon(Icons.edit),
          onPressed: () {
            Navigator.of(context).pop();
            EditRoomNameDialog.show(context, room);
          },
        ),
        onTap: () {
          Room.changeRoom(room);
          Navigator.pop(context);
        },
      );
      widgets.add(listTile);
    }

    // Add "add Room" option
    var discoverRoomsButton = ListTile(
      title: Text("Find New Rooms"),
      leading: Icon(Icons.refresh),
      onTap: () {
        Navigator.of(context).pop();
        discoverRooms(context);
      },
    );
    widgets.add(discoverRoomsButton);
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
