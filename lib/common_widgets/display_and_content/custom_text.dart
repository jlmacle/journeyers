import 'package:flutter/material.dart';

class CustomText extends StatelessWidget {
  /// The text to display
  final String text;
  /// The text font size 
  final double fontSize;
  /// The text alignment
  final TextAlign textAlign;
  /// The text color
  final Color color;
  /// The text font weight
  final FontWeight fontWeight;
  /// The text direction
  final TextDirection textDirection;

  const CustomText
  ({
    super.key,
    required this.text,
    this.fontSize = 24,
    this.textAlign = TextAlign.center,
    this.color = Colors.black,
    this.fontWeight = FontWeight.bold,
    this.textDirection = TextDirection.ltr,
  });

  @override
  Widget build(BuildContext context) 
  {
    return Text(
      text,
      textAlign: textAlign,
      textDirection: textDirection, 
      style: TextStyle(fontSize: fontSize, color: color, fontWeight: fontWeight),
    );
  }
}
