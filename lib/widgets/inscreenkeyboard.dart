import 'package:flutter/material.dart';

class InScreenNumberKeyword extends StatelessWidget {
  final _pinPutFocusNode = FocusNode();
  final _pageController = PageController();

  InScreenNumberKeyword({
    Key key,
    @required TextEditingController pinPutController,
  })  : _pinPutController = pinPutController,
        super(key: key);

  final TextEditingController _pinPutController;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      padding: const EdgeInsets.all(30),
      physics: NeverScrollableScrollPhysics(),
      children: [
        ...[1, 2, 3, 4, 5, 6, 7, 8, 9, 0].map((e) {
          return RoundedButton(
            title: '$e',
            onTap: () {
              _pinPutController.text = '${_pinPutController.text}$e';
            },
          );
        }),
        RoundedButton(
          title: '<-',
          onTap: () {
            if (_pinPutController.text.isNotEmpty) {
              _pinPutController.text = _pinPutController.text
                  .substring(0, _pinPutController.text.length - 1);
            }
          },
        ),
      ],
    );
  }
}

class RoundedButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  RoundedButton({this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color.fromRGBO(25, 21, 99, 1),
        ),
        alignment: Alignment.center,
        child: Text(
          '$title',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }
}
