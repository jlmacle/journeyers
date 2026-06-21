import 'package:flutter/material.dart';

import 'package:journeyers/widgets/custom/text/custom_heading.dart';

/// {@category Utility widgets}
/// {@category Lists}
/// A widget used for the title of the dashboard.
class ListDashboardTitle extends StatelessWidget 
{
  /// The title for the dashboard.
  final String title;

  const ListDashboardTitle
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
      child: CustomHeading
      (
          headingText: title, headingLevel: 2
      ),
    );
  }
}