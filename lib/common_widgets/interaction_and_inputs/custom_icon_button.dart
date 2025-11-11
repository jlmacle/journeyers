import 'package:flutter/material.dart';

class CustomIconButton extends StatefulWidget {
  final Icon icon;
  final String toolTipLabel;
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

class _CustomIconButtonState extends State<CustomIconButton> {
  @override
  Widget build(BuildContext context) {
    return IconButton
    (
      onPressed: widget.onPressedFunction, 
      tooltip: widget.toolTipLabel,
      icon: widget.icon,
    );
  }
}