import 'package:flutter/material.dart';

/// {@category Custom widgets}
/// A customizable focusable text.
class CustomFocusableText extends StatelessWidget {
  /// The text to display.
  final String text;
  /// The text style.
  final TextStyle textStyle;
  /// The text alignment.
  final TextAlign textAlignment;

  const CustomFocusableText
  ({
    super.key,
    required this.text,
    this.textStyle = const TextStyle(color: Colors.black, fontSize: 24,  fontWeight: FontWeight.bold),
    this.textAlignment = TextAlign.center,
  });

  @override
  Widget build(BuildContext context) 
  {
    FocusNode textFocusNode = FocusNode();

    return Semantics
    ( 
      focusable: true,            
      child: Focus
      (
        focusNode: textFocusNode,
        child: Text
        (
          text,      
          style: textStyle,
          textAlign: textAlignment,
        )
      ),
    );
  }
}
