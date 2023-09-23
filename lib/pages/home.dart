/* File contains widget to show the home page
* The home page contains 2 buttons Check-In and Check-Out. */

import 'package:clockwrk_login/pages/check_in.dart';
import 'package:clockwrk_login/pages/check_out.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  final String title;
  final String heading = "FACE RECOGNITION AUTHENTICATION";
  final String subText = "Demo application to authenticate users using facial recognition";

  const HomePage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Image(image: AssetImage('assets/home-logo1.png'), width: 200, height: 200,),
              Container(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Column(
                  children: [
                    Text(
                        heading,
                        style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
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
                width: MediaQuery.of(context).size.width * 0.8,
                child: Column(
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const CheckIn()));
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          textStyle: const TextStyle(fontSize: 20),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Check In'),
                            SizedBox(width: 10),
                            Icon(Icons.login),
                          ],
                        )
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const CheckOut()));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          textStyle: const TextStyle(fontSize: 20),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Check Out'),
                            SizedBox(width: 10),
                            Icon(Icons.logout),
                          ],
                        )
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