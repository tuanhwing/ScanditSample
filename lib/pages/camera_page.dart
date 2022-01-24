
import 'package:BarcodeCaptureSimpleSample/widgets/camera_widget.dart';
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

class _CameraState extends State<CameraPage> {

  String? _captureString;

  Widget get _capturedWidget {
    return Column(
      children: [
        Text(_captureString ?? "NONE"),
        TextButton(
            onPressed: () async {
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => BarcodePage()));
            },
            child: Text("Barcode")
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('camera'),
      ),
      body: _captureString != null ? _capturedWidget : CameraWidget(
        capturedFunction: (value) {
          setState(() {
            _captureString = value;
          });
        }
      ),
    );
  }

}