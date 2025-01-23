/* File contains some common methods which could be used anywhere in the code */

import 'package:clockwrk_login/app_logger.dart';
import 'package:clockwrk_login/app_constants.dart';
import 'package:clockwrk_login/db/preferences_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

/// Function to show a Snack bar in case of an error
void showErrorSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(message),
    duration: const Duration(minutes: 10),
    action: SnackBarAction(
      label: 'Ok',
      onPressed: () {
        Navigator.pop(context);
      },
    ),
  ));
}

/// Function to show a Snack bar in general cases
void showSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(message),
    duration: const Duration(seconds: 2),
  ));
}

void showToast(String message, {int timeInSec=2}) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT, // Or Toast.LENGTH_LONG
    gravity: ToastGravity.BOTTOM, // Or ToastGravity.CENTER, ToastGravity.TOP
    timeInSecForIosWeb: timeInSec,
    backgroundColor: Colors.black,
    textColor: Colors.white,
    fontSize: 16.0,
  );
}

Widget loadingWidget({Color ?color}) {
  return Container(
    color: color,
    child: const Center(
      child: CircularProgressIndicator(), // Full-page loading indicator
    ),
  );
}

Widget appNameWidget({double fontSize=22}) {
  return Text(
      AppConstants.appName,
      style: TextStyle(
        fontFamily: 'Montserrat',
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: Colors.blue
      ),
      textAlign: TextAlign.center
  );
}

// Function to handle sign-out
Future<void> signOut() async {
  try {
    await PreferencesHelper.deleteUserPreference();
    await FirebaseAuth.instance.signOut();
    showToast('Signed out successfully');
  } catch (e) {
    AppLogger.instance.e('Error signing out: $e');
    showToast('Error signing out: $e');
  }
}