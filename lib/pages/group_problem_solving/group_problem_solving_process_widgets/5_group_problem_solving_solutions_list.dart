import 'package:flutter/material.dart';

import 'package:journeyers/app_themes.dart';
import 'package:journeyers/pages/group_problem_solving/group_problem_solving_process_widgets/_group_problem_solving_misc_constants.dart'; // Ensure this matches your path

/// {@category Group problem-solving}
/// A widget used to list the solutions found during a group problem-solving process.
class GPSSolutionsList extends StatelessWidget {
  /// The solutions for the group problem-solving process.
  final List<String> solutions;

  const GPSSolutionsList({super.key, required this.solutions});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Center(
          child: Text(solutionsListTitle, style: problemSolvingSolutionsTitle),
        ),
        const SizedBox(height: 10),
        if (solutions.isEmpty)
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(solutionsListPlaceholder, style: TextStyle(fontStyle: FontStyle.italic)),
          ),
        ...solutions.map((solution) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
              child: Card(
                child: ListTile(
                  title: Text(solution),
                ),
              ),
            )),
      ],
    );
  }
}