/* File contains Camera class which holds the important attributes and
* methods required for dealing with a camera.
* We call this class a service cause the object of this class will be reused
* everywhere. */

import 'dart:async';
import 'package:camera/camera.dart';

class CameraService {
  CameraController? _cameraController;
  // Getter method to give read only access _cameraController
  CameraController? get cameraController => _cameraController;

  // Function to initialize the camera.
  Future<void> initCamera() async{
    // If _cameraController is already initialized then return
    if (_cameraController != null) return;
    
    // Get a list of cameras
    List<CameraDescription> cameras = await availableCameras();
    // Get the front camera
    CameraDescription frontCamera =
      cameras.firstWhere((camera) => camera.lensDirection == CameraLensDirection.front);

    // Create a _cameraController object
    _cameraController = CameraController(frontCamera, ResolutionPreset.max, enableAudio: false);
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

  // Dispose the cameraController
  void dispose() async {
    await _cameraController?.dispose();
    _cameraController = null;
  }
}