import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text("Clean Country"), backgroundColor: Colors.green, foregroundColor: Colors.white),
        body: const Center(child: Text("✅ Clean Country Works!", style: TextStyle(fontSize: 24))),
      ),
    );
  }
}
