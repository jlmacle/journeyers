import "package:flutter/material.dart";

import "package:journeyers/app_themes.dart";
import "package:journeyers/debug_constants.dart";
import "package:journeyers/pages/group_problem_solving/group_problem_solving_process_widgets/_group_problem_solving_externalized_variables.dart";
import "package:journeyers/utils/generic/dev/utility_classes_import.dart";

/// {@category Group problem-solving}
/// A widget used to define the problem to solve, or to retrieve a title from previous context analyses. In the latter case, (gps) is added in suffix.
class GPSProblemToSolveDeclaration extends StatefulWidget {
  /// The title value at edition time.
  final String titleWhenEdition;
  /// A TextEditingController for the session title.
  final TextEditingController sessionTitleTfec;
  /// The data from the previous context analyses sessions (for metadata import).
  final List<Map<String, dynamic>> previousSessions;
  /// A callback function used when a previous context analysis session data is selected.
  final Function(Map<String, dynamic>) onSessionSelected;

  const GPSProblemToSolveDeclaration({
    super.key,
    this.titleWhenEdition = "",
    required this.sessionTitleTfec,
    required this.previousSessions,
    required this.onSessionSelected,
  });

  @override
  State<GPSProblemToSolveDeclaration> createState() => _GPSProblemToSolveDeclarationState();
}

class _GPSProblemToSolveDeclarationState extends State<GPSProblemToSolveDeclaration> {
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    
    if (widgetSequenceDebug) pu.printdLine();
    if (widgetSequenceDebug) pu.printd("GPSProblemToSolveDeclaration");

    if (widget.titleWhenEdition != "") widget.sessionTitleTfec.text = widget.titleWhenEdition;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: _isEditing 
        ? Column(
            children: [
              TextField
              (
                key: const Key("problemToSolveField"),
                controller: widget.sessionTitleTfec,
                autofocus: true,
                decoration: InputDecoration
                (
                  hintText: gpsProcessTitleTextFieldHint,
                  suffixIcon: IconButton
                  (
                    icon: const Icon(Icons.check, color: greenShade900),
                    onPressed: () => setState(() => _isEditing = false),
                  ),
                ),
                onSubmitted: (_) => setState(() => _isEditing = false),
              ),
              // Suggestions List from previous context analyses session data
              if (widget.previousSessions.isNotEmpty)
                Container(
                  // Limiting the suggestion area height to avoid an overflow
                  // TODO: different maxHeight according to platform
                  constraints: const BoxConstraints(maxHeight: 85), 
                  child: ListView.builder(
                    itemCount: widget.previousSessions.length,
                    itemBuilder: (context, index) {
                      final session = widget.previousSessions[index];
                      return ListTile(
                        title: Text(session["title"]),
                        subtitle: Text("Date: ${session["date"]}"),
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
                  child: Text
                  (
                    // if not an edition, or editing an empty title
                    (widget.titleWhenEdition == "")
                    ? 
                      (widget.sessionTitleTfec.text.trim() == "") 
                      ? 
                        gpsProcessTitlePlaceholder
                      : 
                        widget.sessionTitleTfec.text.trim() 
                    // if an edition
                    : 
                      // value to edit was edited?
                      (widget.sessionTitleTfec.text.trim() != "") 
                      ?
                        widget.sessionTitleTfec.text.trim()
                      :
                        widget.titleWhenEdition,

                    style: 
                      const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                ),
              ),
              
              // Widget 3: Right side
              Container(
                width: 50,
                child: GestureDetector
                (
                  child: const Text(editEmoji),
                  onTap: () => setState(() => _isEditing = true),
                ),
              ),
            ],
          ),
        ),
      );
  }
}