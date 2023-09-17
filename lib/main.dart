import 'package:flutter/material.dart';
import 'package:clockwrk_login/pages/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  final String title = "Clockwrk Login";

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      theme: ThemeData(
        // This is the theme of your application.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, background: Colors.blue[50]),
        useMaterial3: true
      ),
      home: HomePage(title: title),
    );
  }
}
