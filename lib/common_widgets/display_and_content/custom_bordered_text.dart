import 'package:flutter/material.dart';
import 'package:journeyers/common_widgets/display_and_content/custom_text.dart';

class CustomBorderedText extends StatelessWidget 
{
  /// The CustomText containing the text
  final CustomText customText;
  /// The padding information encapsulated in an EdgeInsetsGeometry
  final EdgeInsetsGeometry edgeInsetsGeometry;
  /// The Border used to pass the border information
  final Border border;
  /// The color of the border
  final Color borderColor;
  /// The width of the border
  final double borderWidth;
  /// The BorderRadius used to pass the border radius information
  final BorderRadius borderRadius;

  const CustomBorderedText
  ({
    super.key,
    required this.customText,
    required this.edgeInsetsGeometry,
    required this.border,
    this.borderColor = Colors.black,
    this.borderWidth = 1,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) 
  {
    return Container
    (
      padding: edgeInsetsGeometry,
      decoration: BoxDecoration
      (
        border: border,    
        borderRadius: borderRadius,         
      ), 
      child: customText      
    );
  }
}