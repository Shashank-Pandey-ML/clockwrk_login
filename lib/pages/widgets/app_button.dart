/* File contains a widget to show a Button. */

import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  const AppButton({super.key,
    required this.title,
    required this.onClick,
    this.backgroundColor = Colors.white,
    this.foregroundColor = Colors.blue,
    this.icon,
  });

  final String title;
  final Function() onClick;
  final Color backgroundColor, foregroundColor;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: onClick,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          textStyle: const TextStyle(fontSize: 20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title),
            const SizedBox(width: 10),
            icon != null? Icon(icon): Container(),
          ],
        )
    );
  }

}