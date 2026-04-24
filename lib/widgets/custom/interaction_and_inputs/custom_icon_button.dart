import 'package:flutter/material.dart';

/// {@category Custom widgets}
/// A customizable icon button.
class CustomIconButton extends StatelessWidget 
{

  /// The icon of the button.
  final Icon icon;
  /// The tooltip label for the icon.
  final String toolTipLabel;
  /// The callback function called when the button is pressed.
  final VoidCallback onPressedFunction;  

  const CustomIconButton
  ({
    super.key,
    required this.icon,
    required this.toolTipLabel,
    required this.onPressedFunction,  
  });

  @override
  Widget build(BuildContext context) {
    return IconButton
    (
      onPressed: onPressedFunction, 
      tooltip: toolTipLabel,
      icon: icon,
    );
  }
}