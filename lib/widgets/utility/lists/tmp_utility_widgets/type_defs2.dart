import "package:flutter/material.dart";

/// {@category Utils - Generic}
/// A function that returns a record,
/// with a boolean (true if a string should be sanitized),
/// and with a function to sanitize the string.
typedef StringSanitizerBundle = 
({
  bool shouldStringBeSanitized, 
  dynamic Function(dynamic) sanitizingFunction
}) 
Function(String);

/// {@category Utils - Generic}
/// A function that returns true if a string should be blocked.
typedef BlacklistingFunction = 
bool Function(String value);

/// An async function with a Set\<String\> parameter, and a String parameter.
typedef FunctionSetStringAndString2 = 
Future<void> Function({required String? listKey, required Set<String> updatedKeywords});

/// An async function with a Set\<String\> parameter, a Map\<String, dynamic\> parameter, and a String parameter.
typedef FunctionSetStringMapStringDynamicAndString = 
Future<void> Function({required String? listKey, required Set<String> updatedItems, required Map<String, dynamic> listData});

/// An async function with a String parameter, and a Map\<String, dynamic\> parameter.
typedef FunctionStringAndMapStringDynamic = 
Future<void> Function({required String? listKey, required Map<String, dynamic> listData});


/// {@category Utils - Generic}
/// An async function without parameters, and returning Future\<void\>.
typedef FutureVoidCallback = 
Future<void> Function();


/// {@category Utils - Generic}
/// A function with a dynamic parameter, and returning a widget.
typedef FunctionDynamicToWidget = 
Widget Function({required dynamic dynamicParam});

/// {@category Utils - Generic}
/// A function with a String parameter, an int parameter, and returning void.
typedef FunctionStringAndInt = 
void Function({required String stringParam, required int intParam});

/// {@category Utils - Generic}
/// A function with a bool? parameter, and an int parameter.
typedef FunctionNullableBoolAndInt = 
void Function({required bool? boolParam, required int intParam});
