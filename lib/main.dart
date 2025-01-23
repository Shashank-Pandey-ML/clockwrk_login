/* Main file of the ClockWrk Login code */

import 'dart:ui';

import 'package:clockwrk_login/app_constants.dart';
import 'package:clockwrk_login/locator.dart';
import 'package:clockwrk_login/pages/admin/admin_view.dart';
import 'package:clockwrk_login/pages/admin/attendance.dart';
import 'package:clockwrk_login/pages/admin/attendance_view.dart';
import 'package:clockwrk_login/pages/employee/employee_view.dart';
import 'package:clockwrk_login/pages/sign_in.dart';
import 'package:clockwrk_login/pages/sign_up.dart';
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

  final Future<FirebaseApp> _fbApp = Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: ThemeData(
        // This is the theme of your application.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, background: Colors.white),
        popupMenuTheme: const PopupMenuThemeData(
          color: Colors.white, // Set the default background color for popup menus
        ),
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
          } else if (snapshot.hasData) {
            return const HomePage();
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
      routes: {
        '/home': (context) => const HomePage(),
        '/home/signin': (context) => const SignIn(),
        '/home/signup': (context) => const SignUp(),
      },
    );
  }
}
