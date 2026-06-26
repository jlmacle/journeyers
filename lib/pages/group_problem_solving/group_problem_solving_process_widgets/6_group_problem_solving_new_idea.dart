import 'package:flutter/material.dart';

import 'package:journeyers/app_themes.dart';
import 'package:journeyers/pages/group_problem_solving/group_problem_solving_process_widgets/_group_problem_solving_externalized_variables.dart';
import 'package:journeyers/utils/generic/dev/utility_classes_import.dart';

/// {@category Group problem-solving}
/// A widget used to add a new idea to the list.
class GPSNewIdea extends StatefulWidget 
{
  /// A callback function used to update the list of ideas.
  final ValueChanged<String> newIdeaOnAddedCallbackFunction;

  const GPSNewIdea
  ({
    super.key,
    required this.newIdeaOnAddedCallbackFunction
  });

  @override
  State<GPSNewIdea> createState() => _GPSNewIdeaState();
}

class _GPSNewIdeaState extends State<GPSNewIdea> 
{
  // TextEditingController for entering a new idea
  final TextEditingController _newIdeaTfec = .new();
  // FocusNode used to keep the focus on the new idea field after an idea has been entered
  final FocusNode _newIdeaFocusNode = FocusNode();

  // Method to handle adding an idea to the list
  void _newIdeaSubmit() {
    if (_newIdeaTfec.text.trim().isNotEmpty) {
      // Adding the new idea to the list
      widget.newIdeaOnAddedCallbackFunction(_newIdeaTfec.text.trim());
      _newIdeaTfec.clear();
    }
    _newIdeaFocusNode.unfocus();
  }

  @override
  void dispose() 
  {
    _newIdeaTfec.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
                        
    pu.printdLine();
    pu.printd("GPSNewIdea");
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
                  focusNode: _newIdeaFocusNode,
                  controller: _newIdeaTfec,
                  decoration: const InputDecoration(
                    hintText: newIdeaTextFieldHint,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onSubmitted: (_) => _newIdeaSubmit(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.send, color: navyBlue),
                onPressed: _newIdeaSubmit,
              ),
            ],
          ),
        );
  }
}