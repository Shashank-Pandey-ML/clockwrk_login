/* File contains widget to handle Check-Out.
* This page should show a camera preview with capture and back button. */

import 'dart:math';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:clockwrk_login/locator.dart';
import 'package:clockwrk_login/pages/widgets/camera_button.dart';
import 'package:clockwrk_login/pages/widgets/camera_header.dart';
import 'package:clockwrk_login/pages/widgets/camera_preview.dart';
import 'package:clockwrk_login/pages/widgets/common.dart';
import 'package:clockwrk_login/services/camera.dart';
import 'package:clockwrk_login/services/face_detector.dart';
import 'package:flutter/material.dart';

class CheckOut extends StatefulWidget {
  const CheckOut({super.key});

  @override
  State<CheckOut> createState() => CheckOutState();
}

class CheckOutState extends State<CheckOut> {
  final CameraService _cameraService = locator<CameraService>();
  final FaceDetectorService _faceDetectorService = locator<FaceDetectorService>();

  late XFile? _image;

  bool _isInitializing = false;
  bool _pictureTaken = false;
  bool _isBottomSheetVisible = false;

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
            "Check Out",
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
    super.dispose();
  }

  void _initServices() async {
    // A function to initialize the global services.
    // We cant include the content of this function inside initState() cause,
    // initState() cannot be async, and we need an async function to wait
    // for _cameraService.initCamera().

    // Set _isInitializing to false, only when this widget is mounted in
    // widget tree and camera is initialized successfully
    setState(() => _isInitializing = true);
    try {
      await _cameraService.initCamera();
      await _faceDetectorService.initFaceDetector();
      if (mounted) setState(() => _isInitializing = false);
    } on Exception catch (e) {
      // Show a Snackbar to the user with the error message.
      if (mounted) showErrorSnackbar(context, e.toString());
    }
  }

  Widget _getBodyWidget() {
    // Function to return the body Widget based on some flag values
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
        PersistentBottomSheetController bottomSheetController =
        Scaffold.of(context)
            .showBottomSheet((context) => _bottomSheetWidget(context));
        bottomSheetController.closed.whenComplete(() => _reload());
      }
    } else {
      if (mounted) {
        showSnackbar(context, "No face found");
        await Future.delayed(const Duration(seconds: 2));
        _reload();
      }
    }
  }

  /// Function to returns a bottom sheet widget during check-in
  Widget _bottomSheetWidget(BuildContext context) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(20),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("User not found 😞", style: TextStyle(fontSize: 20),)
        ],
      ),
    );
  }

  /// Function to reset the flags and initialize the services again.
  void _reload() {
    setState(() {
      _pictureTaken = false;
      _isBottomSheetVisible = false;
    });
    _initServices();
  }
}