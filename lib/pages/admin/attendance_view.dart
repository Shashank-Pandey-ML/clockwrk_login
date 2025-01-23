/* File contains widget to show the attendance page
* The attendance page contains 2 buttons to Check-In and Check-Out employees. */

import 'package:clockwrk_login/app_constants.dart';
import 'package:clockwrk_login/pages/admin/check_in.dart';
import 'package:clockwrk_login/pages/admin/check_out.dart';
import 'package:clockwrk_login/pages/widgets/app_button.dart';
import 'package:clockwrk_login/provider_helper.dart';
import 'package:flutter/material.dart';

import '../../db/preferences_helper.dart';


class AttendanceView extends StatelessWidget {
  final String heading = "FACE RECOGNITION AUTHENTICATION";
  final String subText = "Application to authenticate employees using facial recognition";

  const AttendanceView({super.key, required this.adminDeviceModeNotifier});

  final AdminDeviceModeModel adminDeviceModeNotifier;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: <Widget>[
          PopupMenuButton(
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'AdminView',
                child: Text('Admin View',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            position: PopupMenuPosition.under,
            onSelected: (String value) {
              if (value == "AdminView") {
                adminDeviceModeNotifier.toggleAdminDeviceMode();
              }
            },
          )
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Image(image: AssetImage(AppConstants.logoPath),
                width: 200,
                height: 200,),
              Container(
                width: MediaQuery
                    .of(context)
                    .size
                    .width * 0.8,
                child: Column(
                  children: [
                    Text(
                        heading,
                        style: const TextStyle(
                            fontSize: 25, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.left
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                        subText,
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.left
                    ),
                  ],
                ),
              ),
              Container(
                  width: MediaQuery
                      .of(context)
                      .size
                      .width * 0.8,
                  child: Column(
                      children: [
                        AppButton(
                          title: 'Check In',
                          onClick: () {
                            Navigator.push(context, MaterialPageRoute(
                                builder: (context) => const CheckIn()));
                          },
                          icon: Icons.login,
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.blue,
                        ),
                        const SizedBox(height: 20),
                        AppButton(
                          title: 'Check Out',
                          onClick: () {
                            Navigator.push(context, MaterialPageRoute(
                                builder: (context) => const CheckOut()));
                          },
                          icon: Icons.logout,
                        ),
                      ]
                  )
              )
            ],
          ),
        ),
      ),
    );
  }
}