import 'package:flutter/material.dart';

import 'package:journeyers/app_themes.dart';
import 'package:journeyers/core/utils/printing_and_logging/print_utils.dart';
import 'package:journeyers/custom_widgets/display_and_content/custom_focusable_text.dart';

// Utility class
PrintUtils pu = PrintUtils();

/// {@category Custom widgets}
/// A customizable heading (level 1 to 6).
class CustomHeading extends StatefulWidget 
{
  /// The title of the heading.
  final String headingText;

  /// The level of the heading.
  final int headingLevel;

  /// The alignment of the heading.
  final TextAlign headingAlignment;

  CustomHeading
  ({
    super.key,
    required this.headingText,
    required this.headingLevel,
    this.headingAlignment = TextAlign.center,
  })
  {
    assert(headingLevel >= 1 && headingLevel <= 6,'Heading level must be between 1 and 6.');
    
  }
  
  @override
  State<CustomHeading> createState() =>  CustomHeadingState();
}


class CustomHeadingState extends State<CustomHeading> 
{
  bool _headingStyleUnderlined = false;
  
  late TextStyle _headerStyle;

  TextStyle getTextStyle(int headingLevel)
  {


    switch (headingLevel) 
    {
      case 1:
        return appTheme.textTheme.headlineLarge!;
      case 2:
        return appTheme.textTheme.headlineMedium!;
      case 3:
        return appTheme.textTheme.headlineSmall!;
      case 4:
        return appTheme.textTheme.titleLarge!;
      case 5:
        return appTheme.textTheme.titleMedium!;
      case 6:
        return appTheme.textTheme.titleSmall!;
    }

    return defaultConstHeadingStyle;
  }

  @override
  void initState() {
    _headerStyle = getTextStyle(widget.headingLevel);
    super.initState();
  }

  // switches the heading decoration if a checkbox is checked
  void switchCustomHeadingDecorationIfCheckboxChecked()
  {
    if (!_headingStyleUnderlined) {
      setState(() {
        _headerStyle = _headerStyle.copyWith(decoration: TextDecoration.underline);
      });
      
      _headingStyleUnderlined = true;
    }
    else{
      setState(() {
        _headerStyle = _headerStyle.copyWith(decoration: TextDecoration.none);
      });
      _headingStyleUnderlined = false;
    }
  }

  // switches the heading decoration if a text field is used
  void switchCustomHeadingDecorationIfTextFieldUsed(String value)
  {
    if (!_headingStyleUnderlined && value.trim() != "") {
      setState(() {
        _headerStyle = _headerStyle.copyWith(decoration: TextDecoration.underline);
      });
      
      _headingStyleUnderlined = true;
    }
    else if (_headingStyleUnderlined && value.trim() == "") {
      setState(() {
        _headerStyle = _headerStyle.copyWith(decoration: TextDecoration.none);
      });
      _headingStyleUnderlined = false;
    }
  }

  @override
  Widget build(BuildContext context) 
  {


    return CustomFocusableText(text: widget.headingText, textStyle: _headerStyle, textAlignment: widget.headingAlignment);
  }
}
