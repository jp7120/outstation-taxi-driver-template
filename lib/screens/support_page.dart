import 'package:driver_app/routes.dart';
import 'package:driver_app/widgets/styles.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:url_launcher/url_launcher.dart' as url;
import 'package:url_launcher/url_launcher.dart';

class SupportPage extends StatelessWidget {
  static final routeName = "support";

  _buildRowWidgets(
      IconData iconData, String title, String subtitle, String urls) {
    return InkWell(
      onTap: () {
        url.launch(urls);
      },
      child: Row(
        children: <Widget>[
          Icon(
            iconData,
            color: Constants.primaryColor,
          ),
          SizedBox(
            width: 20,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w300,
                ),
              ),
              new Text(subtitle, style: CustomStyles.smallTextStyle)
            ],
          ),
        ],
      ),
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
          Positioned(
              top: mQ.height * 0.18,
              child: Container(
                height: Get.height * 0.9,
                width: mQ.width,
                child: ListView(
                  children: <Widget>[
                    new Container(
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
                      "Contact Us!",
                      textAlign: TextAlign.center,
                      style: CustomStyles.cardBoldDarkTextStyle,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 30, top: 30),
                      child: Column(
                        children: <Widget>[
                          _buildRowWidgets(
                              FontAwesomeIcons.phoneAlt,
                              "Phone Number",
                              "${Constants.companyNumber}",
                              "tel:/${Constants.companyNumber}"),
                          SizedBox(
                            height: 25,
                          ),
                          _buildRowWidgets(
                              FontAwesomeIcons.whatsapp,
                              "WhatsApp",
                              "Chat with us on whatsapp!",
                              Constants.whatsappUrl),
                          SizedBox(
                            height: 25,
                          ),
                          _buildRowWidgets(
                              Icons.mail,
                              "Email",
                              "silveronewaytaxi@gmail.com",
                              "mailto:silveronewaytaxi@gmail.com"),
                          SizedBox(
                            height: 25,
                          ),
                          _buildRowWidgets(FontAwesomeIcons.weebly, "Website",
                              Constants.companyWeb, Constants.companyWeb),
                          SizedBox(
                            height: 15,
                          ),
                          _buildRowWidgets(
                              FontAwesomeIcons.weebly,
                              "Website",
                              "http://silvercalltaxi.in/",
                              "http://silvercalltaxi.in/"),
                          SizedBox(
                            height: 15,
                          ),
                          _buildRowWidgets(
                              FontAwesomeIcons.weebly,
                              "Website",
                              "https://silvertaxi.in/",
                              "https://silvertaxi.in/"),
                          SizedBox(
                            height: 25,
                          ),
                          /*  Card(
                              margin: EdgeInsets.only(right: 30),
                              child: ListTile(
                                onTap: () {
                                  Get.defaultDialog(
                                      title: "",
                                      content: Container(
                                          height: Get.height * 0.1,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              Text(
                                                'Developed By',
                                                style: sub,
                                              ),
                                              Text(
                                                'The Reciprocal Solutions',
                                                style: title.copyWith(
                                                    fontSize: 16),
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
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w500),
                                ),
                                trailing: Icon(Icons.developer_mode),
                              )) */
                        ],
                      ),
                    )
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
                  "Call Center",
                  style: CustomStyles.cardBoldTextStyle,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
