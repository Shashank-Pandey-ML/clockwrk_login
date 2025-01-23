/* File contains widget to handle Sign-Up of admin users.
ONLY FOR ADMIN USERS */

import 'package:clockwrk_login/app_logger.dart';
import 'package:clockwrk_login/db/preferences_helper.dart';
import 'package:clockwrk_login/models/user.dart';
import 'package:clockwrk_login/pages/utils.dart';
import 'package:clockwrk_login/pages/widgets/app_button.dart';
import 'package:clockwrk_login/pages/widgets/common.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../db/db_helper.dart';
import '../locator.dart';
import '../models/admin.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<StatefulWidget> createState() => SignUpState();

}

class SignUpState extends State<SignUp> {

  final _formKey = GlobalKey<FormState>();

  final DbHelper _dbHelper = locator<DbHelper>();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // final String _selectedRole = 'Admin';
  // final List<String> _roles = ['Admin', 'Employee'];

  final TextEditingController _nameTextEditingController = TextEditingController(text: '');
  final TextEditingController _mobileNoTextEditingController = TextEditingController(text: '');
  final TextEditingController _emailTextEditingController = TextEditingController(text: '');
  final TextEditingController _passwordTextEditingController = TextEditingController(text: '');

  bool _isSigningUp = false; // State to track loading

  Future<void> _signUp() async {
    setState(() {
      _isSigningUp = true; // Show loading indicator
    });

    if (_formKey.currentState?.validate() ?? false) {
      try {
        // Signing Up to Firebase using Email and Password
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailTextEditingController.text,
          password: _passwordTextEditingController.text,
        );
        // Get the Firebase User object
        final user = userCredential.user;

        if (user != null) {
          AppLogger.instance.i("Signed up user for email '${user.email}'");

          // Create Admin document in the Firestore.
          Admin admin = await _dbHelper.createAdmin(Admin(
            name: _nameTextEditingController.text,
            mobileNo: _mobileNoTextEditingController.text,
            email: _emailTextEditingController.text,
            userId: user.uid,
          ));
          AppLogger.instance.i("Created admin doc for user '${user.email}'");

          // We first create a AppUser object, which will later be added to
          // users collection in Firestore
          AppUser appUser = AppUser(
              id: user.uid,
              adminId: admin.id,
          );
          await _dbHelper.setUserByDocId(user.uid, appUser);
          AppLogger.instance.i("Created user doc for user '${user.email}'");

          // TODO: Add support for signing up Employee users

          // Saving this appUser object into the preferences, so that it can
          // be reused anywhere else in the code.
          await PreferencesHelper.saveUserPreference(appUser);
          AppLogger.instance.i("Added app user  in preferences for email '${user.email}'");

          if (mounted) {
            showToast("User '${user.email}' signed up.");
            Navigator.pop(context);
          }
        }
      } on FirebaseAuthException catch (e) {
        String message;
        if (e.code == 'email-already-in-use') {
          message = 'The account already exists for that email.';
        } else if (e.code == 'weak-password') {
          message = 'The password provided is too weak. ${e.message}';
        } else {
          message = 'An error occurred: ${e.message}';
        }
        AppLogger.instance.d(e.code);
        AppLogger.instance.d(e.message);
        if (mounted) {
          showSnackbar(context, message);
        }
      } catch (e) {
        AppLogger.instance.e('$e');
        if (mounted) {
          showSnackbar(context, "An unexpected error occurred: $e");
        }
      } finally {
        setState(() {
          _isSigningUp = false; // Hide loading indicator
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    AppLogger.instance.d("Showing sign up page");
    FocusNode focusNode = FocusNode();

    return Scaffold(
        appBar: AppBar(
          title: const Text('Sign Up'),
          centerTitle: true,
          backgroundColor: Colors.transparent,
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    // Logo
                    Image.asset(
                      'assets/home-logo1.png', // Path to your logo
                      height: 100,
                    ),
                    const SizedBox(height: 16),
                    appNameWidget(fontSize: 18),
                    const SizedBox(height: 32),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          TextFormField(
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            controller: _nameTextEditingController,
                            decoration: const InputDecoration(labelText: 'Name'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your name';
                              }
                              return null;
                            },
                          ),
                          IntlPhoneField(
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            controller: _mobileNoTextEditingController,
                            focusNode: focusNode,
                            decoration: const InputDecoration(
                              labelText: 'Mobile Number',
                            ),
                            initialCountryCode: "IN",
                            languageCode: "en"
                          ),
                          TextFormField(
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            controller: _emailTextEditingController,
                            decoration: const InputDecoration(labelText: 'Email'),
                            validator: validateEmail,
                          ),
                          // DropdownButtonFormField<String>(
                          //   decoration: const InputDecoration(labelText: 'Select Role'),
                          //   value: _selectedRole,
                          //   onChanged: (String? newValue) {
                          //     setState(() {
                          //       _selectedRole = newValue;
                          //     });
                          //   },
                          //   items: _roles.map<DropdownMenuItem<String>>((String role) {
                          //     return DropdownMenuItem<String>(
                          //       value: role,
                          //       child: Text(role),
                          //     );
                          //   }).toList(),
                          //   validator: (value) {
                          //     if (value == null) {
                          //       return 'Please select a role';
                          //     }
                          //     return null;
                          //   },
                          // ),
                          TextFormField(
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            controller: _passwordTextEditingController,
                            decoration: const InputDecoration(labelText: 'Password'),
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              return null;
                            },
                          ),
                          TextFormField(
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            decoration: const InputDecoration(labelText: 'Confirm Password'),
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password again';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          AppButton(
                            title: 'Sign Up',
                            onClick: _signUp,
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.blue,
                            icon: Icons.person_add,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                )
              ),
            ),
            if (_isSigningUp)
              loadingWidget(color: Colors.black54)
          ],
        ),
        // bottomNavigationBar: BottomAppBar(
        //   elevation: 0, // Remove shadow
        //   color: Colors.transparent,
        //   child: Padding(
        //     padding: const EdgeInsets.all(2.0),
        //     child: Row(
        //       mainAxisAlignment: MainAxisAlignment.center,
        //       children: <Widget>[
        //         Expanded(
        //           child:TextButton(
        //             onPressed: () {
        //               // TODO: Navigate to terms of service page
        //             },
        //             child: const Text(
        //               'Terms of Service',
        //               textAlign: TextAlign.center,
        //               style: TextStyle(
        //                 fontSize: 12,
        //                 color: Colors.blue, // Customize the color if needed
        //               ),
        //             ),
        //           )
        //         ),
        //         const SizedBox(width: 2),
        //         Expanded(
        //           child:TextButton(
        //             onPressed: () {
        //               // TODO: Navigate to privacy policy page
        //             },
        //             child: const Text(
        //               'Privacy Policy',
        //               textAlign: TextAlign.center,
        //               style: TextStyle(
        //                 fontSize: 12,
        //                 color: Colors.blue, // Customize the color if needed
        //               ),
        //             ),
        //           )
        //         ),
        //         const SizedBox(width: 2),
        //         Expanded(
        //           child:TextButton(
        //             onPressed: () {
        //               // TODO: Navigate to contact us page
        //             },
        //             child: const Text(
        //               'Contact Us',
        //               textAlign: TextAlign.center,
        //               style: TextStyle(
        //                 fontSize: 12,
        //                 color: Colors.blue, // Customize the color if needed
        //               ),
        //             ),
        //           )
        //         ),
        //       ],
        //     ),
        //   ),
        // ),
    );
  }

  @override
  void dispose() {
    _nameTextEditingController.dispose();
    _emailTextEditingController.dispose();
    _mobileNoTextEditingController.dispose();
    _passwordTextEditingController.dispose();
    super.dispose();
  }
}