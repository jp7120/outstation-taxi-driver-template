import 'package:driver_app/auth/login.dart';
import 'package:driver_app/routes.dart';
import 'package:driver_app/screens/futureRides.dart';
import 'package:driver_app/screens/invite.dart';
import 'package:driver_app/screens/myRides.dart';
import 'package:driver_app/screens/payments.dart';
import 'package:driver_app/screens/profile.dart';
import 'package:driver_app/screens/support_page.dart';
import 'package:google_fonts/google_fonts.dart';

class DrawerWidget extends StatelessWidget {
  BasicController controller = BasicController();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          Container(
            height: Get.height * 0.2,
            decoration: BoxDecoration(
                gradient: FlutterGradients.summerGames(
                    tileMode: TileMode.clamp,
                    radius: 40,
                    startAngle: 40,
                    endAngle: 80,
                    center: Alignment.bottomLeft)),
            child: Center(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 30,
                  backgroundImage: AssetImage('assets/images/logo.png'),
                ),
                title: Text(
                  "Welcome to".toUpperCase(),
                  style: GoogleFonts.montserrat(
                      fontSize: 12, fontWeight: FontWeight.w400),
                ),
                subtitle: Text(
                  'Silver Taxi',
                  style: CustomStyles.cardBoldDarkDrawerTextStyle,
                ),
              ),
            ),
          ),
          Divider(),
          Padding(
            padding: const EdgeInsets.only(left: 10, top: 5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                InkWell(
                  splashColor: Colors.blue,
                  highlightColor: Colors.blue,
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ProfileScreen()));
                  },
                  child: ListTile(
                    leading: Icon(Icons.person),
                    title: Text(
                      "Profile",
                      style: CustomStyles.cardBoldDarkTextStyle,
                    ),
                  ),
                ),
                InkWell(
                  splashColor: Colors.blue,
                  highlightColor: Colors.blue,
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PaymentHistory()));
                  },
                  child: ListTile(
                    leading: Icon(Icons.payments_outlined),
                    title: Text(
                      "Payments",
                      style: CustomStyles.cardBoldDarkTextStyle,
                    ),
                  ),
                ),
                InkWell(
                  splashColor: Colors.blue,
                  highlightColor: Colors.blue,
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => FutureRidesNew()));
                  },
                  child: ListTile(
                    leading: Icon(Icons.fiber_new),
                    title: Text(
                      "Future Rides",
                      style: CustomStyles.cardBoldDarkTextStyle,
                    ),
                  ),
                ),
                InkWell(
                  splashColor: Colors.blue,
                  highlightColor: Colors.blue,
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => MyRides()));
                  },
                  child: ListTile(
                    leading: Icon(Icons.history),
                    title: Text(
                      "My Rides",
                      style: CustomStyles.cardBoldDarkTextStyle,
                    ),
                  ),
                ),
                /* InkWell(
                  onTap: () {
                    /*  Share.share(
                      "https://github.com/Dennis247/green_taxi",
                      subject: "Invite Your Friend To TRS Taxi",
                    ); */
                  },
                  child: ListTile(
                    leading: Icon(Icons.person_add_alt_1_outlined),
                    title: Text(
                      "Invite",
                      style: CustomStyles.cardBoldDarkTextStyle,
                    ),
                  ),
                ), */
                /*    InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => GeoLocationQuery()));
                  },
                  child: ListTile(
                    leading: Icon(Icons.offline_bolt_rounded),
                    title: Text(
                      "Radius",
                      style: CustomStyles.cardBoldDarkTextStyle,
                    ),
                  ),
                ), */

                /* InkWell(
                  focusColor: Colors.black,
                  enableFeedback: true,
                  splashColor: Colors.blue,
                  highlightColor: Colors.blue,
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => VerticalExample()));
                  },
                  child: ListTile(
                    leading: Icon(Icons.location_on_outlined),
                    title: Text(
                      "Track your order",
                      style: CustomStyles.cardBoldDarkTextStyle,
                    ),
                  ),
                ), */
                InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => InviteFriends()));
                  },
                  child: ListTile(
                    leading: Icon(Icons.person_add_alt_1_outlined),
                    title: Text(
                      "Invite",
                      style: CustomStyles.cardBoldDarkTextStyle,
                    ),
                  ),
                ),
                InkWell(
                  splashColor: Colors.blue,
                  highlightColor: Colors.blue,
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => SupportPage()));
                  },
                  child: ListTile(
                    leading: Icon(Icons.contact_support_rounded),
                    title: Text(
                      "Support",
                      style: CustomStyles.cardBoldDarkTextStyle,
                    ),
                  ),
                ),
                InkWell(
                  splashColor: Colors.blue,
                  highlightColor: Colors.blue,
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SettingsPage()));
                  },
                  child: ListTile(
                    leading: Icon(Icons.card_giftcard_outlined),
                    title: Text(
                      "About",
                      style: CustomStyles.cardBoldDarkTextStyle,
                    ),
                  ),
                ),
                InkWell(
                  splashColor: Colors.blue,
                  highlightColor: Colors.blue,
                  onTap: () {
                    // AuthService().signOutUser(context);
                    showLogoutButton(context);
                  },
                  child: ListTile(
                    leading: Icon(Icons.logout),
                    title: Text(
                      "Log Out",
                      style: CustomStyles.cardBoldDarkTextStyle,
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  showLogoutButton(var context) async {
    await showDialog(
        context: context,
        builder: (c) {
          return AlertDialog(
            backgroundColor: Colors.red,
            title: new Text(
              "Logout?",
              style: title.copyWith(color: Colors.black),
              textAlign: TextAlign.center,
            ),
            content: new Container(
                // color: Colors.black,
                height: Get.height * 0.1,
                width: Get.width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Center(
                      child: Container(
                          child: Text(
                        'Are you sure you want to logout from this app?',
                        textAlign: TextAlign.center,
                        style: sub.copyWith(
                          color: Colors.white,
                        ),
                      )),
                    )
                  ],
                )),
            actions: <Widget>[
              FlatButton(
                // color: Colors.blue,
                child: Text(
                  'Yes'.toUpperCase(),
                  style: title.copyWith(color: Colors.white),
                ),
                onPressed: () {
                  FirebaseAuth.instance.signOut().then((value) {
                    if (Navigator.canPop(c)) {
                      Navigator.pop(c);
                    }
                    Fluttertoast.showToast(msg: "Signing out");
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (c) => PhoneInputScreen()),
                        (route) => false);
                  });
                },
              ),
              FlatButton(
                // color: Colors.white,
                child: Text(
                  'No'.toUpperCase(),
                  style: title.copyWith(color: Colors.white),
                ),
                onPressed: () {
                  if (Navigator.canPop(c)) {
                    Navigator.pop(c);
                  }
                },
              )
            ],
          );
        });
  }
}
