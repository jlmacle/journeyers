import 'package:flutter/material.dart';

import 'package:journeyers/app_themes.dart';
import 'package:journeyers/pages/group_problem_solving/group_problem_solving_process_widgets/_group_problem_solving_externalized_variables.dart';

/// {@category Group problem-solving}
/// A widget used to add a new idea to the list.
class GPSNewIdea extends StatefulWidget 
{
  /// A callback function used to update the list of ideas.
  final ValueChanged<String> ideaOnAddedCallbackFunction;

  const GPSNewIdea
  ({
    super.key,
    required this.ideaOnAddedCallbackFunction
  });

  @override
  State<GPSNewIdea> createState() => _GPSNewIdeaState();
}

class _GPSNewIdeaState extends State<GPSNewIdea> 
{
  // TextEditingController for entering a new idea
  final TextEditingController _ideaTfec = .new();
  // FocusNode used to keep the focus on the new idea field after an idea has been entered
  final FocusNode _ideaFocusNode = FocusNode();

  // Method to handle adding an idea to the list
  void _ideaSubmit() {
    if (_ideaTfec.text.trim().isNotEmpty) {
      // Adding the new idea to the list
      widget.ideaOnAddedCallbackFunction(_ideaTfec.text.trim());
      _ideaTfec.clear();
    }
    _ideaFocusNode.unfocus();
  }

  @override
  void dispose() 
  {
    _ideaTfec.dispose();
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
                  focusNode: _ideaFocusNode,
                  controller: _ideaTfec,
                  decoration: const InputDecoration(
                    hintText: newIdeaTextFieldHint,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onSubmitted: (_) => _ideaSubmit(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.send, color: navyBlue),
                onPressed: _ideaSubmit,
              ),
            ],
          ),
        );
  }
}