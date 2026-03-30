import 'package:flutter/material.dart';
import 'package:journeyers/widgets/custom/text/custom_heading.dart';

/// {@category Utility widgets}
/// A widget used for the title of the dashboard.
class DashboardTitle extends StatelessWidget 
{
  final String title;

  const DashboardTitle
  ({
    super.key,
    required this.title    
  });

  @override
  Widget build(BuildContext context) {
    return 
    Padding
    (
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      child: CustomHeading(
          headingText: title, headingLevel: 2),
    );
  }
}