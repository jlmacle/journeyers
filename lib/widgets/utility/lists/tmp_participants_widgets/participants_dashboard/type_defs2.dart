import "package:flutter/material.dart";




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
