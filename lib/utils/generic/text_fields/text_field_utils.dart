import 'package:flutter/material.dart';

/// {@category Utils - Generic}
/// A generic utility class related to text fields.
class TextFieldUtils
 {
  //*********************  COUNTERS  *********************//

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

//*********************  CHARS TO BE REMOVED  *********************//

  /// A String for the type of quote to be removed 
  static String quoteChar = '"';

//*********************  STRING SANITIZER BUNDLES AND ERROR MESSAGES *********************//
  /// A StringSanitizerBundle sanitizing straight quotes.
  static 
  ({
    bool shouldStringBeSanitized, 
    dynamic Function(dynamic) sanitizingFunction
  }) 
  containsAStraightQuote(String value) => 
  (
    shouldStringBeSanitized: value.contains(quoteChar), 
    sanitizingFunction: (value) => value.replaceAll(quoteChar, '')
  );

  /// An error message displayed if containsStraightQuote returns true.
  static const String containsAStraightQuoteError = 
  'Straight double quotes\n'
  'are removed from the text typed\n'
  'for CSV-export reasons.\nWith apologies.';

  /// A StringSanitizerBundle sanitizing dots.
  static 
  ({
    bool shouldStringBeSanitized, 
    dynamic Function(dynamic) sanitizingFunction
  }) 
  containsADot(String value) => 
  (
    shouldStringBeSanitized: value.contains('.'), 
    sanitizingFunction: (value) => value.replaceAll('.', '')
  );

  /// An error message displayed if containsADot returns true.
  static const String containsADotError = 
  'Dots are removed,\n'
  'as no extension should be entered\n'
  'in the file name.';
  
}
