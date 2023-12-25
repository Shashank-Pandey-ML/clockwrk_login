/* Main file of the ClockWrk Login code */

import 'package:clockwrk_login/locator.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:clockwrk_login/pages/home.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupServices();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final Future<FirebaseApp> _fbApp = Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

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
      home: FutureBuilder(
        future: _fbApp,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return SnackBar(
              content: Text('You have an error! ${snapshot.error.toString()}'),
              duration: const Duration(minutes: 10),
              action: SnackBarAction(
                label: 'Ok',
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            );
            return const Text('Something went wrong');
          } else if (snapshot.hasData) {
            return HomePage(title: title);
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
