import 'package:flutter/material.dart';

import 'package:journeyers/app_themes.dart';
import 'package:journeyers/pages/group_problem_solving/group_problem_solving_process_widgets/_group_problem_solving_externalized_variables.dart';

/// {@category Group problem-solving}
/// A widget used to list the ideas found during a group problem-solving process.
class GPSIdeasList extends StatelessWidget {
  /// The ideas for the group problem-solving process.
  final List<String> ideas;

  const GPSIdeasList({super.key, required this.ideas});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Center(
          child: Text(ideasListTitle, style: problemSolvingIdeasTitle),
        ),
        const SizedBox(height: 10),
        if (ideas.isEmpty)
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(ideasListPlaceholder, style: TextStyle(fontStyle: FontStyle.italic)),
          ),
        ...ideas.map((idea) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
              child: Card(
                child: ListTile(
                  title: Text(idea),
                ),
              ),
            )),
      ],
    );
  }
}