import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// A customizable, dismissable, rectangular area widget, with a message to display, 
/// and a text related to the act of clicking on the widget.
/// The rectangular area takes the width of the screen.

class CustomDismissibleRectangularArea extends StatefulWidget {
  /// The first part of the message to display
  final String message1;
  /// The second part of the message to display
  final String message2;
  /// The color of the message to display
  final Color messagesColor;
  /// The font of the message to display
  final FontWeight messagesFontWeight;

  /// The text related to the act of clicking on the widget
  final String actionText;
  /// The color of the text related to the act of clicking on the widget
  final Color actionTextColor;
  /// The font of the text related to the act of clicking on the widget
  final FontWeight actionTextFontWeight;

  /// The color of the rectangular area
  final Color areaBackgroundColor;
  /// The height of the rectangular area
  final double areaHeight;

  /// The function to call to have the rectangular area disappearing, or appearing, from the screen.
  /// The user can click anywhere on the rectangular area.
  final VoidCallback parentWidgetAreaOnTapCallBackFunction;

  const CustomDismissibleRectangularArea
  ({
    super.key,
    required this.message1,
    this.message2 = "",
    this.messagesColor = Colors.black,
    this.messagesFontWeight = FontWeight.bold,    

    required this.actionText,
    this.actionTextColor = Colors.black,
    this.actionTextFontWeight = FontWeight.normal,

    this.areaBackgroundColor = Colors.white,
    this.areaHeight = 200,

    required this.parentWidgetAreaOnTapCallBackFunction
  });

  

  @override
  State<CustomDismissibleRectangularArea> createState() => _CustomDismissibleRectangularAreaState();
}

class _CustomDismissibleRectangularAreaState extends State<CustomDismissibleRectangularArea> 
{

  FocusNode dismissibleRectangularAreaFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) 
  {
    return MergeSemantics
    (        
      child: Focus
      (
        focusNode: dismissibleRectangularAreaFocusNode,
        child: InkWell
        (
          onTap:() {widget.parentWidgetAreaOnTapCallBackFunction();},
          child: Container(
            color: widget.areaBackgroundColor,
            padding: EdgeInsets.symmetric(vertical: 20),
            child: ConstrainedBox(
              constraints: BoxConstraints
              (
                minHeight: widget.areaHeight,
                maxHeight: double.infinity,
                minWidth: double.infinity,
              ),
              child: Column
              (
                mainAxisAlignment: MainAxisAlignment.center, 
                children: [
                  Semantics
                  (
                    headingLevel: 1,
                    focusable: true,
                    focused: true,
                    child: Focus
                    (
                      child: Text
                      (
                        widget.message1,
                        textAlign: TextAlign.center,
                        style: TextStyle
                        (
                          color: widget.messagesColor,
                          fontWeight: widget.messagesFontWeight,  
                                        
                        ),
                      ),
                    ),
                  ),
                  if (widget.message2 != "")    
                    Semantics
                    (
                      headingLevel: 1,
                      focusable: true,
                      child: Focus
                      (   
                        child: Text
                        (
                          widget.message2,
                          textAlign: TextAlign.center,
                          style: TextStyle
                          (
                            color: widget.messagesColor,
                            fontWeight: widget.messagesFontWeight,                  
                          ),
                        ),
                      ),
                    ),
                    Gap(20),
                    Semantics
                    (
                      headingLevel: 1,
                      focusable: true,
                      child: Focus
                      (
                        child: Text
                        (
                          widget.actionText,
                          textAlign: TextAlign.center,
                          style: TextStyle
                          (
                            color: widget.actionTextColor,
                            fontWeight: widget.actionTextFontWeight,                  
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      )
    );
  }
}