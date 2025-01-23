
import 'package:clockwrk_login/app_logger.dart';
import 'package:clockwrk_login/app_constants.dart';
import 'package:clockwrk_login/pages/utils.dart';
import 'package:clockwrk_login/pages/widgets/app_button.dart';
import 'package:clockwrk_login/pages/widgets/common.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../db/db_helper.dart';
import '../db/preferences_helper.dart';
import '../locator.dart';
import '../models/user.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<StatefulWidget> createState() => SignInState();
}

class SignInState extends State<SignIn> {
  final _formKey = GlobalKey<FormState>();

  final DbHelper _dbHelper = locator<DbHelper>();

  final TextEditingController _emailTextEditingController = TextEditingController(text: '');
  final TextEditingController _passwordTextEditingController = TextEditingController(text: '');

  bool _isSigningIn = false; // State to track loading

  Future<void> _signIn() async {
    setState(() {
      _isSigningIn = true; // Show loading indicator
    });

    if (_formKey.currentState?.validate() ?? false) {
      try {
        final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailTextEditingController.text,
          password: _passwordTextEditingController.text,
        );

        final user = credential.user;

        if (user != null) {
          AppUser? appUser = await _dbHelper.getUserByDocId(user.uid);
          if (appUser != null) {
            await _dbHelper.setUserByDocId(user.uid, appUser);

            await PreferencesHelper.saveUserPreference(appUser);
          }

          showToast("User '${user.email}' signed in.");
        }
      } on FirebaseAuthException catch (e) {
        String? message;
        if (e.code == 'user-not-found') {
          message = 'No user found for that email. Please Sign Up.';
        } else if (e.code == 'wrong-password') {
          message = 'Wrong password provided for that user.';
        } else if (e.code == 'invalid-credential') {
          message = 'Invalid credential provided for the login.';
        } else {
          message = e.message;
        }
        AppLogger.instance.d(e.code);
        AppLogger.instance.d(message);
        if (mounted) {
          showSnackbar(context, message ?? 'Unknown error when Signing In');
        }
      } catch (e) {
        AppLogger.instance.e('$e');
        if (mounted) {
          showSnackbar(context, "An unexpected error occurred: '$e'");
        }
      } finally {
        setState(() {
          _isSigningIn = false; // Hide loading indicator
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    AppLogger.instance.d("Showing sign in page");
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Image(image: AssetImage(AppConstants.logoPath),
                    width: 200,
                    height: 200,),
                  appNameWidget(),
                  Container(
                    width: MediaQuery
                        .of(context)
                        .size
                        .width * 0.8,
                    child: Form(
                      key: _formKey,
                      child: Column(
                          children: [
                            TextFormField(
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              controller: _emailTextEditingController,
                              decoration: const InputDecoration(labelText: 'Email'),
                              validator: validateEmail,
                            ),
                            const SizedBox(height: 20),
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
                            const SizedBox(height: 20),
                            AppButton(
                              title: 'Sign In',
                              onClick: () {
                                _signIn();
                              },
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.blue,
                              icon: Icons.login,
                            ),
                            const SizedBox(height: 20),
                            TextButton(
                              onPressed: () {
                                // TODO: Implement forgot password page
                              },
                              child: const Text('Forgot Password?'),
                            ),
                            // const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                const Text(
                                  "Don't have an account? ",
                                  style: TextStyle(fontSize: 16),
                                ),
                                TextButton(
                                  onPressed: () {
                                    // Navigate to the sign-up page or perform another action
                                    Navigator.pushNamed(context, '/home/signup');
                                  },
                                  child: const Text(
                                    'Sign up',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue, // Customize the color if needed
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ]
                      ),
                    )
                  )
                ],
              ),
            ),
          ),
          if (_isSigningIn)
            loadingWidget(color: Colors.black54),
        ],
      ),
    );
  }

}