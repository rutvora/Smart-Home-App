import 'dart:io';

import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';

import 'configurePage.dart';
import 'drawer.dart';
import 'globals.dart';
import 'loadingAnimations.dart';
import 'network.dart';
import 'room.dart';

class Dashboard extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int navigationBarSelectedIndex = 0;
  ProgressDialog progressDialog;

  /// Connects to broker and sets callback for connection change status
  void initialize() async {
    progressDialog = pleaseWait(context, "Connecting to broker...");
    InternetAddress broker = await resolveMDNS('ideapad-510-15ISK');
    GlobalVariables.localBroker = MQTT(broker, (connected) {
      print("Status changed " + connected.toString());
      if (context == null) {
        print("Build context is null");
        return;
      }
      if (!connected) {
        print("is not connected");
        progressDialog.show();
      } else if (progressDialog != null) {
        print("is connected and progressDialog not null");
        progressDialog.hide();
      } else {
        print("Progress dialog null");
      }
    });
    GlobalVariables.localBroker.connectToBroker();
  }

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Widget _getPageToDisplay() {
    switch (navigationBarSelectedIndex) {
      case 0:
        return Room();
      case 1:
        return Configure();
      default:
        return null;
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      switch (index) {
        case 0:
          this.navigationBarSelectedIndex = 0;
          return;
        case 1:
          this.navigationBarSelectedIndex = 1;
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
        currentIndex: navigationBarSelectedIndex,
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
