import 'package:flutter/material.dart';

/// {@category Utils - Generic}
/// A generic utility class related to text fields.
class TextFieldUtils
 {
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

  /// A counter displaying "currentLength/maxLength".
  static Widget? presentCounter(
    BuildContext context, {
    int? currentLength,
    int? maxLength,
    bool? isFocused,
  }) {
    return Text('$currentLength/$maxLength');
  }
}
