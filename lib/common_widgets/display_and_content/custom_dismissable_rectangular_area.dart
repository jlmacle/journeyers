import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

typedef NewVisibilityStatusCallback = void Function(bool newVisibilityStatus);

class CustomDismissableRectangularArea extends StatefulWidget {
  final BuildContext buildContext;

  final String message1;
  final String message2;
  final Color messagesColor;
  final FontWeight messagesFontWeight;

  final String actionText;
  final Color actionTextColor;
  final FontWeight actionTextFontWeight;

  final Color areaBackgroundColor;
  final double sizedBoxHeight;

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
  @override
  Widget build(BuildContext context) 
  {
    return GestureDetector
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
    );
  }
}