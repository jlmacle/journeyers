import 'package:flutter/material.dart';

String checkbox = "checkbox";
String textField = "textField";
String segmentedButton = "segmentedButton";

const int chars10Lines = 1560;

const int chars1Page = 7330;

// https://api.flutter.dev/flutter/material/InputCounterWidgetBuilder.html
Widget? absentCounter(
  BuildContext context, {
  int? currentLength,
  int? maxLength,
  bool? isFocused,
}) {
  return null;
}


Widget? presentCounter(
  BuildContext context, {
  int? currentLength,
  int? maxLength,
  bool? isFocused,
}) {
  return Text('$currentLength/$maxLength');
}
