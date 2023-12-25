/* File contains FaceDetectorService class which holds the important attributes and
* methods required for detecting a face.
* We call this class a service cause the object of this class will be reused
* everywhere. */

import 'dart:io';

import 'package:camera/camera.dart';
import 'package:clockwrk_login/services/camera.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:clockwrk_login/locator.dart';

class FaceDetectorService {
  final CameraService _cameraService = locator<CameraService>();

  late FaceDetector _faceDetector;
  FaceDetector get faceDetector => _faceDetector;

  List<Face> _faces = [];
  List<Face> get faces => _faces;

  // Flag to know whether face is detected or not
  bool get faceDetected => _faces.isNotEmpty;

  final _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  initFaceDetector() {
    _faceDetector = FaceDetector(
        options: FaceDetectorOptions(
          enableContours: true,
          enableLandmarks: true,
        )
    );
  }

  // Function to get InputImage (fed to google ml-kit) from a CameraImage
  // (image from individual frames when we call 'startImageStream')
  InputImage? _inputImageFromCameraImage(CameraImage image) {
    // If _cameraController is not initialized then return
    if (_cameraService.cameraController == null) return null;

    // get image rotation
    // it is used in android to convert the InputImage from Dart to Java
    // `rotation` is not used in iOS to convert the InputImage from Dart to Obj-C
    // in both platforms `rotation` and `camera.lensDirection` can be used to compensate `x` and `y` coordinates on a canvas
    final sensorOrientation = _cameraService.frontCamera.sensorOrientation;
    InputImageRotation? rotation;
    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    }
    else if (Platform.isAndroid) {
      var rotationCompensation = _orientations[_cameraService.cameraController!.value.deviceOrientation];
      if (rotationCompensation == null) return null;
      if (_cameraService.frontCamera.lensDirection == CameraLensDirection.front) {
        // front-facing
        rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
      } else {
        // back-facing
        rotationCompensation =
            (sensorOrientation - rotationCompensation + 360) % 360;
      }
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
    }
    if (rotation == null) return null;

    // get image format
    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    // validate format depending on platform
    // only supported formats:
    // * nv21 for Android
    // * bgra8888 for iOS
    if (format == null ||
        (Platform.isAndroid && format != InputImageFormat.nv21) ||
        (Platform.isIOS && format != InputImageFormat.bgra8888)) return null;

    // since format is constraint to nv21 or bgra8888, both only have one plane
    if (image.planes.length != 1) return null;
    final plane = image.planes.first;

    // compose InputImage using bytes
    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation, // used only in Android
        format: format, // used only in iOS
        bytesPerRow: plane.bytesPerRow, // used only in iOS
      ),
    );
  }

  // Function to get InputImage (fed to google ml-kit) from a XFile
  // (image captured using 'takePicture')
  InputImage? _inputImageFromFileImage(XFile image) {
    // If _cameraController is not initialized then return
    if (_cameraService.cameraController == null) return null;

    return InputImage.fromFilePath(image.path);
  }

  // Function to detect faces from a CameraImage
  Future<void> detectFaceFromCameraImage(CameraImage image) async {
    final inputImage = _inputImageFromCameraImage(image);
    _faces = _faceDetector.processImage(inputImage!) as List<Face>;
  }

  // Function to detect faces from a XFile image
  Future<void> detectFaceFromFileImage(XFile image) async {
    final inputImage = _inputImageFromFileImage(image);
    _faces = await _faceDetector.processImage(inputImage!);
  }

  dispose() {
    _faces = [];
    _faceDetector.close();
  }
}