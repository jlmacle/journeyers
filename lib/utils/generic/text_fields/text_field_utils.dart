import 'package:flutter/material.dart';
import 'package:journeyers/debug_constants.dart';

import 'package:journeyers/utils/generic/dev/type_defs.dart';
import 'package:journeyers/utils/generic/dev/utility_classes_import.dart';

/// {@category Utils - Generic}
/// A generic utility class related to text fields.
class TextFieldUtils
 {
  // ─── COUNTERS ───────────────────────────────────────

  // https://api.flutter.dev/flutter/material/InputCounterWidgetBuilder.html
  /// A counter displaying no data.
  static Widget? counterAbsent(
    BuildContext context, {
    int? currentLength,
    int? maxLength,
    bool? isFocused,
  }) {
    return null;
  }

  /// A counter displaying "currentLength/maxLength".
  static Widget? counterPresent(
    BuildContext context, {
    int? currentLength,
    int? maxLength,
    bool? isFocused,
  }) {
    return Text('$currentLength/$maxLength');
  }

  // ─── CHARS AND FILE EXTENSIONS ───────────────────────────────────────

  /// An externalization for the type of quote to be removed.
  static const String charQuote = '"';

  /// An externalization for dot.
  static const String charDot = '.';

  /// An externalization for a line return.
  static const String charLR = '\n';

  /// An externalization for ".csv".
  static const String extensionCSV = ".csv";

  /// An externalization for ".txt".
  static const String extentionTXT = ".txt";

  // ─── STRING SANITIZER BUNDLES AND ERROR MESSAGES ───────────────────────────────────────
  /// A [StringSanitizerBundle] sanitizing straight quotes.
  static 
  ({
    bool shouldStringBeSanitized, 
    dynamic Function(dynamic) sanitizingFunction
  }) 
  containsAStraightQuote(String value) => 
  (
    shouldStringBeSanitized: value.contains(charQuote), 
    sanitizingFunction: (value) => value.replaceAll(charQuote, '')
  );

  /// An error message displayed if containsAStraightQuote returns true.
  static const String errorContainsAStraightQuote = 
  'Straight double quotes\n'
  'are removed from the text typed\n'
  'for CSV-export reasons.\nWith apologies.';

  /// A [StringSanitizerBundle] sanitizing dots.
  static 
  ({
    bool shouldStringBeSanitized, 
    dynamic Function(dynamic) sanitizingFunction
  }) 
  containsADot(String value) => 
  (
    shouldStringBeSanitized: value.contains(charDot), 
    sanitizingFunction: (value) => value.replaceAll(charDot, '')
  );

  /// An error message displayed if containsADot returns true.
  static const String errorContainsADot = 
  'Dots are removed,\n'
  'as no extension should be entered\n'
  'in the file name.';

  // ─── BLACKLISTING FUNCTIONS AND ERROR MESSAGES ───────────────────────────────────────
  
  /// Method checking if a file name is already used, assuming knowledge of its extension.
  /// This method assumes a fileExtension parameter with the format ".fileExtension".
  static bool fileNameAlreadyUsed(String value, String fileExtension) 
  {
    List<String> currentListOfStoredFileNames = du.currentListOfStoredFileNames;
    currentListOfStoredFileNames = currentListOfStoredFileNames.where
    (
      (fileName) => fileName.contains(fileExtension)
    ).toList();

    if (textFieldDebugging) pu.printd("Text Field: currentListOfStoredFileNames for extension $fileExtension: $currentListOfStoredFileNames");
    var valueWithExtension = "$value$fileExtension";
    if (textFieldDebugging) pu.printd("Text Field: valueWithExtension: $valueWithExtension");
    return currentListOfStoredFileNames.contains(valueWithExtension);
  }

  /// Method checking if a CSV file name is already used.
  static bool fileNameAlreadyUsedCSV(String value) 
  {
    return fileNameAlreadyUsed(value, extensionCSV);
  }

  /// Method checking if a TXT file name is already used.
  static bool fileNameAlreadyUsedTXT(String value) 
  {
    return fileNameAlreadyUsed(value, extentionTXT);
  }

  /// An error message displayed if a file name is already used.
  static const String errorFileNameAlreadyUsed = 
  'File name not available.\n'
  'Please use a different file name.';

  /// Simple blacklisting function returning true.
  static bool simpleBlacklistingFunction(String value) 
  {
    return true;
  }

  /// An error message displayed for the simple blacklisting function returning true.
  static const String errorTextBlacklisted = "This text is part of a blacklist.";

  // ─── MAP WITH A BLACKLISTING FUNCTION AS KEY, AND AN ERROR MESSAGE AS VALUE (for automated testing) ───────────────────────────────────────
  /// Map with a blacklisting function as key, and an error message as value (for automated testing).
  static const Map<BlacklistingFunction, String> simpleBlacklistingFunctionErrorMapping = 
  {
    TextFieldUtils.simpleBlacklistingFunction : TextFieldUtils.errorTextBlacklisted
  };
}
