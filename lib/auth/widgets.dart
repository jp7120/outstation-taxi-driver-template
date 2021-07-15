import 'package:driver_app/constants.dart';
import 'package:flutter/material.dart';

class PhoneAuthWidgets {
  static Widget getLogo({String logoPath, double height}) => Material(
        type: MaterialType.transparency,
        elevation: 10.0,
        child: Image.asset(logoPath, height: height),
      );
}

class SearchCountryTF extends StatelessWidget {
  final TextEditingController controller;

  const SearchCountryTF({Key key, this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.only(left: 8.0, top: 8.0, bottom: 2.0, right: 8.0),
      child: Card(
        child: TextFormField(
          autofocus: false,
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Search your country',
            contentPadding: const EdgeInsets.only(
                left: 5.0, right: 5.0, top: 10.0, bottom: 10.0),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}

class PhoneNumberField extends StatelessWidget {
  final TextEditingController controller;
  final String prefix;

  final FocusNode focusNode;

  const PhoneNumberField(
      {Key key, this.controller, this.prefix, this.focusNode})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Row(
        children: <Widget>[
          Text("  " + prefix + "  ", style: TextStyle(fontSize: 16.0)),
          SizedBox(width: 8.0),
          Expanded(
            child: TextFormField(
              controller: controller,
              focusNode: focusNode,
              maxLength: 10,
              autofocus: false,
              style: sub,
              onChanged: (v) {
                if (v.length == 10) {
                  focusNode.unfocus();
                }
              },
              keyboardType: TextInputType.phone,
              key: Key('EnterPhone-TextFormField'),
              decoration: InputDecoration(
                border: InputBorder.none,
                counterText: '',
                errorMaxLines: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SubTitle extends StatelessWidget {
  final String text;

  const SubTitle({Key key, this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.centerLeft,
        child: Text(' $text',
            style: sub.copyWith(color: Colors.white, fontSize: 14.0)));
  }
}

class ShowSelectedCountry extends StatelessWidget {
  final VoidCallback onPressed;

  const ShowSelectedCountry({
    Key key,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.only(
              left: 4.0, right: 4.0, top: 8.0, bottom: 8.0),
          child: Row(
            children: <Widget>[Icon(Icons.arrow_drop_down, size: 24.0)],
          ),
        ),
      ),
    );
  }
}
