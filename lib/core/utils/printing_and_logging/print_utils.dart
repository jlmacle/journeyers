import 'package:flutter/foundation.dart';

/// {@category Utils}
/// A utility class related to printing.
class PrintUtils {
  /// A method used to print debug information.
  void printd(dynamic object) {
    // "A constant that is true if the application was compiled in debug mode."
    if (kDebugMode) //https://api.flutter.dev/flutter/foundation/kDebugMode-constant.html
    {
      // "As per convention, calls to debugPrint should be within a debug mode check or an assert:"
      debugPrint(
        "Debug: $object",
      ); //https://api.flutter.dev/flutter/rendering/debugPrint.html
    }
  }
}
