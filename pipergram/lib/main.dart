import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pipergram/pages/home.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Firestore.instance.settings(timestampsInSnapshotsEnabled: true).then((_) {
  //   print("Timestamps enabled in snapshots\n");
  // }, onError: (_) {
  //   print("Error enabling timestamps in snapshots\n");
  // });
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PiperGram',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        accentColor: Colors.teal,
      ),
      home: Home(),
    );
  }
}

//"client_id": "377544078767-8qom432bjbeq21lirumoduqaqp9als0v.apps.googleusercontent.com",
//"current_key": "AIzaSyBs06-7tGuDWIvg3Y557WM7T8c1u1uCQVI"
