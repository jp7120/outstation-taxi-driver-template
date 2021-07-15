import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver_app/model/paymentDetails.dart';
import 'package:driver_app/routes.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PaymentHistory extends StatefulWidget {
  @override
  _PaymentHistoryState createState() => _PaymentHistoryState();
}

class _PaymentHistoryState extends State<PaymentHistory> {
  BasicController basicController = Get.put(BasicController());

  List<Payment> list = [];

  @override
  void initState() {
    super.initState();
    getPaymentData();
  }

  getPaymentData() {
    var driver = basicController.getDriver();

    Firestore.instance
        .collection('payments')
        .where('driverUID', isEqualTo: driver.uid)
        .orderBy('timestamp', descending: true)
        .getDocuments()
        .then((value) {
      // print(value.documents[0].data.toString());
      value.documents.forEach((element) {
        var pay = Payment.fromJson(element.data);
        print(pay.toJson());
        setState(() {
          // for (int i = 3; i < 100; i++)
          list.add(pay);
        });
      });

      print(list.length.toString());
    });

    //
  }

//BEFORE:
// Implementing the android 11 Query package thing
// revert to this if something went wrong

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    var height = screenSize.height;
    var width = screenSize.width;
    var defaultSize = height * 0.05;
    var defaultPadding = 16;
    // list.add(Payment(timestamp: Timestamp(10230122, 12312312)));
    return Scaffold(
      appBar: buildAppBar('Payment history'),
      body: SafeArea(
        child: list.length != 0
            ? Column(
                children: [
                  // Text(
                  //   'List of all payment you have made',
                  //   style: title,
                  // ),
                  // SizedBox(height: defaultSize),
                  Container(
                    height: Get.height * 0.87,
                    width: Get.width,
                    child: ListView(
                      children: [
                        DataTable(
                            dividerThickness: 2,
                            headingRowHeight: 80,
                            dataRowHeight: 80,
                            showBottomBorder: true,
                            headingTextStyle: title.copyWith(fontSize: 16),
                            dataTextStyle: sub.copyWith(fontSize: 13),
                            headingRowColor: MaterialStateColor.resolveWith(
                                (states) => Colors.amberAccent),
                            columnSpacing: 30,
                            columns: const <DataColumn>[
                              DataColumn(
                                label: Text(
                                  'Amount',
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Reason',
                                ),
                              ),
                              DataColumn(
                                  label: Center(
                                child: Text(
                                  'Date',
                                  textAlign: TextAlign.center,
                                ),
                              )),
                            ],
                            rows: list.map((e) {
                              DateTime date =
                                  DateTime.fromMillisecondsSinceEpoch(
                                      e.timestamp.seconds * 1000);
                              print(date);

                              return DataRow(
                                cells: <DataCell>[
                                  DataCell(Container(
                                    width: 80,
                                    child: Text(
                                      '${formatPrice(double.parse(e.amountAdded))}',
                                      style: title.copyWith(
                                          color: e.status
                                                      .trim()
                                                      .toLowerCase()
                                                      .replaceAll(" ", "") ==
                                                  'ridecommission'
                                              ? Colors.red.shade800
                                              : Colors.green,
                                          fontSize: 16),
                                      textAlign: TextAlign.center,
                                    ),
                                  )),
                                  DataCell(Text(
                                    '${e.status == 'success' ? 'Wallet Recharge' : e.status}',
                                    style: TextStyle(letterSpacing: 1),
                                  )),
                                  DataCell(Text(
                                    '${date.toString().substring(0, 10)}',
                                    textAlign: TextAlign.center,
                                  )),
                                ],
                              );
                            }).toList()),
                      ],
                    ),
                  )
                ],
              )
            : Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Looks like you haven\'t added money to wallet!',
                      style: title,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: defaultSize),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AddMoneyScreen()));
                      },
                      child: Container(
                        height: height * 0.05,
                        width: width * 0.5,
                        decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10.0)),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Icon(
                                FontAwesomeIcons.plusCircle,
                                size: 20,
                                color: Colors.white,
                              ),
                              SizedBox(
                                width: width * 0.058,
                              ),
                              Text(
                                "Add Money",
                                style: title.copyWith(
                                    color: Colors.white, fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
      ),
    );
  }
}
