
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'barcode_page.dart';

class CameraPage extends StatefulWidget {

  final CameraDescription cameraDescription;

  const CameraPage({Key? key, required this.cameraDescription}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CameraState();

}

class _CameraState extends State<CameraPage> with WidgetsBindingObserver {
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
    final CameraController cameraController = CameraController(
      // Get a specific camera from the list of available cameras.
        widget.cameraDescription,
        // Define the resolution to use.
        ResolutionPreset.medium,
        enableAudio: false
    );
    controller = cameraController;
    // If the controller is updated then update the UI.
    cameraController.addListener(() {
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
    final CameraController? cameraController = controller;
    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _onNewCameraSelected();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);

    _onNewCameraSelected();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('camera'),
      ),
      body: _cameraWidget(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {

          try {

            final XFile? file = await controller?.takePicture();

            print ('AAAAAA path: ${file!.path}');
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const BarcodePage()));

          } catch (e) {
            // If an error occurs, log the error to Firebase.
            print ("AAAAA capture exception: ${e.toString()}");
          }
        },
        tooltip: 'Increment',
        child: const Icon(Icons.camera),
      ),
    );
  }

}