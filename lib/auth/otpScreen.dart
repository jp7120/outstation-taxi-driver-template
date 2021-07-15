import 'package:driver_app/auth/login.dart';
import 'package:driver_app/screens/uploadDocuments.dart';
import 'package:driver_app/model/driverDetail.dart';
import 'package:driver_app/notification/setup.dart';
import 'package:driver_app/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class OTPScreen extends StatefulWidget {
  final String phone;

  const OTPScreen({Key key, this.phone}) : super(key: key);
  @override
  _OTPScreenState createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  double _height, _width, _fixedPadding;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () => _submitPhoneNumber());
  }

  final scaffoldKey =
      GlobalKey<ScaffoldState>(debugLabel: "scaffold-get-phone");

  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _otpController = TextEditingController();

  FirebaseUser _firebaseUser;
  String _status;

  AuthCredential _phoneAuthCredential;
  String _verificationId;
  int _code;

  FocusNode focusNode = FocusNode();

  bool isOtp = false;

  var otp;

  TextEditingController _pinPutController = TextEditingController(text: '');
  final _pinPutFocusNode = FocusNode();
  final _pageController = PageController();

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
    //  Fetching height & width parameters from the MediaQuery
    //  _logoPadding will be a constant, scaling it according to device's size
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;
    _fixedPadding = _height * 0.025;
    // final loader = Provider.of<PhoneAuthDataProvider>(context).loading;

    final mQ = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: _willPopCallback,
      child: Scaffold(
          key: scaffoldKey,
          backgroundColor: Colors.white.withOpacity(0.95),
          body: SafeArea(
            child: Container(
              width: Get.width,
              height: Get.height,
              // color: Colors.black,
              child: Stack(
                children: [
                  Positioned(
                    top: 10,
                    left: 10,
                    child: CircleAvatar(
                      backgroundColor: Colors.greenAccent,
                      child: IconButton(
                        icon: Icon(Icons.arrow_back_ios_outlined),
                        color: Colors.black,
                        onPressed: _willPopCallback,
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                          height: Get.height * 0.2,
                          width: Get.width * 0.8,
                          child: Image.asset('assets/images/logo.png')),

                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Text("Phone Verification",
                                style:
                                    sub.copyWith(color: Colors.orangeAccent)),
                            SizedBox(height: mQ.height * 0.01),
                            Text(
                              "Enter your OTP code below",
                              style: CustomStyles.mediumTextStyle,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        // width: Get.width,
                        // padding: EdgeInsets.all(10),
                        child: PinCodeTextField(
                          controller: _pinPutController,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          textInputType: TextInputType.number,
                          length: 6,
                          obsecureText: false,
                          inactiveColor: Colors.black,
                          animationType: AnimationType.fade,
                          shape: PinCodeFieldShape.underline,
                          animationDuration: Duration(milliseconds: 300),
                          borderRadius: BorderRadius.circular(5),
                          fieldHeight: 30,
                          fieldWidth: 25,
                          autoFocus: true,
                          onChanged: (value) {
                            setState(() {
                              otp = value;
                            });
                            print(value);
                          },
                        ),
                      ),
                      isLoading
                          ? Container(
                              width: Get.width * 0.8,
                              decoration: BoxDecoration(
                                  gradient: FlutterGradients.aquaGuidance(),
                                  boxShadow: [
                                    BoxShadow(
                                      offset: Offset(0, 5),
                                      spreadRadius: -10,
                                      blurRadius: 20,
                                    )
                                  ],
                                  borderRadius: BorderRadius.circular(20)),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  /* Text(
                                          'Verifying OTP',
                                          style:
                                              title.copyWith(color: Colors.white),
                                        ),
                                        SizedBox(width: 10), */
                                  SpinKitThreeBounce(
                                    color: Colors.white,
                                  )
                                ],
                              ),
                              padding: EdgeInsets.all(6),
                            )
                          : InkWell(
                              onTap: () {
                                _submitOTP();
                              },
                              child: Container(
                                width: Get.width * 0.8,
                                decoration: BoxDecoration(
                                    gradient: FlutterGradients.aquaGuidance(),
                                    boxShadow: [
                                      BoxShadow(
                                        offset: Offset(0, 5),
                                        spreadRadius: -10,
                                        blurRadius: 20,
                                      )
                                    ],
                                    borderRadius: BorderRadius.circular(20)),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Submit OTP',
                                      style:
                                          title.copyWith(color: Colors.white),
                                    ),
                                    SizedBox(width: 10),
                                    CircleAvatar(
                                      backgroundColor: Colors.greenAccent,
                                      child: Icon(
                                        Icons.arrow_forward,
                                        color: Colors.black,
                                        size: 15,
                                      ),
                                    ),
                                  ],
                                ),
                                padding: EdgeInsets.all(6),
                              ),
                            ),
                      // InScreenNumberKeyword(pinPutController: _pinPutController),
                    ],
                  ),
                ],
              ),
            ),
          )),
    );
  }

  /*
   *  Widget hierarchy ->
   *    Scaffold -> SafeArea -> Center -> SingleChildScrollView -> Card()
   *    Card -> FutureBuilder -> Column()
   */

  _showSnackBar(String text) {
    final snackBar = SnackBar(
      content: Text('$text'),
    );
//    if (mounted) Scaffold.of(context).showSnackBar(snackBar);
    scaffoldKey.currentState.showSnackBar(snackBar);
  }

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

  /// phoneAuthentication works this way:
  ///     AuthCredential is the only thing that is used to authenticate the user
  ///     OTP is only used to get AuthCrendential after which we need to authenticate with that AuthCredential
  ///
  /// 1. User gives the phoneNumber
  /// 2. Firebase sends OTP if no errors occur
  /// 3. If the phoneNumber is not in the device running the app
  ///       We have to first ask the OTP and get `AuthCredential`(`_phoneAuthCredential`)
  ///       Next we can use that `AuthCredential` to signIn
  ///    Else if user provided SIM phoneNumber is in the device running the app,
  ///       We can signIn without the OTP.
  ///       because the `verificationCompleted` callback gives the `AuthCredential`(`_phoneAuthCredential`) needed to signIn
  Future<void> _login() async {
    /// This method is used to login the user
    /// `AuthCredential`(`_phoneAuthCredential`) is needed for the signIn method
    /// After the signIn method from `AuthResult` we can get `FirebaserUser`(`_firebaseUser`)

    setState(() {
      isLoading = true;
    });

    try {
      if (_phoneAuthCredential != null) {
        var authRes = await FirebaseAuth.instance
            .signInWithCredential(this._phoneAuthCredential);

        if (authRes != null) {
          _firebaseUser = authRes.user;
          basicController.setCurrentUser(authRes.user);
          Firestore.instance
              .collection("DriverDetails")
              .document(_firebaseUser.uid)
              .get()
              .then((value) {
            if (value.exists) {
              if (value.data['docsUploaded'] == true) {
                setState(() {
                  isLoading = false;
                });

                DriverDetails d = DriverDetails.fromJson(value.data);
                basicController.setCurrentDriver(d);

                getTokenAndUpload(_firebaseUser);

                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => DriverHomeScreen()),
                    (route) => false);
                print('goto home');
              }
            } else {
              setState(() {
                isLoading = false;
              });
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => UploadDocuments()),
                  (route) => false);
              print("NO docs");
            }
          });

          print(_firebaseUser.phoneNumber.toString());
          setState(() {
            _status += 'Signed In\n';
          });
        }
      }
    } on PlatformException catch (e) {
      print("in login " + e.toString());
      Fluttertoast.showToast(msg: "${e.message.split(".")[0]}");
      setState(() {
        isLoading = false;
      });
      // Get.back();
    }
  }

  Future<void> _logout() async {
    /// Method to Logout the `FirebaseUser` (`_firebaseUser`)
    try {
      // signout code
      await FirebaseAuth.instance.signOut();
      _firebaseUser = null;
      setState(() {
        _status += 'Signed out\n';
      });
    } catch (e) {
      print(e);
    }
  }

  bool isLoading = false;

  Future<void> _submitPhoneNumber() async {
    Get.dialog(
        Scaffold(
          backgroundColor: Constants.primaryColor,
          body: WillPopScope(
              onWillPop: () async => false,
              child: Container(
                color: Colors.yellow.shade900,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: SpinKitDoubleBounce(
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Please wait...',
                      style: title,
                    ),
                  ],
                ),
              )),
        ),
        barrierDismissible: false);

    try {
      String phoneNumber = "+91" + widget.phone.toString().trim();
      print(phoneNumber);

      /// The below functions are the callbacks, separated so as to make code more redable
      void verificationCompleted(AuthCredential phoneAuthCredential) {
        print('verificationCompleted');
        setState(() {
          _status += 'verificationCompleted\n';
        });
        this._phoneAuthCredential = phoneAuthCredential;
        print(phoneAuthCredential);
      }

      void verificationFailed(AuthException error) {
        print('verificationFailed');
        Fluttertoast.showToast(msg:"There is an error while login. Try again later");
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => PhoneInputScreen()));

        if (Get.isDialogOpen) {
          Get.back();
        }
        print(error.message);
      }

      void codeSent(String verificationId, [int code]) {
        print('codeSent');
        this._verificationId = verificationId;
        print(verificationId);
        this._code = code;
        print(code.toString());
        if (Get.isDialogOpen) {
          Get.back();
        }
        setState(() {
          _status += 'Code Sent\n';
        });
      }

      void codeAutoRetrievalTimeout(String verificationId) {
        print('codeAutoRetrievalTimeout');
        setState(() {
          _status += 'codeAutoRetrievalTimeout\n';
        });
        print(verificationId);
      }

      await FirebaseAuth.instance.verifyPhoneNumber(
        /// Make sure to prefix with your country code
        phoneNumber: phoneNumber,

        /// `seconds` didn't work. The underlying implementation code only reads in `millisenconds`
        timeout: Duration(milliseconds: 10000),

        /// If the SIM (with phoneNumber) is in the current device this function is called.
        /// This function gives `AuthCredential`. Moreover `login` function can be called from this callback
        /// When this function is called there is no need to enter the OTP, you can click on Login button to sigin directly as the device is now verified
        verificationCompleted: verificationCompleted,

        /// Called when the verification is failed
        verificationFailed: verificationFailed,

        /// This is called after the OTP is sent. Gives a `verificationId` and `code`
        codeSent: codeSent,

        /// After automatic code retrival `tmeout` this function is called
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
      ); // All the callbacks are above
    } on PlatformException catch (e) {
      print(e);
      if (Get.isDialogOpen) {
        Get.back();
      }
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => PhoneInputScreen()));
             Fluttertoast.showToast(msg:"There is an error while login. Try again later");

    }
  }

  void _submitOTP() {
    /// get the `smsCode` from the user

    String smsCode = otp;
    try {
      this._phoneAuthCredential = PhoneAuthProvider.getCredential(
          verificationId: this._verificationId, smsCode: smsCode);

      _login();
    } on PlatformException catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
    }
  }
}
