import 'package:flutter/material.dart';

/// {@category Custom widgets}
/// A customizable icon button.
class CustomIconButton extends StatefulWidget 
{
  /// The icon to use.
  final Icon icon;
  /// The tooltip label for the icon.
  final String toolTipLabel;
  /// The callback function called when the icon button is pressed.
  final VoidCallback parentWidgetOnPressedCallBackFunction;   // type alias: typedef VoidCallback = void Function();

  const CustomIconButton
  ({
    super.key,
    required this.icon,
    required this.toolTipLabel,
    required this.parentWidgetOnPressedCallBackFunction,
  });

  @override
  State<CustomIconButton> createState() => _CustomIconButtonState();
}

class _CustomIconButtonState extends State<CustomIconButton> 
{
  @override
  Widget build(BuildContext context) 
  {
    return 
    IconButton
    (
      onPressed: widget.parentWidgetOnPressedCallBackFunction, 
      tooltip: widget.toolTipLabel,
      icon: widget.icon,
    );
  }
}