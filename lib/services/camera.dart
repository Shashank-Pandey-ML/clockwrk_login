/* File contains CameraService class which holds the important attributes and
* methods required for dealing with a camera.
* We call this class a service cause the object of this class will be reused
* everywhere. */

import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';

class CameraService {
  CameraController? _cameraController;
  CameraController? get cameraController => _cameraController;

  late CameraDescription _frontCamera;
  CameraDescription get frontCamera => _frontCamera;

  // Function to initialize the camera.
  Future<void> initCamera() async{
    // If _cameraController is already initialized then return
    if (_cameraController != null) return;
    
    // Get a list of cameras
    List<CameraDescription> cameras = await availableCameras();
    // Get the front camera
    _frontCamera =
      cameras.firstWhere((camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.isNotEmpty ? cameras.first : throw Exception('No cameras found'),);

    // Create a _cameraController object
    _cameraController = CameraController(_frontCamera, ResolutionPreset.max,
        enableAudio: false, imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.nv21 // for Android
            : ImageFormatGroup.bgra8888, // for iOS
    );
    // Initialize the _cameraController object. Also handle exception.
    await _cameraController?.initialize().catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            throw Exception('You have denied camera access.');
          case 'CameraAccessDeniedWithoutPrompt':
            // iOS only
            throw Exception('Please go to Settings app to enable camera access.');
          case 'CameraAccessRestricted':
            // iOS only
            throw Exception('Camera access is restricted.');
        }
      }
    });
  }

  Future<XFile?> takePicture() async {
    if (_cameraController == null) return null;

    final XFile? image = await _cameraController?.takePicture();
    if (image == null) return null;
    return image;
  }

  // Dispose the cameraController
  void dispose() async {
    await _cameraController?.dispose();
    _cameraController = null;
  }
}