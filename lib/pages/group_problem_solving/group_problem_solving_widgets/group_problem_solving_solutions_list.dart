import 'package:flutter/material.dart';
import 'package:journeyers/app_themes.dart'; // Ensure this matches your path

/// {@category Group problem-solving}
/// A widget used to list the solutions found during a group problem-solving process.
class GroupProblemSolvingSolutionsList extends StatelessWidget {
  final List<String> solutions;

  const GroupProblemSolvingSolutionsList({super.key, required this.solutions});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Center(
          child: Text("List of solutions", style: problemSolvingSolutionsTitle),
        ),
        const SizedBox(height: 10),
        if (solutions.isEmpty)
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Text("No solutions added yet.", style: TextStyle(fontStyle: FontStyle.italic)),
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