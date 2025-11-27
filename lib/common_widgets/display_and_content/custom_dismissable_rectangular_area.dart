import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

typedef NewVisibilityStatusCallback = void Function(bool newVisibilityStatus);

/// A customizable, dismissable, rectangular area widget, with a message to display, and a text related to the act of clicking on the widget.
/// The rectangular area takes the width of the screen.

class CustomDismissableRectangularArea extends StatefulWidget {
  final BuildContext buildContext;

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
  final double sizedBoxHeight;

  /// The function to call to have the rectangular area disappearing, or appearing, from the screen.
  /// The user can click anywhere on the rectangular area.
  final NewVisibilityStatusCallback setStateCallBack;

  const CustomDismissableRectangularArea
  ({
    super.key,
    required this.buildContext,

    required this.message1,
    this.message2 = "",
    this.messagesColor = Colors.black,
    this.messagesFontWeight = FontWeight.bold,    

    required this.actionText,
    this.actionTextColor = Colors.black,
    this.actionTextFontWeight = FontWeight.normal,

    this.areaBackgroundColor = Colors.white,
    this.sizedBoxHeight = 120,

    required this.setStateCallBack
  });

  

  @override
  State<CustomDismissableRectangularArea> createState() => _CustomDismissableRectangularAreaState();
}

class _CustomDismissableRectangularAreaState extends State<CustomDismissableRectangularArea> {

  FocusNode dismissableRectangularAreaFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) 
  {
    return Semantics
          (        
            header: true,
            headingLevel: 2,
            focusable: true,            
            child: Focus
            (
              focusNode: dismissableRectangularAreaFocusNode,
              child: 
    GestureDetector
    (
      onTap:() {bool messageVisibility = false; widget.setStateCallBack(messageVisibility);},
      child: SizedBox(
        height: widget.sizedBoxHeight,
        child: Container(
          color: widget.areaBackgroundColor,
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end, // to position at the bottom of the box
            children: [
              Center(
                child: Text
                (
                  widget.message1,
                  style: TextStyle
                  (
                    color: widget.messagesColor,
                    fontWeight: widget.messagesFontWeight,                
                  ),
                ),
              ),
              if (widget.message2 != "")       
                Center(
                  child: Text
                  (
                    widget.message2,
                    style: TextStyle
                    (
                      color: widget.messagesColor,
                      fontWeight: widget.messagesFontWeight,                  
                    ),
                  ),
                ),
                Gap(20),
                Center(                
                    child: Text
                    (
                      widget.actionText,
                      style: TextStyle
                      (
                        color: widget.actionTextColor,
                        fontWeight: widget.actionTextFontWeight,                  
                      ),
                    ),                
                ),
            ],
          ),
        ),
      ),
    ))
    );
  }
}