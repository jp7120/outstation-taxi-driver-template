import 'dart:convert';

import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:upi_india/upi_india.dart';
import 'package:url_launcher/url_launcher.dart' as url;

import 'package:driver_app/model/driverDetail.dart';
import 'package:driver_app/routes.dart';

class AddMoneyScreen extends StatefulWidget {
  @override
  _AddMoneyScreenState createState() => _AddMoneyScreenState();
}

class _AddMoneyScreenState extends State<AddMoneyScreen> {
  Future<UpiResponse> _transaction;
  UpiIndia _upiIndia = UpiIndia();
  List<UpiApp> apps;

  TextEditingController amount = TextEditingController(text: '');

  TextStyle header = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  TextStyle value = TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 14,
  );

  FirebaseUser currentuser;

  BasicController basicController;

  static const platform =
      const MethodChannel('com.thereciprocalsolutions.silvertaxidriver');

  @override
  void initState() {
    basicController = Get.put(BasicController());

    getUser();

    super.initState();
  }

  DriverDetails driver;

  bool isLoading = false;
  bool isSuccess = false;
  bool isCompleted = false;

  UpiResponse _upiResponse;

  String errorMsg = 'No error';
  String upiApp = '';

  getUser() async {
    var user = basicController.getCurrentUser();
    var d = basicController.getDriver();
    setState(() {
      currentuser = user;
      driver = d;
    });
    if (currentuser != null) print(currentuser.phoneNumber);
  }

  var dateId;

  updatePaymentDetails() async {
    var formatedDate = formatDate(DateTime.now());

    if (status == UpiPaymentStatus.FAILURE) {
      // Fluttertoast.showToast(msg: "Failed...");
      print('failed');
    } else {
      Payment payment = Payment(
          amountAdded: money.toString(),
          createdAt: formatedDate,
          timestamp: DateTime.now(),
          driverName: driver.name,
          driverPhone: driver.phoneNum,
          driverUid: driver.uid,
          paymentId: dateId,
          upiTransId: approvalRef,
          paymentThru: '$upiApp',
          prevBalance: driver.amount.toString(),
          status: "Wallet Recharge",
          errorMsg: errorMsg,
          totalAmount: (money + driver.amount).toString(),
          transactionRefId: txnRef,
          transactionReference: txnId);

      ///? MAKE THIS AS A TRANSACTION
      ///we need to update the amount in the driver collection `amount` field
      ///once this is successfull

      await Firestore.instance
          .collection('payments')
          .document(dateId)
          .setData(payment.toJson())
          .then((value) async {
        Fluttertoast.showToast(msg: "Success data stored");
        await Firestore.instance
            .collection(Constants.driverCollection)
            .document(driver.uid)
            .updateData({
          'amount': FieldValue.increment(money),
        }).then((value) {
          print("Amount updated");
        });
        await Firestore.instance
            .collection("AdminDetails")
            .document('allDetails')
            .updateData({
          'totalDriversAmountRecharged': FieldValue.increment(money),
          'totalTransactions': FieldValue.increment(1)
        });
      });
    }
  }

  Future<void> initiateTransaction(String app) async {
    try {
      setState(() {
        isLoading = true;
        upiApp = app;
      });
      // money = 1.0;
      var result = await platform.invokeMethod('startTransaction', {
        "app": app,
        'driver': '${currentuser.phoneNumber}',
        'receiverUpiId': "8885777222@okbizaxis",
        // 'receiverUpiId': "sundararajalamelu-1@oksbi",
        'receiverName': "SILVER TAXI",
        'transactionRefId': "BCR2DN6T36K6XTS3",
        'transactionNote':
            "Wallet Recharge for ${driver.name}-${driver.phoneNum}",
        'amount': money.toString(),
        // 'currency': currency,
        'merchantId': '4121',
      }) /* .then((response) {
        print("IN SUCCESS RESPONSE UPI_INDIA_FINAL_RESPONSE: $response");
        return UpiResponse(response);
      }).catchError((e) {
        print("IN ERROR UPI_INDIA_FINAL_RESPONSE: invalid_parameters");
        return UpiResponse('invalid_parameters');
      }) */
          ;
      var json = jsonDecode(result);
      var date = DateTime.now().toIso8601String();

      print("Result " + result.toString());
      setState(() {
        isLoading = false;
        dateId = DateTime.now().millisecondsSinceEpoch.toString();
        isCompleted = true;
        isSuccess = true;
        _upiResponse = UpiResponse(result.toString());
        if (result != null) {
          txnId = json["transactionId"] ?? 'N/A';
          resCode = json["responseCode"] ?? 'N/A';
          txnRef = json["transactionRefId"] ?? 'N/A';

          if (json["status"].toLowerCase() == "success")
            status = "success";
          else if (json["status"].toLowerCase().contains("fail"))
            status = "failure";
          else if (json["status"].toLowerCase().contains("submit"))
            status = "submitted";
          else
            status = "other";

          // status = json["status"] ?? 'N/A';
          approvalRef = json["approvalRefNo"] == null
              ? dateId.toString()
              : json["approvalRefNo"];
          _checkTxnStatus(status);
        }
      });
      print(json);

      print("Result status " + status.toString());

      updatePaymentDetails();
    } on PlatformException catch (e) {
      print(e);
      Map<String, dynamic> js = {
        "appName": "com.phonepe.app",
        "responseCode": "00",
        "status": "Success",
        "transactionId": "YBLe45f4292cd4d42bfb709648d55d71e51",
        "transactionRefId": "BCR2DN6T36K6XTS3"
      };
      setState(() {
        dateId = DateTime.now().millisecondsSinceEpoch.toString();
        isLoading = false;
        errorMsg = e.message.toString();
        status = 'failure';

        // if (status.toLowerCase().contains("fail")) status = "failure";

        isCompleted = true;
      });
      print(js['']);
      _checkTxnStatus(status);

      updatePaymentDetails();
    }

    /*   return _upiIndia.startTransaction(
        app: UpiApp.PayTM,
        receiverUpiId: "8885777222@okbizaxis",
        receiverName: 'SILVER TAXI',
        transactionRefId: 'BCR2DN6T36K6XTS3',
        transactionNote: 'WALLET RECHARGE BY DRIVER RAMESH ',
        merchantId: '4121',
        amount: double.parse('1')); */
  }

  double money = 500.0;
  bool isEntered = false;

  int currentIndex = 0;

  buildNewAddMoneyPage() {
    Size screenSize = MediaQuery.of(context).size;
    var height = screenSize.height;
    var width = screenSize.width;
    var defaultSize = height * 0.05;
    var defaultPadding = 16;
    return isLoading
        ? Center(
            child: CircularProgressIndicator(),
          )
        : Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: height * 0.3,
                  width: width,
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      // color: Colors.cyan,
                      gradient: FlutterGradients.northMiracle(),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(spreadRadius: -20, blurRadius: 30)
                      ]),
                  child: Row(
                    children: [
                      Expanded(
                          flex: 2,
                          child: Image.asset('assets/images/logo.png')),
                      Expanded(
                        flex: 3,
                        child: Text(
                          'Silver One Way Taxi Partner',
                          style: title.copyWith(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: defaultSize),
              Text(
                'Please choose the amount to recharge!',
                style: title,
                textAlign: TextAlign.center,
              ),
              Container(
                height: height * 0.13,
                width: width,
                padding: EdgeInsets.all(10.0),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: BouncingScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (c, i) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          currentIndex = i;
                          money = (i + 1).toDouble() * 500;
                        });
                        print(money);
                      },
                      child: Transform.scale(
                        scale: currentIndex == i ? 1.05 : 1.0,
                        child: AnimatedContainer(
                          curve: Curves.easeInCubic,
                          duration: Duration(milliseconds: 100),
                          padding: EdgeInsets.all(5.0),
                          margin:
                              EdgeInsets.symmetric(vertical: 20, horizontal: 5),
                          height: height * 0.13,
                          width: width * 0.25,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: currentIndex != i
                                  ? Colors.white
                                  : Colors.redAccent.shade200,
                              boxShadow: [
                                BoxShadow(spreadRadius: -20, blurRadius: 30)
                              ]),
                          child: Center(
                              child: Text(
                            '${formatPrice((i + 1).toDouble() * 500)}',
                            style: title.copyWith(
                                fontSize: 14,
                                color: currentIndex == i
                                    ? Colors.white
                                    : Colors.red),
                          )),
                        ),
                      ),
                    );
                  },
                  itemCount: 10,
                ),
              ),
              RichText(
                  text: TextSpan(children: [
                TextSpan(
                  text: 'Add ',
                  style: title.copyWith(fontSize: 20),
                ),
                TextSpan(
                  text: ' ${formatPrice(money)} ',
                  style: title.copyWith(fontSize: 25, color: Colors.redAccent),
                ),
                TextSpan(
                  text: 'to Wallet',
                  style: title.copyWith(fontSize: 20),
                ),
              ])),
              SizedBox(height: defaultSize),
              buildAnimatedButton(FontAwesomeIcons.ccAmazonPay, 'PhonePe',
                  Colors.purple.shade800, () {
                initiateTransaction('phonepe');
              }),
              SizedBox(height: defaultSize * 0.5),
              buildAnimatedButton(FontAwesomeIcons.paypal, 'PayTM',
                  Colors.lightBlueAccent.shade700, () {
                initiateTransaction('paytm');
              })
            ],
          );
  }

  BouncingWidget buildAnimatedButton(
    IconData icon,
    String btnText,
    Color btnColor,
    Function onPressed,
  ) {
    Size screenSize = MediaQuery.of(context).size;
    var height = screenSize.height;
    var width = screenSize.width;
    var defaultSize = height * 0.05;
    var defaultPadding = 16;
    return BouncingWidget(
      duration: Duration(milliseconds: 200),
      scaleFactor: 1.5,
      onPressed: onPressed,
      child: Container(
        width: width * 0.7,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: btnColor == null ? Colors.black87 : btnColor,
            boxShadow: [BoxShadow(spreadRadius: -20, blurRadius: 30)]),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon(icon, color: Colors.white),
              // SizedBox(width: defaultSize * 1),
              Center(
                child: Text(
                  "$btnText",
                  textAlign: TextAlign.center,
                  style: title.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget displayUpiApps() {
    if (apps == null)
      return Center(child: CircularProgressIndicator());
    else if (apps.length == 0)
      return buildNewAddMoneyPage();
    else {
      return buildOldAddMoney();
    }
  }

  SingleChildScrollView buildOldAddMoney() {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          !isEntered
              ? Container(
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                  child: Column(
                    children: <Widget>[
                      Container(
                        height: Get.height * 0.3,
                        width: Get.width * 0.8,
                        padding: EdgeInsets.fromLTRB(30, 10, 10, 10),
                        margin: EdgeInsets.fromLTRB(30, 10, 10, 10),
                        child: Image.network(
                            "https://i.pinimg.com/originals/c0/a5/06/c0a5066b3f25f9c33a493cb32b6c00f7.png"),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Please enter the amount to recharge your account wallet!',
                          textAlign: TextAlign.center,
                          style: title.copyWith(fontSize: 13),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          controller: amount,
                          decoration: InputDecoration(
                              labelText: 'Enter amount',
                              labelStyle: sub,
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              )),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: CustomButton(
                          color: Constants.primaryDark,
                          title: 'Recharge',
                          onPressed: () {
                            setState(() {
                              isEntered = true;
                            });
                            /*  Fluttertoast.showToast(
                                msg:
                                    'Amount you have entered is ${amount.text.length <= 0 ? '0' : amount.text} but for testing the amount is 1 rs',
                                toastLength: Toast.LENGTH_LONG); */
                          },
                          context: context,
                        ),
                      ),
                    ],
                  ),
                )
              : Container(),
          isEntered
              ? Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Text(
                        'Please choose your preffered payment method!',
                        textAlign: TextAlign.center,
                        style: title,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        setState(() {
                          isEntered = false;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.all(40),
                        margin: EdgeInsets.all(40),
                        // color: Colors.black,
                        decoration: BoxDecoration(
                            gradient: FlutterGradients.sunVeggie(),
                            borderRadius: BorderRadius.circular(60)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(Icons.edit),
                            SizedBox(width: 20),
                            Column(
                              children: <Widget>[
                                Text(
                                  amount.text != null
                                      ? formatPrice(
                                          double.parse(amount.text),
                                        )
                                      : '0',
                                  style: title.copyWith(
                                      fontSize: 30,
                                      color: Colors.teal.shade600),
                                ),
                                Text(
                                  'Edit Amount',
                                  style: sub,
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topCenter,
                      child: SingleChildScrollView(
                        physics: BouncingScrollPhysics(),
                        child: Wrap(
                          children: apps.map<Widget>((UpiApp app) {
                            return GestureDetector(
                              onTap: () {
                                // print(app.app.toString());
                                // _transaction =
                                //     initiateTransaction(app.app.toString());

                                setState(() {});
                              },
                              child: Container(
                                height: 100,
                                width: 100,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Image.memory(
                                      app.icon,
                                      height: 60,
                                      width: 60,
                                    ),
                                    Text(app.name),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                )
              : Container(),
        ],
      ),
    );
  }

  /* String _upiErrorHandler(error) {
    switch (error) {
      case UpiIndiaAppNotInstalledException:
        return 'Requested app not installed on device';
      case UpiIndiaUserCancelledException:
        return 'You cancelled the transaction';
      case UpiIndiaNullResponseException:
        return 'Requested app didn\'t return any response';
      case UpiIndiaInvalidParametersException:
        return 'Requested app cannot handle the transaction';
      default:
        return 'An Unknown error has occurred';
    }
  } */

  void _checkTxnStatus(String status) {
    switch (status) {
      case UpiPaymentStatus.SUCCESS:
        print('Transaction Successful');
        break;
      case UpiPaymentStatus.SUBMITTED:
        print('Transaction Submitted');
        break;
      case UpiPaymentStatus.FAILURE:
        print('Transaction Failed');
        break;
      default:
        print('Received an Unknown transaction status');
    }
  }

  String txnId = '';
  String resCode = '';
  String txnRef = '';
  String status = '';
  String approvalRef = '';
  double amountAdded = 0.0;

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    var height = screenSize.height;
    var width = screenSize.width;
    var defaultSize = height * 0.05;
    var defaultPadding = 16;
    // showSuccessMessage();
    // isCompleted = true;

    return Scaffold(
      appBar: buildAppBar('Add money'),
      /* floatingActionButton: FloatingActionButton(
        onPressed: () {
          getPaymentData();
        },
      ), */
      resizeToAvoidBottomInset: true,
      body: isCompleted
          ? Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  status == UpiPaymentStatus.SUCCESS && _upiResponse != null
                      ? Padding(
                          padding: const EdgeInsets.all(28.0),
                          child: Container(
                              color: Colors.greenAccent.shade100,
                              height: height * 0.75,
                              padding: EdgeInsets.only(top: 30.0),
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Center(
                                        child: Icon(
                                      Icons.check_circle,
                                      size: 60,
                                    )),
                                    SizedBox(height: defaultSize * 0.5),
                                    Center(
                                      child: Text(
                                        'Payment Success',
                                        style: title,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    SizedBox(height: defaultSize * 0.5),
                                    Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(18.0),
                                        child: Text(
                                          '${formatPrice(money)} added to your wallet',
                                          style: sub.copyWith(
                                            fontSize: 16,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: defaultSize * 0.2),
                                    Padding(
                                      padding: const EdgeInsets.all(18.0),
                                      child: Text(
                                        'Payment Info:',
                                        style: sub.copyWith(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.start,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(18.0),
                                      child: Text(
                                        'Transaction ID : $dateId',
                                        style: sub.copyWith(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.start,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(18.0),
                                      child: Text(
                                        'Payment Reference : \n${_upiResponse != null ? txnId : 'processing'}',
                                        style: sub.copyWith(fontSize: 13),
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.start,
                                        maxLines: 2,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 18.0, top: 10),
                                      child: Text(
                                        'Created At : ${DateTime.now().toString().substring(0, 16)}',
                                        maxLines: 1,
                                        style: sub.copyWith(fontSize: 13),
                                        textAlign: TextAlign.start,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(18.0),
                                      child: CustomButton(
                                          context: context,
                                          title: 'Contact Support',
                                          onPressed: () {
                                            url.launch(Constants.whatsappUrl);
                                          },
                                          color: Constants.primaryDark),
                                    )
                                  ])))
                      : Padding(
                          padding: const EdgeInsets.all(28.0),
                          child: Container(
                            color: Colors.redAccent.shade100,
                            height: height * 0.45,
                            padding: EdgeInsets.all(2.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SizedBox(width: defaultSize * 0.5),
                                    Icon(Icons.error),
                                    SizedBox(width: defaultSize * 0.5),
                                    Expanded(
                                      child: Text(
                                        '$errorMsg'.capitalize,
                                        style: title,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    '1.  Restart the app if it doesn\'t work.',
                                    style: sub,
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    '2.  Kindly try it back some time.',
                                    style: sub,
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    '3.  Still not working? Contact Us',
                                    style: sub,
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(18.0),
                                  child: CustomButton(
                                      context: context,
                                      title: 'Contact Support',
                                      onPressed: () {
                                        url.launch(Constants.whatsappUrl);
                                      },
                                      color: Constants.primaryDark),
                                ),
                              ],
                            ),
                            // decoration: BoxDecoration(
                            //     gradient: FlutterGradients.sunVeggie(),
                            //     borderRadius: BorderRadius.circular(20)),
                          ),
                        )
                ],
              ),
            )
          : buildNewAddMoneyPage(),
    );
  }
}
