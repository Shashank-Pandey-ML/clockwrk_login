/* File contains FaceRecognitionService class which holds the important attributes and
* methods required for recognizing a face.
* We call this class a service cause the object of this class will be reused
* everywhere. */

import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:clockwrk_login/db/db_helper.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

import '../locator.dart';
import '../models/employee.dart';

class FaceRecognitionService {
  Interpreter? _interpreter;
  double threshold = 0.5;

  List _predictedData = [];
  List get predictedData => _predictedData;

  final DbHelper _dbHelper = locator<DbHelper>();

  /// Initializes the face recognition service by loading the tflite model trained to
  /// convert image to a list of numbers which then can be used for identifying employees.
  Future initFaceRecognition() async {
    // late Delegate delegate;
    try {
      // INFO: This commented out code is not working. Will need more debugging.
      // if (Platform.isAndroid) {
      //   delegate = GpuDelegateV2(
      //     options: GpuDelegateOptionsV2(
      //       isPrecisionLossAllowed: false,
      //       inferencePreference: TfLiteGpuInferenceUsage.fastSingleAnswer,
      //       inferencePriority1: TfLiteGpuInferencePriority.maxPrecision,
      //       inferencePriority2: TfLiteGpuInferencePriority.minLatency,
      //       inferencePriority3: TfLiteGpuInferencePriority.auto,
      //     ),
      //   );
      // }
      // else if (Platform.isIOS) {
      //   delegate = GpuDelegate(
      //     options: GpuDelegateOptions(
      //         allowPrecisionLoss: true,
      //         waitType: 1
      //     ),
      //   );
      // }
      // var interpreterOptions = InterpreterOptions()..addDelegate(delegate);

      // _interpreter = await Interpreter.fromAsset('assets/mobilefacenet.tflite',
      //     options: interpreterOptions);

      _interpreter = await Interpreter.fromAsset('assets/mobilefacenet.tflite');
    } catch (e) {
      throw Exception('Failed to load the Face Recognition Model. ${e.toString()}');
    }
  }

  /// Function which takes the image and the face detected as inputs and
  /// sets the current predicted facial data attribute of this service.
  Future setCurrentPrediction(XFile image, Face? face) async {
    if (_interpreter == null) throw Exception('Interpreter is null');
    if (face == null) throw Exception('Face is null');
    List input = await _preProcess(image, face);

    input = input.reshape([1, 112, 112, 3]);
    List output = List.generate(1, (index) => List.filled(192, 0));

    _interpreter?.run(input, output);
    output = output.reshape([192]);

    _predictedData = List.from(output);
  }

  /// Preprocesses the image by cropping the face and returning the resulting
  /// image as a Float32List.
  Future<List> _preProcess(XFile image, Face faceDetected) async {
    img.Image croppedImage = await _cropFace(image, faceDetected);
    img.Image resizedImage = img.copyResizeCropSquare(croppedImage, size: 112);

    Float32List imageAsList = imageToByteListFloat32(resizedImage);
    return imageAsList;
  }

  /// Function to crop a face from the image
  Future<img.Image> _cropFace(XFile image, Face faceDetected) async {
    img.Image? convertedImage = await _convertXFileImage(image);
    double x = faceDetected.boundingBox.left - 10.0;
    double y = faceDetected.boundingBox.top - 10.0;
    double w = faceDetected.boundingBox.width + 10.0;
    double h = faceDetected.boundingBox.height + 10.0;
    return img.copyCrop(
        convertedImage!, x: x.round(), y: y.round(), width: w.round(), height: h.round());
  }

  /// Converts a XFile to a img.Image
  Future<img.Image?> _convertXFileImage(XFile image) async {
    return img.decodeImage(await image.readAsBytes());
  }

  /// Converts a img.Image to a Float32List
  Float32List imageToByteListFloat32(img.Image image) {
    var convertedBytes = Float32List(1 * 112 * 112 * 3);
    var buffer = Float32List.view(convertedBytes.buffer);
    int pixelIndex = 0;

    for (var i = 0; i < 112; i++) {
      for (var j = 0; j < 112; j++) {
        var pixel = image.getPixel(j, i);
        buffer[pixelIndex++] = (pixel.r - 128) / 128;
        buffer[pixelIndex++] = (pixel.g - 128) / 128;
        buffer[pixelIndex++] = (pixel.b - 128) / 128;
      }
    }
    return convertedBytes.buffer.asFloat32List();
  }

  /// Function to check whether the face identified in a image is already
  /// registered within the DB or not.
  Future<Employee?> predictEmployee(String adminId) async {
    return _dbHelper.getEmployeeByModelData(adminId, _predictedData);
  }

  /// Function which assigns 'value' to the '_predictedData' attribute
  void setPredictedData(value) {
    _predictedData = value;
  }

  dispose() {
    _interpreter?.close();
  }
}
