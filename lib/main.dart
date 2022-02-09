import 'dart:async';
import 'dart:isolate';

import 'package:BarcodeCaptureSimpleSample/pages/barcode_page.dart';
import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:scandit_flutter_datacapture_barcode/scandit_flutter_datacapture_barcode.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.

  print("[FirebaseManager] Handling a background message: ${message.messageId}");
}

void main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();

    await ScanditFlutterDataCaptureBarcode.initialize();
    List<CameraDescription> cameras = await availableCameras();// Obtain a list of the available cameras on the device.

    // Pass all uncaught errors from the framework to Crashlytics.
    FlutterError.onError = (error) {
      FirebaseCrashlytics.instance.recordFlutterError(error);
    };

    Isolate.current.addErrorListener(RawReceivePort((pair) async {
      final List<dynamic> errorAndStacktrace = pair;
      await FirebaseCrashlytics.instance.recordError(
        errorAndStacktrace.first,
        errorAndStacktrace.last,
      );
    }).sendPort);

    runApp(MyApp(cameras: cameras,));
  }, (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack);
  });

}

class MyApp extends StatelessWidget {
  const MyApp({Key? key, required this.cameras}) : super(key: key);

  final List<CameraDescription> cameras;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(
        title: 'Flutter Demo Home Page',
        cameras: cameras,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title, required this.cameras}) : super(key: key);
  final String title;
  final List<CameraDescription> cameras;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  Future<void> _initFirebaseMessaging() async {
    ///Requesting permission
    NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');

    ///Handling Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');
      print('Message mutableContent: ${message.mutableContent}');
      print('Message contentAvailable: ${message.contentAvailable}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });

    ///Handling Background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    String? fcmToken = await FirebaseMessaging.instance.getToken();
    String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
    print ("Firebase token: $fcmToken");
    print ("APNs token: $apnsToken");

    print('initializeMessaging init onBackgroundMessage');
    return;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    ///issue here
    _initFirebaseMessaging();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '0',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => BarcodePage()));
          // Navigator.of(context).push(MaterialPageRoute(builder: (_) => CameraPage(cameraDescription: widget.cameras.first)));
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
