import 'package:flutter/material.dart';

import 'package:journeyers/app_themes.dart';

/// {@category Group problem-solving}
/// A widget used to define the problem to solve, or to retrieve a title from previous context analyses.
class GroupProblemSolvingProblemToSolve extends StatefulWidget {
  /// A TextEditingController for the session title.
  final TextEditingController problemTitleController;
  /// The data from the previous context analyses sessions.
  final List<Map<String, dynamic>> previousSessions;
  // A callback function for when a previous context analysis session data is selected.
  final Function(Map<String, dynamic>) onSessionSelected;

  const GroupProblemSolvingProblemToSolve({
    super.key,
    required this.problemTitleController,
    required this.previousSessions,
    required this.onSessionSelected,
  });

  @override
  State<GroupProblemSolvingProblemToSolve> createState() => _GroupProblemSolvingProblemToSolveState();
}

class _GroupProblemSolvingProblemToSolveState extends State<GroupProblemSolvingProblemToSolve> {
  bool _isEditing = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: _isEditing 
        ? Column(
            children: [
              TextField(
                controller: widget.problemTitleController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: "Enter title or select below",
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.check, color: greenShade900),
                    onPressed: () => setState(() => _isEditing = false),
                  ),
                ),
              ),
              // Suggestions List from previous context analyses session data
              if (widget.previousSessions.isNotEmpty)
                Container(
                  // Limiting the suggestion area height to avoid an overflow
                  // TODO: different maxHeight according to platform
                  constraints: const BoxConstraints(maxHeight: 150), 
                  child: ListView.builder(
                    itemCount: widget.previousSessions.length,
                    itemBuilder: (context, index) {
                      final session = widget.previousSessions[index];
                      return ListTile(
                        title: Text(session['title']),
                        subtitle: Text("Date: ${session['date']}"),
                        onTap: () {
                          widget.onSessionSelected(session);
                          setState(() => _isEditing = false);
                        },
                      );
                    },
                  ),
                ),
            ],
          )
          : 
          GestureDetector(
            // TODO: to expand to clicking
            onTap: () => setState(() => _isEditing = true),
            child:
            Flex(
            direction: Axis.horizontal, 
            children: [
              // Widget 1: Left side
              Container(width: 50),
              
              // Widget 2: The Centered Text
              // Expanded fills the middle gap so Center can work effectively
              Expanded(
                child: Center(
                  child: Text(
                  (widget.problemTitleController.text.trim() == "") ? "Problem To Solve": widget.problemTitleController.text.trim(), 
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                ),
              ),
              
              // Widget 3: Right side
              Container(
                width: 50,
                child: GestureDetector
                (
                  child: const Text("✏️"),
                  onTap: () => setState(() => _isEditing = true),
                ),
              ),
            ],
          ),
        ),
      );
  }
}