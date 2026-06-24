import 'package:flutter/foundation.dart';

/// {@category Utils - Generic}
/// A generic utility class related to printing.
class PrintUtils {

  /// A method used to print debug information.
  void printd(Object object) {
    // "A constant that is true if the application was compiled in debug mode."
    if (kDebugMode) 
    {
      // "As per convention, calls to debugPrint should be within a debug mode check or an assert:"
      debugPrint(
        "Debug: $object",
      ); 
    }
  }

  /// A method used to print a line.
  void printdLine() {
    // "A constant that is true if the application was compiled in debug mode."
    if (kDebugMode) 
    {
      // "As per convention, calls to debugPrint should be within a debug mode check or an assert:"
      debugPrint("___________________________________________________________________________");
   }
  }
}
