import 'package:flutter/material.dart';
import 'package:journeyers/app_themes.dart';

class ProblemToSolve extends StatelessWidget {
  const ProblemToSolve({super.key});

  @override
  Widget build(BuildContext context) {
    return 
    const Padding
    (
      padding: EdgeInsetsGeometry.all(10),
      // Should be a text field becoming a text
      child:Center(child: Text('Problem to solve', style:dialogStyle))
    );
  }
}