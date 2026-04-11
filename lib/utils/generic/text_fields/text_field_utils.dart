import 'package:flutter/material.dart';

import 'package:journeyers/utils/generic/dev/type_defs.dart';

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

  /// A String for the type of quote to be removed 
  static String quoteChar = '"';

  /// A String validator searching for straight quotes.
  static bool containsStraightQuote(String value) => value.contains(quoteChar);

  /// An error message displayed if containsStraightQuote returns true.
  static const String containsStraightQuoteError = 
  'Straight double quotes\n'
  'are removed from the text typed\n'
  'for CSV-export reasons.\nWith apologies.';

  /// A String validator searching for line returns.
  static bool containsLineReturn(String value) => value.contains('\n');

  /// A map with functions as keys, and error messages as values.
  /// The functions return true on a valid input,
  /// and false on an invalid input.
  static const Map<StringValidator, String> quoteAndLineReturnValidatorsErrorsMap = 
  {
    containsStraightQuote : containsStraightQuoteError
  };
}
