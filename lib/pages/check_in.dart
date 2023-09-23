/* File contains widget to handle Check-In.
* This page should show a camera preview with capture and back button. */

import 'package:clockwrk_login/locator.dart';
import 'package:clockwrk_login/pages/widgets/camera_action_button.dart';
import 'package:clockwrk_login/pages/widgets/camera_header.dart';
import 'package:clockwrk_login/pages/widgets/camera_preview.dart';
import 'package:clockwrk_login/pages/widgets/common.dart';
import 'package:clockwrk_login/services/camera.dart';
import 'package:flutter/material.dart';

class CheckIn extends StatefulWidget {
  const CheckIn({super.key});

  @override
  State<CheckIn> createState() => CheckInState();
}

class CheckInState extends State<CheckIn> {
  final CameraService _cameraService = locator<CameraService>();

  bool _isInitializing = false;

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
      floatingActionButton: const CameraActionButton(),
    );
  }

  @override
  void dispose() {
    _cameraService.dispose();
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
      if (mounted) setState(() => _isInitializing = false);
    } on Exception catch (e) {
      // If any initialization fails then show a Snackbar to the user with
      // the error message.
      if (mounted) showErrorSnackbar(context, e.toString());
    }
  }

  Widget _getBodyWidget() {
    // Function to return the body Widget based on some flag values
    if (_isInitializing) return const Center(child: CircularProgressIndicator());
    return CameraPreviewWidget(_cameraService.cameraController!);
  }

}