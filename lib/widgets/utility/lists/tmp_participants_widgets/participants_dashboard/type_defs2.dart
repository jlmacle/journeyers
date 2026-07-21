import "package:flutter/material.dart";



/// {@category Utils - Generic}
/// A function with a String parameter, an int parameter, and returning void.
typedef OnListItemValueUpdatedCallbackFunctionType = 
void Function({required int intParam, required String stringParam});

/// {@category Utils - Generic}
/// A function with a bool? parameter, and an int parameter.
typedef FunctionNullableBoolAndInt = 
void Function({required bool? boolParam, required int intParam});
