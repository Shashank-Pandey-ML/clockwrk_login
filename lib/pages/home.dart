/* File contains widget to show the home page
* The home page contains 2 buttons Check-In and Check-Out. */

import 'package:clockwrk_login/app_logger.dart';
import 'package:clockwrk_login/db/preferences_helper.dart';
import 'package:clockwrk_login/models/admin.dart';
import 'package:clockwrk_login/models/employee.dart';
import 'package:clockwrk_login/models/user.dart';
import 'package:clockwrk_login/pages/admin/admin_view.dart';
import 'package:clockwrk_login/pages/sign_in.dart';
import 'package:clockwrk_login/db/db_helper.dart';
import 'package:clockwrk_login/locator.dart';
import 'package:clockwrk_login/pages/widgets/common.dart';
import 'package:clockwrk_login/provider_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loadingWidget();
        } else if (snapshot.hasData) {
          AppLogger.instance.d("User auth state changed");
          User? user = snapshot.data;
          if (user != null) {
            AppLogger.instance.i("'${user.email}' user is authenticated");
            return RoleBasedNavigation(
                user: user,
            );
          } else {
            AppLogger.instance.d("No user authenticated. Moving to SignIn page");
            return const SignIn();
          }
        } else if (snapshot.hasError) {
          // Show an error message
          AppLogger.instance.d("Error: ${snapshot.error}");
          showToast('Error: ${snapshot.error}');
          return Container();
        } else {
          return const SignIn();
        }
      },
    );
  }
}

class RoleBasedNavigation extends StatefulWidget {
  final User? user;

  const RoleBasedNavigation({super.key, required this.user});

  @override
  State<StatefulWidget> createState() => RoleBasedNavigationState();
}

class RoleBasedNavigationState extends State<RoleBasedNavigation> {
  final DbHelper _dbHelper = locator<DbHelper>();

  final AdminDeviceModeModel _adminDeviceModeNotifier = AdminDeviceModeModel();

  bool _isInitializing = false;

  @override
  void initState() {
    super.initState();
    _isInitialized();
  }

  void _isInitialized() async {
    setState(() {
      _isInitializing = true;
    });

    int attempts = 0;
    const int maxAttempts = 10;
    const Duration delay = Duration(seconds: 1);

    while (attempts < maxAttempts) {
      try {
        AppUser? appUser = await PreferencesHelper.getUserPreference();
        if (appUser != null) {
          break;
        }
      } catch (e) {
        AppLogger.instance.d('Attempt ${attempts + 1} failed: $e');
      }

      attempts++;
      if (attempts < maxAttempts) {
        await Future.delayed(delay); // Wait before retrying
      }
    }

    setState(() {
      _isInitializing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      AppLogger.instance.d("Role based navigation is being initialized");
      return loadingWidget();
    }
    return ListenableBuilder(
      listenable: _adminDeviceModeNotifier,
      builder: (BuildContext context, Widget? child) {
        return AdminView(
            adminDeviceModeNotifier: _adminDeviceModeNotifier
        );
      },
    );
    // return FutureBuilder<Admin?>(
    //   future: _dbHelper.getAdminByUserId(widget.user!.uid),
    //   builder: (BuildContext context, AsyncSnapshot<Admin?> snapshot) {
    //     if (snapshot.connectionState == ConnectionState.waiting) {
    //       AppLogger.instance.d("Waiting to get admin data from db");
    //       return loadingWidget();
    //     } else if (snapshot.hasData) {
    //       Admin? admin = snapshot.data;
    //       if (admin != null) {
    //         AppLogger.instance.d("Got '${admin.name}' admin data");
    //         return ListenableBuilder(
    //           listenable: widget.adminDeviceModeNotifier,
    //           builder: (BuildContext context, Widget? child) {
    //             return AdminView(
    //                 isAttendanceMode: widget.adminDeviceModeNotifier.isAttendanceMode
    //             );
    //           },
    //         );
    //       } else {
    //         // Show an error message
    //         showToast("Admin returned as null");
    //         return Container();
    //       }
    //     } else if (snapshot.hasError) {
    //       // Show an error message
    //       AppLogger.instance.e('Error: ${snapshot.error}');
    //       showToast('Error: ${snapshot.error}');
    //       return Container();
    //     } else {
    //       // Sometimes due to absence of proper synchronization, this code gets
    //       // executed.
    //       // This happens when SignUp/SignIn is done executing the
    //       // firebase_auth method to signIn or signUp, but the followup operations
    //       // like creating Admin document takes time, but the StreamBuilder
    //       // already gets the event of signIn/signUP, so it starts building
    //       // RoleBasedNavigation widget. Keep in mind that admin record creation
    //       // is still not done, so here getAdminByUserId will return null and
    //       // this part of the code gets executed.
    //       showToast("No data when fetching Admin");
    //       WidgetsBinding.instance.addPostFrameCallback((_) {
    //         showToast('Error: ${snapshot.error}');
    //         // Navigate to the home page
    //         Navigator.pushNamedAndRemoveUntil(context, '/home', (Route<dynamic> route) => false);
    //       });
    //       // Return a placeholder widget while navigating
    //       return Container();
    //     }
    //   },
    // );
  }

}