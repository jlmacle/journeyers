import 'package:flutter/material.dart';
import 'package:journeyers/common_widgets/display_and_content/custom_text.dart';

class CustomBorderedText extends StatelessWidget 
{
  /// The CustomText object containing the text
  final CustomText customTextObject;
  /// The padding information encapsulated in an EdgeInsetsGeometry object
  final EdgeInsetsGeometry edgeInsetsGeometryObject;
  /// The Border object used to pass the border information
  final Border borderObject;
  /// The color of the border
  final Color borderColor;
  /// The width of the border
  final double borderWidth;
  /// The BorderRadius object used to pass the border radius information
  final BorderRadius borderRadiusObject;

  const CustomBorderedText
  ({
    super.key,
    required this.customTextObject,
    required this.edgeInsetsGeometryObject,
    required this.borderObject,
    this.borderColor = Colors.black,
    this.borderWidth = 1,
    required this.borderRadiusObject,
  });

  @override
  Widget build(BuildContext context) 
  {
    return Container
    (
      padding: edgeInsetsGeometryObject,
      decoration: BoxDecoration
      (
        border: borderObject,    
        borderRadius: borderRadiusObject,         
      ), 
      child: customTextObject      
    );
  }
}