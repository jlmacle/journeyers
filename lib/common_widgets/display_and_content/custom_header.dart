

import 'package:flutter/material.dart';
import 'package:journeyers/app_themes.dart';
import 'package:journeyers/common_widgets/display_and_content/custom_text.dart';

class CustomHeader extends StatelessWidget 
{
  /// The title of the header
  final String headerTitle;  
  /// The level of the header
  final int headerLevel;   
  /// The direction of the header
  final TextDirection headerDirection;
  /// The style of the header
  late TextStyle headerStyle;
  /// The alignment of the header
  final TextAlign headerAlign;

  CustomHeader
  ({
    super.key, 
    required this.headerTitle, 
    required this.headerLevel, 
    this.headerDirection = TextDirection.ltr, 
    this.headerAlign=TextAlign.center
  }): assert(headerLevel >= 1 && headerLevel <= 6, 'Heading level must be between 1 and 6.');

  @override
  Widget build(BuildContext context) 
  {
    FocusNode groupProblemSolvingDashboardFocusNode = FocusNode();    

    switch(headerLevel)
    {
      case 1:
        headerStyle = appTheme.textTheme.headlineLarge!;
      case 2:
        headerStyle = appTheme.textTheme.headlineMedium!;
        break;
      case 3:
        headerStyle = appTheme.textTheme.headlineSmall!;
      case 4:
        headerStyle = appTheme.textTheme.titleLarge!;
      case 5:
        headerStyle = appTheme.textTheme.titleMedium!;
      case 6:
        headerStyle = appTheme.textTheme.titleSmall!;
      default:
        headerStyle = appTheme.textTheme.labelMedium!;
    }

    return MergeSemantics(child: Semantics
    (        
      header: true,
      headingLevel: headerLevel,
      focusable: true,            
      child: Focus
      (
        focusNode: groupProblemSolvingDashboardFocusNode,
        child: CustomText(text: headerTitle, textStyle: headerStyle),
      ),
    ));
  }
}