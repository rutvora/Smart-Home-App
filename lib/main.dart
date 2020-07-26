import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to Flutter',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Your Smart Home'),
        ),
        body: Center(
//          child: Text('Hello World'),
          child: Text("Hello World!"),
        ),
      ),
    );
  }
}
