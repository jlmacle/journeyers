import 'package:flutter/material.dart';

/// {@category Utils - Generic}
/// A function with a dynamic parameter, and returning a widget.
typedef FunctionDynamicToWidget = 
Widget Function({required dynamic dynamicParam});

/// {@category Utils - Generic}
/// A function with a String parameter, an int parameter, and returning void.
typedef FunctionStringAndInt = 
void Function({required String stringParam, required int intParam});
