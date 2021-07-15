import 'package:driver_app/routes.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:screen/screen.dart';
import 'constants.dart';
import 'notification/notificationLaunch.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(FireApp());
}

class FireApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Screen.keepOn(true);
    return GetMaterialApp(
      theme: ThemeData(
        primaryColor: Constants.primaryColor,
        primarySwatch: Colors.red,
      ),
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Assets {
  static String _imagesRoot = "assets/images/";
  static String firebase = _imagesRoot + "logo.png";

  static const double fourBy1 = 4.0;
  static const double fourBy2 = 8.0;
  static const double fourBy3 = 12.0;
  static const double fourBy4 = 16.0;

  static const double eightBy1 = 8.0;
  static const double eightBy2 = 16.0;
  static const double eightBy3 = 24.0;
  static const double eightBy4 = 32.0;

  static const double sixteenBy1 = 16.0;
  static const double sixteenBy2 = 32.0;
  static const double sixteenBy3 = 48.0;
  static const double sixteenBy4 = 64.0;
}
