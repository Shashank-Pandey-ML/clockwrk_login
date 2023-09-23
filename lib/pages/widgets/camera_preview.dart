/* File contains widget to show Camera Preview */

import 'package:camera/camera.dart';
import 'package:clockwrk_login/locator.dart';
import 'package:clockwrk_login/services/camera.dart';
import 'package:flutter/cupertino.dart';

class CameraPreviewWidget extends StatelessWidget {
  CameraPreviewWidget(CameraController? cameraController, {super.key});

  final CameraService _cameraService = locator<CameraService>();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Transform.scale(
      scale: 1.0,
      child: AspectRatio(
        aspectRatio: MediaQuery.of(context).size.aspectRatio,
        child: OverflowBox(
          alignment: Alignment.center,
          child: FittedBox(
            fit: BoxFit.fitHeight,
            child: Container(
              width: width,
              height:
              width * _cameraService.cameraController!.value.aspectRatio,
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  CameraPreview(_cameraService.cameraController!),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}