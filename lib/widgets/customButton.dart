import 'package:driver_app/constants.dart';
import 'package:flutter/material.dart';
import 'styles.dart';

class CustomButton extends StatelessWidget {
  final String title;
  final Color color;
  final Function onPressed;
  final bool isIcon;
  final IconData icon;
  const CustomButton({
    Key key,
    this.title,
    this.color,
    this.isIcon,
    this.onPressed,
    @required this.context, this.icon,
  }) : super(key: key);

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    var height = screenSize.height;
    var width = screenSize.width;
    var defaultSize = height * 0.05;
    var defaultPadding = 16;
    return Container(
      width: width,
      child: MaterialButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        color: color ?? Constants.primaryColor,
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "$title",
              style: CustomStyles.cardBoldTextStyle,
            ),
            isIcon == null
                ? Icon(
                    Icons.navigate_next,
                    color: Colors.white,
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}

class CustomLoadingButton extends StatelessWidget {
  const CustomLoadingButton({
    Key key,
    @required this.context,
  }) : super(key: key);

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    var height = screenSize.height;
    var width = screenSize.width;
    var defaultSize = height * 0.05;
    var defaultPadding = 16;
    return Container(
      width: width,
      height: height * 0.07,
      decoration: BoxDecoration(
          color: Constants.primaryColor,
          borderRadius: BorderRadius.circular(5)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(width: width * 0.1),
          CircularProgressIndicator(),
          SizedBox(width: width * 0.20),
          Text(
            'Loading',
            style: CustomStyles.cardBoldTextStyle,
          )
        ],
      ),
    );
  }
}
