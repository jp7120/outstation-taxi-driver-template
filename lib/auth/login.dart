import 'package:driver_app/auth/otpScreen.dart';

import 'package:driver_app/auth/widgets.dart';
import 'package:driver_app/screens/uploadDocuments.dart';
import 'package:driver_app/model/driverDetail.dart';
import 'package:driver_app/notification/setup.dart';
import 'package:driver_app/routes.dart';
import 'package:driver_app/widgets/roundedButton.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PhoneInputScreen extends StatefulWidget {
  @override
  _PhoneInputScreenState createState() => _PhoneInputScreenState();
}

class _PhoneInputScreenState extends State<PhoneInputScreen> {
  double _height, _width, _fixedPadding;

  @override
  void initState() {
    super.initState();
    _getFirebaseUser();

    focusNode.requestFocus();
  }

  final scaffoldKey =
      GlobalKey<ScaffoldState>(debugLabel: "scaffold-get-phone");

  TextEditingController _phoneNumberController = TextEditingController();

  FirebaseUser _firebaseUser;
  String _status;

  FocusNode focusNode = FocusNode();

  bool isOtp = false;

  var otp;

  TextEditingController _pinPutController = TextEditingController(text: '');
  final _pinPutFocusNode = FocusNode();
  final _pageController = PageController();

  FocusNode phone = FocusNode();

  Future<bool> _willPopCallback() async {
    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              'Are you sure you want to go back?',
              style: title,
            ),
            actions: [
              Container(
                width: 100,
                child: CustomButton(
                    title: 'yes'.toUpperCase(),
                    isIcon: false,
                    color: Colors.greenAccent.shade700,
                    context: context,
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (c) => PhoneInputScreen()),
                          (route) => false);
                    }),
              ),
              Container(
                width: 100,
                child: CustomButton(
                    title: 'no'.toUpperCase(),
                    isIcon: false,
                    color: Colors.greenAccent.shade700,
                    context: context,
                    onPressed: () {
                      Navigator.of(context).pop();
                    }),
              )
            ],
          );
        });

    // eturn true if the route to be popped

    return false;

    // return true if the route to be popped
  }

  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;
    _fixedPadding = _height * 0.025;

    final mQ = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: _willPopCallback,
      child: Scaffold(
          key: scaffoldKey,
          backgroundColor: Colors.white.withOpacity(0.95),
          body: SafeArea(
            child: Stack(
              children: <Widget>[
                Center(
                  child: SingleChildScrollView(
                    child: _getBody(),
                  ),
                ),
                // loader ? CircularProgressIndicator() : SizedBox()
              ],
            ),
          )),
    );
  }

  Widget _getBody() => Card(
      color: Colors.amberAccent,
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.0)),
      child: Container(
        decoration: BoxDecoration(
            gradient: FlutterGradients.northMiracle(),
            borderRadius: BorderRadius.circular(28.0)),
        child: SizedBox(
            height: _height * 9 / 10,
            width: _width * 9 / 10,
            child: _getColumnBody()),
      ));

  Widget _getColumnBody() => Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          //  Logo: scaling to occupy 2 parts of 10 in the whole height of device
          Padding(
            padding: EdgeInsets.all(_fixedPadding),
            child: PhoneAuthWidgets.getLogo(
                logoPath: 'assets/images/logo.png', height: _height * 0.2),
          ),

          // AppName:
          Text('${Constants.appName}',
              textAlign: TextAlign.center,
              style: title.copyWith(
                  color: Colors.white,
                  fontSize: 24.0,
                  fontWeight: FontWeight.w700)),
          SizedBox(height: 20),

          //  Subtitle for Enter your phone
          Padding(
            padding: EdgeInsets.only(top: 10.0, left: _fixedPadding),
            child: SubTitle(text: 'Enter your phone'),
          ),
          //  PhoneNumber TextFormFields
          Padding(
            padding: EdgeInsets.only(
                left: _fixedPadding,
                right: _fixedPadding,
                bottom: _fixedPadding),
            child: PhoneNumberField(
              focusNode: phone,
              controller: _phoneNumberController,
              prefix: "+91",
            ),
          ),

          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(width: _fixedPadding),
              Icon(Icons.info, color: Colors.white, size: 20.0),
              SizedBox(width: 10.0),
              Expanded(
                child: RichText(
                    text: TextSpan(children: [
                  TextSpan(
                      text: 'We will send ',
                      style: sub.copyWith(
                          color: Colors.white, fontWeight: FontWeight.w400)),
                  TextSpan(
                      text: 'OTP'.toUpperCase(),
                      style: title.copyWith(
                          color: Colors.white,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w700)),
                  TextSpan(
                      text: ' to this mobile number.',
                      style: sub.copyWith(
                          color: Colors.white, fontWeight: FontWeight.w400)),
                ])),
              ),
              SizedBox(width: _fixedPadding),
            ],
          ),

          SizedBox(height: _fixedPadding * 1.5),

          RaisedButton(
            elevation: 16.0,
            onPressed: () {
              if (_phoneNumberController.text.trim().length >= 10)
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => OTPScreen(
                              phone: _phoneNumberController.text.trim(),
                            )));
              else {
                Fluttertoast.showToast(
                    msg: "Kindly enter your 10 digit phone number!");
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'SEND OTP',
                style: title.copyWith(color: Colors.white),
              ),
            ),
            color: Colors.deepOrangeAccent,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0)),
          ),
        ],
      );

  _showSnackBar(String text) {
    final snackBar = SnackBar(
      content: Text('$text'),
    );
//    if (mounted) Scaffold.of(context).showSnackBar(snackBar);
    scaffoldKey.currentState.showSnackBar(snackBar);
  }

/*   void _handleError(e) {
    print(e.message);
    setState(() {
      _status += e.message + '\n';
    });
  } */

  getUserInfo() {
    var local = basicController.getCurrentUser();

    Firestore.instance
        .collection("DriverDetails")
        .document("Zpp4hPUHk0fNNkK114hWxoW19lH3")
        .get()
        .then((value) {
      if (value.exists) {
        if (value.data['docsUploaded'] == true) {
          print(value.data['docsUploaded']);
          getTokenAndUpload(_firebaseUser);

          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => DriverHomeScreen()),
              (route) => false);
          print('goto home');
        }
      } else
        print("NO docs");
    });
  }

  Future<void> _getFirebaseUser() async {
    var user = await FirebaseAuth.instance.currentUser();

    if (user != null) {
      print('USER ${user.phoneNumber}');
      // print('USER ${preferences.getBool('isDocumentsUploaded')}');
      // print(_firebaseUser.phoneNumber);
      /* if (preferences.getBool('isDocumentsUploaded') == true) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => summa()));
      } else if (preferences.getBool('isDocumentsUploaded') == false) { */

      // var local = basicController.getCurrentUser();

      Firestore.instance
          .collection("DriverDetails")
          .document(user.uid)
          .get()
          .then((value) {
        if (value.exists) {
          if (value.data['docsUploaded'] == true) {
            print(value.data['docsUploaded']);
            getTokenAndUpload(_firebaseUser);

            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => DriverHomeScreen()),
                (route) => false);
            print('goto home');
          }
        } else {
          print("NO docs");
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => UploadDocuments()));
        }
      });

      // }
    }

    setState(() {
      _status =
          (_firebaseUser == null) ? 'Not Logged In\n' : 'Already LoggedIn\n';
    });
  }

  final FirebaseMessaging _fcm = FirebaseMessaging();

  var notifiToken = '';

  getTokenAndUpload(FirebaseUser user) {
    var time = DateTime.now().toString();
    _fcm.getToken().then((value) {
      notifiToken = value;
      print(notifiToken);
      Firestore.instance
          .collection("DriverDetails")
          .document(user.uid)
          .updateData({
        'tokenUpdatedAt': time,
        'lastLoginAt': time,
        'token': notifiToken
      });
    }).then((value) {
      print('notification token updated in firebase');
    });
  }

  BasicController basicController = Get.put(BasicController());
}
