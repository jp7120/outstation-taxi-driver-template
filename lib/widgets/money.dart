import 'package:intl/intl.dart';
import 'dart:math';
import 'package:flutter/material.dart';

formatPrice(double money) {
  var moneyFormat = NumberFormat.simpleCurrency(locale: 'en_IN');

  var value = money;

  var formated = moneyFormat.format(value).replaceFirst(RegExp(r"\.[^]*"), "");

  // print(formated);

  return formated;
}
