import 'package:driver_app/auth/login.dart';
import 'package:driver_app/model/driverDetail.dart';
import 'package:flutter/material.dart';
import 'package:driver_app/routes.dart';

import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  BasicController controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller = Get.put(BasicController());

    getCurrentUser();
  }

  void getCurrentUser() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    if (user == null) {
      Future.delayed(Duration(seconds: 2), () {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => PhoneInputScreen()));
      });
    } else if (user != null) {
      // print(user.displayName);
      controller.setCurrentUser(user);

      Firestore.instance
          .collection("DriverDetails")
          .document(user.uid)
          .get()
          .then((value) {
        print(value.data);
        if (value.data == null) {
          print("NO docs");
          Future.delayed(Duration(seconds: 2), () {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => UploadDocuments()));
          });
        }
        if (value.data != null) {
          if (value.data['docsUploaded'] == true) {
            print(value.data['docsUploaded']);
            DriverDetails dr = DriverDetails.fromJson(value.data);
            controller.setCurrentDriver(dr);

            Future.delayed(Duration(seconds: 2), () {
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => DriverHomeScreen()));
            });
            print('goto home');
          } else {
            print("NO docs");
            Future.delayed(Duration(seconds: 2), () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => UploadDocuments()));
            });
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var height = Get.height;
    var width = Get.height;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        height: Get.height,
        width: Get.width,
        decoration: BoxDecoration(
            gradient: FlutterGradients.happyFisher(tileMode: TileMode.clamp)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            /* Lottie.asset('assets/images/carSplash.json',
                height: height * 0.5, width: width * 0.8), */

            Expanded(child: Image.asset('assets/images/logo.png')),
            Center(
              child: Text(
                '${Constants.appName}',
                style: title.copyWith(fontSize: 25, color: Colors.white),
              ),
            ),
            SpinKitThreeBounce(
              color: Constants.primaryColor,
            )
          ],
        ),
      ),
    );
  }
}
