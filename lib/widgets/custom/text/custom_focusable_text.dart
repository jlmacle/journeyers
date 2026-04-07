// Line for automated processing
// flutter run -t ./lib/widgets/custom/text/custom_focusable_text.dart -d chrome
// flutter run -t ./lib/widgets/custom/text/custom_focusable_text.dart -d linux
// flutter run -t ./lib/widgets/custom/text/custom_focusable_text.dart -d macos
// flutter run -t ./lib/widgets/custom/text/custom_focusable_text.dart -d windows
// Line for automated processing

import 'package:flutter/material.dart';

/// {@category Custom widgets}
/// A customizable focusable text.

class CustomFocusableText extends StatefulWidget
{

  /// The text to display.
  final String text;

  /// The style of the text.
  final TextStyle textStyle;

  /// The alignment of the text.
  final TextAlign textAlignment;

  const CustomFocusableText
  ({
    super.key,
    required this.text,
    this.textStyle = const 
        TextStyle
        (
          color: Colors.black,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
    this.textAlignment = TextAlign.center,
  });

  @override
  State<CustomFocusableText> createState() => _CustomFocusableTextState();
}

class _CustomFocusableTextState extends State<CustomFocusableText> 
{
  FocusNode textFocusNode = .new();

  @override
  void dispose() 
  {
    textFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) 
  {
    return 
    Semantics
    (
      focusable: true,
      child: 
      Focus
      (
        focusNode: textFocusNode,
        child: Text(widget.text, style: widget.textStyle, textAlign: widget.textAlignment),
      ),
    );
  }
}
