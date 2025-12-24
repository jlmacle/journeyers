import 'package:flutter/material.dart';

class FormUtils
{
  /// A util used to label checkbox data.
  static String checkbox = "checkbox";
  /// A util used to label text field data.
  static String textField = "textField";
  /// A util used to label segmented button data.
  static String segmentedButton = "segmentedButton";

  /// A number of characters used to represent 10 lines of text field input on a computer.
  static const int chars10Lines = 1560;
  /// A number of characters used to represent 1 page of text field input on a computer.
  static const int chars1Page = 7330;

  // https://api.flutter.dev/flutter/material/InputCounterWidgetBuilder.html
  /// A counter displaying no data.
  static Widget? absentCounter(
    BuildContext context, {
    int? currentLength,
    int? maxLength,
    bool? isFocused,
  }) {
    return null;
  }

  // A counter displaying "currentLength/maxLength"
  static Widget? presentCounter(
    BuildContext context, {
    int? currentLength,
    int? maxLength,
    bool? isFocused,
  }) {
    return Text('$currentLength/$maxLength');
  }
}