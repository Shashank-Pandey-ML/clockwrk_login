/* File contains widget to handle Check-In.
* This page should show a camera preview with capture and back button.
* There are multiple scenarios to consider when the picture is taken:
* 1. A face is detected in the photo:
*     a. Face is registered: Show the user's name and ask whether to continue
*        check-in.
*     b. Face is not registered: Ask whether its a new user. If yes, then ask
*        for relevant user details and add it to the DB.
* 2. No face detected: Notify the user that there is no face detected. */

import 'dart:math';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:clockwrk_login/db/db_helper.dart';
import 'package:clockwrk_login/locator.dart';
import 'package:clockwrk_login/pages/widgets/app_button.dart';
import 'package:clockwrk_login/pages/widgets/app_text_field.dart';
import 'package:clockwrk_login/pages/widgets/camera_button.dart';
import 'package:clockwrk_login/pages/widgets/camera_header.dart';
import 'package:clockwrk_login/pages/widgets/camera_preview.dart';
import 'package:clockwrk_login/pages/widgets/common.dart';
import 'package:clockwrk_login/services/camera.dart';
import 'package:clockwrk_login/services/face_detector.dart';
import 'package:clockwrk_login/services/face_recognition.dart';
import 'package:flutter/material.dart';

import '../models/user.dart';

class CheckIn extends StatefulWidget {
  const CheckIn({super.key});

  @override
  State<CheckIn> createState() => CheckInState();
}

class CheckInState extends State<CheckIn> {
  final CameraService _cameraService = locator<CameraService>();
  final FaceDetectorService _faceDetectorService = locator<FaceDetectorService>();
  final FaceRecognitionService _faceRecognitionService = locator<FaceRecognitionService>();
  final DbHelper _dbHelper = locator<DbHelper>();

  late XFile? _image;

  bool _isInitializing = false;
  bool _pictureTaken = false;
  bool _isBottomSheetVisible = false;
  bool _newUser = false;

  final TextEditingController _userTextEditingController = TextEditingController(text: '');
  final TextEditingController _phoneTextEditingController = TextEditingController(text: '');
  final TextEditingController _emailTextEditingController = TextEditingController(text: '');

  User? predictedUser;

  @override
  void initState() {
    super.initState();
    _initServices();
  }

  @override
  Widget build(BuildContext context) {
    Widget body = _getBodyWidget();

    return Scaffold(
      body: Stack(
        children: [
          body,
          CameraHeader(
            "Check In",
            onBackPressed: () {
              Navigator.of(context).pop();
            },
          )
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: !_isBottomSheetVisible
          ? CameraActionButton(takePicture: takePicture)
          : Container(),
    );
  }

  @override
  void dispose() {
    _cameraService.dispose();
    _faceDetectorService.dispose();
    _faceRecognitionService.dispose();
    super.dispose();
  }

  /// A function to initialize the global services (camera service,
  /// face detection service and face recognition service). Called inside [initState].
  void _initServices() async {
    // We cant include the content of this function inside initState() cause,
    // initState() cannot be async, and we need an async function to wait
    // for _cameraService.initCamera().
    //
    // Set _isInitializing to false, only when this widget is mounted in
    // widget tree and camera is initialized successfully
    setState(() => _isInitializing = true);
    try {
      await _cameraService.initCamera();
      await _faceDetectorService.initFaceDetector();
      await _faceRecognitionService.initFaceRecognition();
      if (mounted) setState(() => _isInitializing = false);
    } on Exception catch (e) {
      // If any initialization fails then show a Snackbar to the user with
      // the error message.
      if (mounted) showErrorSnackbar(context, e.toString());
    }
  }

  /// Function to return the body widget based on some flag values
  Widget _getBodyWidget() {
    if (_isInitializing) return const Center(child: CircularProgressIndicator());
    if (_pictureTaken) {
      return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.rotationY(pi),
          child: FittedBox(
            fit: BoxFit.cover,
            child: Image.file(File(_image!.path)),
          ),
        )
      );
    }
    return CameraPreviewWidget(_cameraService.cameraController!);
  }

  /// Function to take the picture and detect the faces in the same.
  Future<void> takePicture() async {
    _image = await _cameraService.takePicture();
    if (_image == null) return;

    setState(() {
      _pictureTaken = true;
      _isBottomSheetVisible = true;
    });

    await _faceDetectorService.detectFaceFromFileImage(_image!);
    if (_faceDetectorService.faceDetected) {
      if (mounted) {
        await _faceRecognitionService.setCurrentPrediction(_image!, _faceDetectorService.faces[0]);
        var user = await _faceRecognitionService.predictUser();
        if (user != null) {
          predictedUser = user;
        }
        _showBottomSheetWidget();
      }
    } else {
      if (mounted) {
        showSnackbar(context, "No face found");
        await Future.delayed(const Duration(seconds: 2));
        _reload();
      }
    }
  }

  /// Function to show the bottom sheet widget
  void _showBottomSheetWidget() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: _bottomSheetWidget,
    ).then((value) {
      _reload();
    });
  }

  /// Function to returns a bottom sheet widget during check-in
  Widget _bottomSheetWidget(BuildContext context, {int height = 200}) {
    return Wrap(
      children: <Widget> [
        predictedUser == null
          ? _userNotFoundWidget()
          : _userFoundWidget(),
      ]
    );
  }

  /// Function to return the widget when user is not found. In this case we
  /// ask the user whether he wants to register himself as a new user or not.
  /// If Yes, then we ask for relevant user details to be entered and add them
  /// to the DB.
  Widget _userNotFoundWidget() {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AnimatedContainer(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              duration: const Duration(milliseconds: 400),
              child: AnimatedCrossFade(
                duration: const Duration(milliseconds: 400),
                firstChild: Container(
                    height: 300,
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AppTextField(
                            labelText: 'Name',
                            controller: _userTextEditingController,
                          ),
                          AppTextField(
                            labelText: 'Phone Number',
                            controller: _phoneTextEditingController,
                            keyboardType: TextInputType.phone,
                          ),
                          AppTextField(
                            labelText: 'Email',
                            controller: _emailTextEditingController,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          AppButton(
                            title: 'Submit',
                            onClick: () {
                              _dbHelper.addUser(User(
                                  name: _userTextEditingController.text,
                                  mobileNo: _phoneTextEditingController.text,
                                  email: _emailTextEditingController.text,
                                  salaryPerHour: 10.00,
                                  modelData: _faceRecognitionService
                                      .predictedData
                              ));
                              showSnackbar(context, "User registered. Please check-in again.");
                              Navigator.popUntil(context, (route) => route.isFirst);
                            },
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.blue,
                            icon: Icons.person_add,
                          ),
                        ],
                      ),
                    )
                ),
                secondChild: Container(
                    height: 200,
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("User not found 😞",
                            style: TextStyle(fontSize: 20),),
                          const SizedBox(height: 20),
                          AppButton(
                            title: 'New Member?',
                            onClick: () {
                              setState(() {
                                _newUser = true;
                              });
                            },
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.blue,
                            icon: Icons.person_add,
                          ),
                        ],
                      ),
                    )
                ),
                crossFadeState: _newUser == true
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond
              ),
            );
        }
    );
  }

  Widget _userFoundWidget() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${"Welcome ${predictedUser!.name}"}.', style: const TextStyle(fontSize: 20),),
            const SizedBox(height: 20),
            AppButton(
              title: 'Continue',
              onClick: () {
                showSnackbar(context, "Checked in as ${predictedUser!.name} ");
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              foregroundColor: Colors.white,
              backgroundColor: Colors.blue,
            ),
          ],
        )
      )
    );
  }

  /// Function to reset the flags and initialize the services again.
  void _reload() {
    setState(() {
      _pictureTaken = false;
      _isBottomSheetVisible = false;
      _newUser = false;
      predictedUser = null;
    });
    _initServices();
  }

}