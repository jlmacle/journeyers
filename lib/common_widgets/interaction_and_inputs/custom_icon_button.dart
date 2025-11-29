import 'package:flutter/material.dart';

/// A customizable icon button

class CustomIconButton extends StatefulWidget 
{
  /// The icon to use
  final Icon icon;
  /// The tool tip label for the icon
  final String toolTipLabel;
  /// The callback function to call when the icon button is pressed
  final VoidCallback onPressedFunction;   // type alias: typedef VoidCallback = void Function();

  const CustomIconButton
  ({
    super.key,
    required this.icon,
    required this.toolTipLabel,
    required this.onPressedFunction,
  });

  @override
  State<CustomIconButton> createState() => _CustomIconButtonState();
}

class _CustomIconButtonState extends State<CustomIconButton> 
{
  @override
  Widget build(BuildContext context) 
  {
    return IconButton
    (
      onPressed: widget.onPressedFunction, 
      tooltip: widget.toolTipLabel,
      icon: widget.icon,
    );
  }
}