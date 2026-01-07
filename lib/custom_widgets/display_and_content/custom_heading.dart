import 'package:flutter/material.dart';

import 'package:journeyers/app_themes.dart';
import 'package:journeyers/custom_widgets/display_and_content/custom_focusable_text.dart';

/// {@category Custom widgets}
/// A customizable heading (level 1 to 6).
class CustomHeading extends StatelessWidget 
{
  /// The title of the heading.
  final String headingText;

  /// The level of the heading.
  final int headingLevel;

  /// The style of the heading.
  late final TextStyle headingStyle;

  /// The alignment of the heading.
  final TextAlign headingAlignment;

  CustomHeading
  ({
    super.key,
    required this.headingText,
    required this.headingLevel,
    this.headingAlignment = TextAlign.center,
  }) : assert(headingLevel >= 1 && headingLevel <= 6,'Heading level must be between 1 and 6.');

  @override
  Widget build(BuildContext context) 
  {
    switch (headingLevel) 
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
    }

    return CustomFocusableText(text: headingText, textStyle: headingStyle);
  }
}
