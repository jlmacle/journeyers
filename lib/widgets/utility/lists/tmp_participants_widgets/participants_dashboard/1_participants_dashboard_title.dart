import "package:flutter/material.dart";

import "package:journeyers/widgets/custom/text/custom_heading.dart";

/// {@category Utils - Project-specific}
/// {@category Lists}
/// A widget used for the title of the participants lists dashboard.
class ParticipantsListsDashboardTitle extends StatelessWidget 
{
  /// The title for the dashboard.
  final String title;

  const ParticipantsListsDashboardTitle
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