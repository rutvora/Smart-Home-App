import 'package:flutter/material.dart';

import 'configurePage.dart';
import 'drawer.dart';
import 'globalVariables.dart';
import 'room.dart';

class Dashboard extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int index = 0;

  Widget _getPageToDisplay() {
    switch (index) {
      case 0:
        return Room();
      case 1:
        return Configure();
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      switch (index) {
        case 0:
          this.index = 0;
          return;
        case 1:
          this.index = 1;
          GlobalVariables.currentRoom = null;
          return;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Smart Home'),
      ),
      body: _getPageToDisplay(),
      drawer: MyDrawer(),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text('Home'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            title: Text('Configure'),
          )
        ],
        onTap: _onItemTapped,
      ),
    );
  }
}
