import 'package:flutter/material.dart';
import 'package:share/share.dart';

import 'package:url_launcher/url_launcher.dart' as UrlLauncher;

import '../routes.dart';

class InviteFriends extends StatefulWidget {
  const InviteFriends({
    Key key,
  }) : super(key: key);

  @override
  _InviteFriendsState createState() => _InviteFriendsState();
}

class _InviteFriendsState extends State<InviteFriends> {
  BasicController basicController = Get.put(BasicController());

  TimeOfDay prev;

  @override
  void initState() {
    super.initState();
  }

  bool isTimerEnded = false;

  openInvite() {
    Share.share(
        "https://play.google.com/store/apps/details?id=com.thereciprocalsolutions.silvertaxidriver",
        subject:
            // "Hola,\nWorried about Outstation taxi service?\nFear not, Silver One Way Taxi provides you the safe and the most economic ride at your very own doorstep.\nSo now, What you got to do to get the service?\nWell, Silver One Way Taxi made it very easy for you.  Download Silver One Way Taxi app by just clicking this link and book your outstation taxi.\nWant to know more about Silver One Way Taxi?\nHit the Website- www.silveronewaytaxi.in",
            "Hello,\nI'm a driver in Silver One Way Taxi.\n I recommend you to attach yourself with Silver One Way Taxi for your wonderful growth.");
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    var height = screenSize.height;
    var width = screenSize.width;
    var defaultSize = height * 0.05;
    var defaultPadding = 16;

    return Scaffold(
        appBar: buildGradientAppBar('Invitation'),
        body: Container(
            height: height,
            width: width,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset('assets/images/invite.jpg',
                      height: 300, width: 300),
                  Text(
                    'Invite a Friend',
                    style: title,
                    textAlign: TextAlign.center,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 58.0, vertical: 20),
                    child: Text(
                      'Share it with your friends and earn some rewards!',
                      style: sub,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Container(
                      width: Get.width * 0.5,
                      child: CustomButton(
                        context: context,
                        color: Colors.redAccent.shade100,
                        title: 'Share',
                        onPressed: () {
                          openInvite();
                        },
                      )),
                  SizedBox(height: defaultSize * 0.5),
                ])));
  }
}
