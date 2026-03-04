import 'package:flutter/material.dart';

class CustomIconButton extends StatelessWidget 
{

  final Icon icon;
  final String toolTipLabel;
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