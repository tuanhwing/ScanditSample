
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:scandit_flutter_datacapture_barcode/scandit_flutter_datacapture_barcode.dart';
import 'package:scandit_flutter_datacapture_barcode/scandit_flutter_datacapture_barcode_capture.dart';
import 'package:scandit_flutter_datacapture_core/scandit_flutter_datacapture_core.dart';

const String licenseKey = 'AZwRzwyRLZAGPRZJFSYeTRMUA7aaAIqzpRpTUT57WM3ZZ9iJTS9uL/pbrC7AceZZoXCRvwtXYVNdDQnLQlUoO6VDlRgaZ+3RnygQGKdd0r2Xfe1wRkYPSmZ0o0coV6JAvWfKETN1Qm6eQmNie25SFe9eS1k1TQC/PWeVjhIzMWW2A6Vk4mPBKfxrDkYHZxUM02zE+yl1FnGbVSow8mgO4lBWjTj3ZLPXvngZMNhO+nwVcpkKfWjpEixHbOX0dvFQHUrz5l9i+q0xSN2Zlk8UWD1Z2nhdYWJF4k49MqptnYOOdZTHGivX1OFQ74EwVIB2Oi94aLpqKMoQZ/wIkk8vSG5OaBBJYvITRXJdj6hK/3qqWqr6gmvcPL1IPF7VQl7uqXGTX+lG5SIMQcFgYVfl62VrInBtT2SRpWSDa3UQVjctbehAiXmj+9d1k9wmS8v7R2cBjrZFHbTjb1pv5kpw2w9rMyYafXdZuF5c9VFmS3McQgFmuWXtZylZqZmZaQwdO0MLWmUO1TO7GEqJPA6sd51+Y4tIy4S66LtH/ECvHCCOYZgZMkcQRT5nQyANXvApNrzXfA7GbzrdOsepikIq3UmE5CTIlnLQm5MkU1qyuBjYlS+Uu643MYRICm2rOP3cTaOFVZpD6k+oQ/6DeND2wJD/AvXdCWj9ykjAE+r50dkzN49ziYkdOEpgrZGu+N4MGYU5bx+yenwlBQAsggEo93W1lzshD0ka4SY1Mch3IBO3e5JyIr51QfuURtzMdMsKu6mUIcvyE7I5u2eROcEehAn7htc90gIEpYOfCphGloS6/M0CD9nXH66GLCC3BEUdwC7MorCG0dJ3sax9nlE8iLEjw5K0drC46kDNiQCtEpxlzLpWKymkKIHUn+3PZnPZ+PCy1kmoji47Nqygs3qofoWq5Pk19n0EOyJjUFrNkFj09U9JbsyZExfc+sHIxZ5fnOSismqNOIW/hb3XkunlZLdRSO71cxFroe05ByrH2Pw7jKEQUNs+N86X4s5uJje+weeS2CJhRK+85vCCoATyxJPrHtH9WuscJGyIRh2e9q26rwY/jI4jt9DW5J94aKLc6mDBViaPEKimToqIZTmxxJ717dGv4JjtlFVfHd8BUEMXGyQp4w1TIJoct3rvF408O7rRbNpLTyo6ee4hTaY5eTTfLW//mk/qIcqnVIm/3k9gmxFN8ydm2L72mY+XCPN/';

class BarcodePage extends StatefulWidget {
  const BarcodePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _BarcodeState(DataCaptureContext.forLicenseKey(licenseKey));

}

class _BarcodeState extends State<BarcodePage>  with WidgetsBindingObserver
    implements BarcodeCaptureListener {
  final DataCaptureContext _context;

  // Use the world-facing (back) camera.
  Camera? _camera = Camera.defaultCamera;
  late BarcodeCapture _barcodeCapture;
  late DataCaptureView _captureView;

  bool _isPermissionMessageVisible = false;

  _BarcodeState(this._context);

  void _checkPermission() {
    Permission.camera.request().isGranted.then((value) => setState(() {
      _isPermissionMessageVisible = !value;
      if (value) {
        _camera?.switchToDesiredState(FrameSourceState.on);
      }
    }));
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);

    // Use the recommended camera settings for the BarcodeCapture mode.
    _camera?.applySettings(BarcodeCapture.recommendedCameraSettings);

    // Switch camera on to start streaming frames and enable the barcode tracking mode.
    // The camera is started asynchronously and will take some time to completely turn on.
    _checkPermission();

    // The barcode capture process is configured through barcode capture settings
    // which are then applied to the barcode capture instance that manages barcode capture.
    var captureSettings = BarcodeCaptureSettings();

    // The settings instance initially has all types of barcodes (symbologies) disabled. For the purpose of this
    // sample we enable a very generous set of symbologies. In your own app ensure that you only enable the
    // symbologies that your app requires as every additional enabled symbology has an impact on processing times.
    captureSettings.enableSymbologies({
      Symbology.ean8,
      Symbology.ean13Upca,
      Symbology.upce,
      Symbology.qr,
      Symbology.dataMatrix,
      Symbology.code39,
      Symbology.code128,
      Symbology.interleavedTwoOfFive
    });

    // Some linear/1d barcode symbologies allow you to encode variable-length data. By default, the Scandit
    // Data Capture SDK only scans barcodes in a certain length range. If your application requires scanning of one
    // of these symbologies, and the length is falling outside the default range, you may need to adjust the "active
    // symbol counts" for this symbology. This is shown in the following few lines of code for one of the
    // variable-length symbologies.
    captureSettings.settingsForSymbology(Symbology.code39).activeSymbolCounts =
        [for (var i = 7; i <= 20; i++) i].toSet();

    // Create new barcode capture mode with the settings from above.
    _barcodeCapture = BarcodeCapture.forContext(_context, captureSettings)
    // Register self as a listener to get informed whenever a new barcode got recognized.
      ..addListener(this);

    // To visualize the on-going barcode capturing process on screen, setup a data capture view that renders the
    // camera preview. The view must be connected to the data capture context.
    _captureView = DataCaptureView.forContext(_context);

    // Add a barcode capture overlay to the data capture view to render the location of captured barcodes on top of
    // the video preview. This is optional, but recommended for better visual feedback.
    // var overlay = BarcodeCaptureOverlay.withBarcodeCaptureForViewWithStyle(
    //     _barcodeCapture, _captureView, BarcodeCaptureOverlayStyle.frame)
    //   ..viewfinder = RectangularViewfinder.withStyleAndLineStyle(
    //       RectangularViewfinderStyle.square, RectangularViewfinderLineStyle.light);

    // Adjust the overlay's barcode highlighting to match the new viewfinder styles and improve the visibility of feedback.
    // With 6.10 we will introduce this visual treatment as a new style for the overlay.
    // overlay.brush = Brush(Color.fromARGB(0, 0, 0, 0), Color.fromARGB(255, 255, 255, 255), 3);

    // _captureView.addOverlay(overlay);

    // Set the default camera as the frame source of the context. The camera is off by
    // default and must be turned on to start streaming frames to the data capture context for recognition.
    if (_camera != null) {
      _context.setFrameSource(_camera!);
    }
    _camera?.switchToDesiredState(FrameSourceState.on);
    _barcodeCapture.isEnabled = true;
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (_isPermissionMessageVisible) {
      child = PlatformText('No permission to  access the camera!',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black));
    } else {
      child = _captureView;
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('barcode'),
      ),
      body: Center(child: child)
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermission();
    } else if (state == AppLifecycleState.paused) {
      _camera?.switchToDesiredState(FrameSourceState.off);
    }
  }

  @override
  void didScan(BarcodeCapture barcodeCapture, BarcodeCaptureSession session) async {
    _barcodeCapture.isEnabled = false;
    var code = session.newlyRecognizedBarcodes.first;
    var data = (code.data == null || code.data?.isEmpty == true) ? code.rawData : code.data;
    var humanReadableSymbology = SymbologyDescription.forSymbology(code.symbology);
    await showPlatformDialog(
        context: context,
        builder: (_) => PlatformAlertDialog(
          content: PlatformText(
            'Scanned: $data\n (${humanReadableSymbology.readableName})',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          actions: [
            PlatformDialogAction(
                child: PlatformText('OK'),
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop();
                })
          ],
        ));
    _barcodeCapture.isEnabled = true;
  }

  @override
  void didUpdateSession(BarcodeCapture barcodeCapture, BarcodeCaptureSession session) {}

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    _barcodeCapture.removeListener(this);
    _barcodeCapture.isEnabled = false;
    _camera?.switchToDesiredState(FrameSourceState.off);
    _context.removeAllModes();
    super.dispose();
  }
}