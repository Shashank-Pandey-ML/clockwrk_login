/* File contains some common methods which could be used anywhere in the code */

import 'package:flutter/material.dart';

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
