import "package:flutter/material.dart";

import "package:journeyers/app_themes.dart";
import "package:journeyers/debug_constants.dart";
import "package:journeyers/l10n/app_localizations.dart";
import "package:journeyers/pages/group_problem_solving/group_problem_solving_process_widgets/_group_problem_solving_externalized_variables.dart";
import "package:journeyers/utils/generic/dev/utility_classes_import.dart";

/// {@category Group problem-solving}
/// A widget used to define the problem to solve, or to retrieve a title from previous context analyses. In the latter case, (gps) is added in suffix.
class GPSProblemToSolveDeclaration extends StatefulWidget {
  /// The title value at edition time.
  final String titleWhenEdition;
  /// A TextEditingController for the session title.
  final TextEditingController sessionTitleTec;
  /// The data from the previous context analyses sessions (for title import).
  final List<Map<String, dynamic>> caPreviousSessions;
  /// A callback function used when a previous context analysis session data is selected.
  final Function(Map<String, dynamic>) onSessionSelected;
  /// A callback function used when entering title edit mode (title tapped, or edit emoji tapped).
  final VoidCallback onTitleTapped;
  /// A callback function used when the text field loses focus.
  final VoidCallback onTextFieldLosingFocus;
  /// A boolean used to state if the title is being edited.
  final bool isEditMode;

  const GPSProblemToSolveDeclaration({
    super.key,
    this.titleWhenEdition = "",
    required this.sessionTitleTec,
    this.isEditMode = false,
    required this.caPreviousSessions,
    required this.onSessionSelected,
    required this.onTitleTapped,
    required this.onTextFieldLosingFocus,
  });

  @override
  State<GPSProblemToSolveDeclaration> createState() => _GPSProblemToSolveDeclarationState();
}

class _GPSProblemToSolveDeclarationState extends State<GPSProblemToSolveDeclaration> 
{
  bool _isEditMode = false;

  final FocusNode _textFieldFocusNode = .new();


  void _enterEditMode()
  {
    setState(() => _isEditMode = true);
    widget.onTitleTapped();
  }

  @override
  void initState() {
    super.initState();
    
    if (widgetSequenceDebug) pu.printdLine();
    if (widgetSequenceDebug) pu.printd("GPSProblemToSolveDeclaration");

    if (widget.titleWhenEdition != "") widget.sessionTitleTec.text = widget.titleWhenEdition;
  }

  @override
  void dispose() {
    _textFieldFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isEditMode || widget.isEditMode
      ? Column(
          children: [
            TextField
            (
              key: const Key("problemToSolveField"),
              controller: widget.sessionTitleTec,
              autofocus: true,
              focusNode: _textFieldFocusNode,
              decoration: InputDecoration
              (
                hintText: gpsProcessTitleTextFieldHint,
                suffixIcon: IconButton
                (
                  icon: const Icon(Icons.check, color: greenShade900),
                  onPressed: ()
                  {                      
                    setState(() => _isEditMode = false);
                    widget.onTextFieldLosingFocus();
                  },
                ),
              ),
              onSubmitted: (_) 
              { 
                    setState(() => _isEditMode = false);
                    widget.onTextFieldLosingFocus();
              },
            ),

            // Suggestions List from previous context analyses session data
            if (widget.caPreviousSessions.isNotEmpty)
               Expanded(
                child:
                ListView.builder(
                  itemCount: widget.caPreviousSessions.length,
                  itemBuilder: (context, index) {
                    final session = widget.caPreviousSessions[index];
                    return ListTile(
                      title: Text(session["title"]),
                      subtitle: Text("Date: ${session["date"]}"),
                      onTap: () {
                        widget.onSessionSelected(session);
                        setState(() => _isEditMode = false);
                        widget.onTextFieldLosingFocus();
                      },
                    );
                  },
                ),
              ),
          ],
        )
        : 
        GestureDetector(
          onTap: _enterEditMode,
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
                  key: const Key("gps-process-gpsproblemtosolvedeclaration-title-text"),
                  // if not an edition, or editing an empty title
                  (widget.titleWhenEdition == "")
                  ? 
                    (widget.sessionTitleTec.text.trim() == "") 
                    ? 
                      AppLocalizations.of(context)?.gps_process_default_title ?? "Issue with the default title for a problem-solving session."
                    : 
                      widget.sessionTitleTec.text.trim() 
                  // if an edition
                  : 
                    // value to edit was edited?
                    (widget.sessionTitleTec.text.trim() != "") 
                    ?
                      widget.sessionTitleTec.text.trim()
                    :
                      widget.titleWhenEdition,
    
                  style: 
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            
            // Widget 3: Right side
            SizedBox(
              width: 50,
              child: GestureDetector
              (
                child: 
                  Tooltip
                  (
                    message: AppLocalizations.of(context)?.gps_process_edit_title_tooltip ?? "Issue with the l10n for the 'Please click to edit the title' tooltip",
                    child: const Text(editEmoji)
                  ),
                onTap: _enterEditMode,
              ),
            ),
          ],
        ),
      );
  }
}