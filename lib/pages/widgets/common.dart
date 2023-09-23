/* File contains some common methods which could be used anywhere in the code */

import 'package:flutter/material.dart';

void showErrorSnackbar(BuildContext context,String message) {
  // Function to show a Snack bar in case of an error
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
