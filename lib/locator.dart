/* File contains GetIt.instance which helps us reuse the instances of service
* class (eg. CameraService) everywhere in the code. */

import 'package:get_it/get_it.dart';
import 'package:clockwrk_login/services/camera.dart';

// The get_it package is a service locator for Dart and Flutter applications.
// It allows you to register and retrieve objects (services) throughout your app,
// making it easy to manage dependencies and decouple different parts of your code.
// To register a CameraService:
//    locator.registerSingleton<CameraService>(()=>CameraService());
// To retrieve a service:
//    CameraService cameraService = locator<CameraService>();
//
// A singleton is a design pattern that ensures that a class has only one instance,
// while providing a global access point to that instance.

final locator = GetIt.instance;

void setupServices() {
  locator.registerLazySingleton<CameraService>(() => CameraService());
}