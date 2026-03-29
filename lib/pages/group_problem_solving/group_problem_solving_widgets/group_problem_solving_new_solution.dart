import 'package:flutter/material.dart';
import 'package:journeyers/app_themes.dart';

/// {@category Group problem-solving}
/// A widget used to add a new solution to the list.
class GroupProblemSolvingNewSolution extends StatefulWidget 
{
  /// A callback function used to update the list of solutions.
  final ValueChanged<String> solutionAddedCallbackFunction;

  const GroupProblemSolvingNewSolution
  ({
    super.key,
    required this.solutionAddedCallbackFunction
  });

  @override
  State<GroupProblemSolvingNewSolution> createState() => _GroupProblemSolvingNewSolutionState();
}

class _GroupProblemSolvingNewSolutionState extends State<GroupProblemSolvingNewSolution> 
{
  // TextEditingController for entering a new solution
  final TextEditingController _solutionController = TextEditingController();

  // Method to handle adding a solution to the list
  void _submitSolution() {
    if (_solutionController.text.trim().isNotEmpty) {
      // Adding the new solution to the list
      widget.solutionAddedCallbackFunction(_solutionController.text.trim());
      _solutionController.clear();
    }
  }

  @override
  void dispose() 
  {
    _solutionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return 
    Container(
          color: Theme.of(context).cardColor,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _solutionController,
                  decoration: const InputDecoration(
                    hintText: "Please type a solution.",
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onSubmitted: (_) => _submitSolution(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.send, color: navyBlue),
                onPressed: _submitSolution,
              ),
            ],
          ),
        );
  }
}