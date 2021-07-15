import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:driver_app/routes.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatelessWidget {
  static final routeName = "account-settings";

  Widget _buildRowWidget(IconData iconData, String title, String subtitle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Row(
          children: <Widget>[
            Icon(
              iconData,
              color: Constants.primaryColor,
            ),
            SizedBox(
              width: 20,
            ),
            Row(
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: CustomStyles.smallLightTextStyle,
                    ),
                    Text(
                      subtitle,
                      style: CustomStyles.smallTextStyle.copyWith(fontSize: 14),
                      overflow: TextOverflow.clip,
                    )
                  ],
                ),
              ],
            ),
          ],
        ),
        /*  Container(
          margin: EdgeInsets.only(right: 30),
          height: 30,
          width: 75,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              'Change',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ), */
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final mQ = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: <Widget>[
          Container(
            width: mQ.width,
            height: mQ.height,
          ),
          NoLogoHeaderWidget(height: mQ.height * 0.5),
          /* Positioned(
              top: mQ.height * 0.11,
              child: Container(
                height: mQ.height,
                width: mQ.width,
                child: ListView(
                  children: <Widget>[
                    Container(
                      width: 150,
                      height: 150,
                      decoration: new BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: FlutterGradients.zeusMiracle(),
                        boxShadow: [
                          BoxShadow(
                              color: Color(0x29000000),
                              offset: Offset(0, 5),
                              blurRadius: 6,
                              spreadRadius: 0)
                        ],
                      ),
                      child:
                          Center(child: Image.asset('assets/images/logo.png')),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      "${Constants.appName}",
                      textAlign: TextAlign.center,
                      style: CustomStyles.cardBoldDarkTextStyle,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: Text(
                        'We would like to introduce ourselves as one of the most noted call taxi in this field of call taxi service.',
                        style: sub,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 30),
                      child: Text(
                        "About Us",
                        style: CustomStyles.cardBoldDarkTextStyle2,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 30, top: 30),
                      child: Column(
                        children: <Widget>[
                          _buildRowWidget(
                            FontAwesomeIcons.home,
                            "Office Address",
                            "181/A, West Railway Colony, Salem - 636005",
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          InkWell(
                            onTap: () {
                              launch("https://silveronewaytaxi.in");
                            },
                            child: _buildRowWidget(FontAwesomeIcons.phoneAlt,
                                "Website ", "https://silveronewaytaxi.in"),
                          ),
                          SizedBox(height: 40),
                          Card(
                              child: ListTile(
                            onTap: () {
                              Get.defaultDialog(
                                  title: "",
                                  content: Container(
                                      height: Get.height * 0.1,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Text(
                                            'Developed By',
                                            style: sub,
                                          ),
                                          Text(
                                            'The Reciprocal Solutions',
                                            style: title.copyWith(fontSize: 16),
                                          ),
                                        ],
                                      )),
                                  confirm: Container(
                                    width: Get.width * 0.3,
                                    child: CustomButton(
                                      context: context,
                                      color: Colors.blueGrey,
                                      title: "Contact",
                                      onPressed: () {
                                        launch(Uri.encodeFull(
                                            'https://thereciprocalsolutions.com'));
                                      },
                                    ),
                                  ));

                              //
                            },
                            title: Text(
                              "Developer Contact",
                              style: TextStyle(
                                  fontSize: 16.0, fontWeight: FontWeight.w500),
                            ),
                            trailing: Icon(Icons.developer_mode),
                          ))
                          // SizedBox(
                          //   height: 25,
                          // ),
                          // _buildRowWidget(
                          //     Icons.shopping_cart, "Shopping", "Density Mall"),
                        ],
                      ),
                    )
                  ],
                ),
              )), */
          Positioned(
              top: mQ.height * 0.16,
              child: Container(
                height: mQ.height,
                width: mQ.width,
                child: ListView(
                  children: <Widget>[
                    Container(
                      width: 150,
                      height: 150,
                      decoration: new BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: FlutterGradients.zeusMiracle(),
                        boxShadow: [
                          BoxShadow(
                              color: Color(0x29000000),
                              offset: Offset(0, 5),
                              blurRadius: 6,
                              spreadRadius: 0)
                        ],
                      ),
                      child:
                          Center(child: Image.asset('assets/images/logo.png')),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      "${Constants.appName}",
                      textAlign: TextAlign.center,
                      style: CustomStyles.cardBoldDarkTextStyle,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: Text(
                        'We would like to introduce ourselves as one of the most noted call taxi in this field of call taxi service.',
                        style: sub,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 30),
                      child: Text(
                        "Contact Us",
                        style: CustomStyles.cardBoldDarkTextStyle2,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 30, top: 30),
                      child: Column(
                        children: <Widget>[
                          _buildRowWidget(
                            FontAwesomeIcons.home,
                            "Office Address",
                            "181/A, West Railway Colony,\n Salem - 636005",
                          ),
                          SizedBox(
                            height: 25,
                          ),
                          _buildRowWidget(FontAwesomeIcons.phoneAlt,
                              "Phone Number", Constants.companyNumber),
                          // SizedBox(
                          //   height: 25,
                          // ),
                          // _buildRowWidget(
                          //     Icons.shopping_cart, "Shopping", "Density Mall"),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
          Positioned(
            top: 50.0,
            left: 0.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                MaterialButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  color: Colors.white,
                  textColor: Colors.green,
                  child: Icon(
                    Icons.arrow_back,
                    size: 15,
                  ),
                  padding: EdgeInsets.all(6),
                  shape: CircleBorder(),
                ),
                Text(
                  "About Us",
                  style: CustomStyles.cardBoldTextStyle,
                ),
              ],
            ),
          ),
          Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: InkWell(
                onTap: () {
                  Get.defaultDialog(
                      title: "",
                      content: Container(
                          height: Get.height * 0.1,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text(
                                'Developed By',
                                style: sub,
                              ),
                              Text(
                                'The Reciprocal Solutions',
                                style: title.copyWith(fontSize: 16),
                              ),
                            ],
                          )),
                      confirm: Container(
                        width: Get.width * 0.3,
                        child: CustomButton(
                          context: context,
                          color: Colors.blueGrey,
                          title: "Contact",
                          onPressed: () {
                            launch(Uri.encodeFull(
                                'https://thereciprocalsolutions.com'));
                          },
                        ),
                      ));

                  //
                },
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text("Developed by",
                        style: CustomStyles.smallLightTextStyle
                            .copyWith(fontSize: 18)),
                    SizedBox(width: 10),
                    Image.asset(
                      'assets/images/logoo.png',
                      height: 30,
                      width: 30,
                    ),
                  ],
                ),
              ))
        ],
      ),
    );
  }
}
