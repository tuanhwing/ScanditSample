
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CameraWidget extends StatefulWidget {
  const CameraWidget({Key? key, this.capturedFunction});
  final Function(String)? capturedFunction;
  @override
  State<StatefulWidget> createState() => _CameraState();

}

class _CameraState extends State<CameraWidget> with WidgetsBindingObserver {

  CameraController? controller;
  ///Camera Preview Widget
  Widget _cameraWidget(context) {
    if (controller == null || !controller!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator(),);
    }

    var camera = controller!.value;
    // fetch screen size
    final size = MediaQuery.of(context).size;

    // calculate scale depending on screen and camera ratios
    // this is actually size.aspectRatio / (1 / camera.aspectRatio)
    // because camera preview size is received as landscape
    // but we're calculating for portrait orientation
    var scale = size.aspectRatio * camera.aspectRatio;

    // to prevent scaling down, invert the value
    if (scale < 1) scale = 1 / scale;

    return Transform.scale(
      scale: scale,
      child: Center(
        child: CameraPreview(controller!),
      ),
    );
  }

  void _onNewCameraSelected() async {
    if (controller != null) {
      await controller?.dispose();
    }
    List<CameraDescription> cameras = await availableCameras();
    if (cameras.isEmpty) return;

    final CameraController cameraController = CameraController(
      // Get a specific camera from the list of available cameras.
        cameras.first,
        // Define the resolution to use.
        ResolutionPreset.max,
        enableAudio: false
    );
    controller = cameraController;
    // If the controller is updated then update the UI.
    cameraController.addListener(() {
      print("_onNewCameraSelected cameraController.addListener");
      if (mounted) setState(() {});
      if (cameraController.value.hasError) {
        print("_onNewCameraSelected cameraController.value.hasError");
      }
    });
    try {
      await cameraController.initialize();
      controller?.setFlashMode(FlashMode.off);
      controller?.lockCaptureOrientation(DeviceOrientation.portraitUp);
    } on CameraException catch (e) {
      print("${this.runtimeType} _onNewCameraSelected" + e.toString());
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print ("AAAAAAAA didChangeAppLifecycleState $state");
    // App state changed before we got the chance to initialize.
    if (controller == null || !controller!.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      if (controller != null) {
        _onNewCameraSelected();
      }
    }
  }

  void _captureImage() async {
    try {

      final XFile? file = await controller?.takePicture();
      if (file != null) {
        print ('AAAAAA path: ${file.path}');

        widget.capturedFunction?.call(file.path);
      }


    } catch (e) {
      // If an error occurs, log the error to Firebase.
      print ("AAAAA capture exception: ${e.toString()}");
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);

    _onNewCameraSelected();
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);

    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _cameraWidget(context),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
                onPressed: _captureImage,
                child: Text("Capture")
            ),
          ],
        )

      ],
    );
  }

}
