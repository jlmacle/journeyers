import 'package:flutter/material.dart';
import 'package:journeyers/app_themes.dart';
import 'package:journeyers/common_widgets/display_and_content/custom_text.dart';

class CustomHeading extends StatelessWidget 
{
  /// The title of the heading
  final String headingTitle;  
  /// The level of the heading
  final int headingLevel;   
  /// The style of the heading
  late final TextStyle headingStyle;
  /// The alignment of the heading
  final TextAlign headingAlign;

  CustomHeading
  ({
    super.key, 
    required this.headingTitle, 
    required this.headingLevel, 
    this.headingAlign = TextAlign.center
  }): assert(headingLevel >= 1 && headingLevel <= 6, 'Heading level must be between 1 and 6.');

  @override
  Widget build(BuildContext context) 
  {
    FocusNode headingFocusNode = FocusNode();    

    switch(headingLevel)
    {
      case 1:
        headingStyle = appTheme.textTheme.headlineLarge!;
      case 2:
        headingStyle = appTheme.textTheme.headlineMedium!;
        break;
      case 3:
        headingStyle = appTheme.textTheme.headlineSmall!;
      case 4:
        headingStyle = appTheme.textTheme.titleLarge!;
      case 5:
        headingStyle = appTheme.textTheme.titleMedium!;
      case 6:
        headingStyle = appTheme.textTheme.titleSmall!;
      default:
        headingStyle = appTheme.textTheme.labelMedium!;
    }

    return MergeSemantics(child: Semantics
    (        
      header: true,
      headingLevel: headingLevel,
      focusable: true,            
      child: Focus
      (
        focusNode: headingFocusNode,
        child: CustomText(text: headingTitle, textStyle: headingStyle),
      ),
    ));
  }
}