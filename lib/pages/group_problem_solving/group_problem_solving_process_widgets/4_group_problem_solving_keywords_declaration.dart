import "package:flutter/material.dart";

import "package:journeyers/app_themes.dart";
import "package:journeyers/debug_constants.dart";
import "package:journeyers/pages/group_problem_solving/group_problem_solving_process_widgets/_group_problem_solving_externalized_variables.dart";
import "package:journeyers/utils/generic/dev/utility_classes_import.dart";
import "package:journeyers/utils/generic/sheets_and_overlays/sheets_and_overlays_utils.dart";

/// {@category Group problem-solving}
/// A widget used to declare keywords, or to retrieve keywords from previous context analyses.
class GPSKeywordsDeclaration extends StatefulWidget 
{
  /// The keywords value at edition time.
  final Set<String> keywordsWhenEdition;

  /// The keywords associated to the session data.
  final Set<String> currentKeywords;

  /// A callback function called to update the keywords describing the session.
  final ValueChanged<Set<String>> onKeywordsUpdatedCallbackFunction;  

  const GPSKeywordsDeclaration
  ({
    super.key,
    this.keywordsWhenEdition = const {},
    required this.currentKeywords,
    required this.onKeywordsUpdatedCallbackFunction
  });


  @override
  State<GPSKeywordsDeclaration> createState() => _GPSKeywordsDeclarationState();
}

class _GPSKeywordsDeclarationState extends State<GPSKeywordsDeclaration> 
{
  // Initializes with the passed keywords instead of an empty list
  Set<String>? _keywords;
  final TextEditingController _keywordsTec = .new();
    
  // Method used to add keywords to the _keywords list
  void _keywordAdd(String value, [StateSetter? localSetState]) 
  {
    var trimmedValue = value.trim();
    if (trimmedValue.isNotEmpty && !_keywords!.contains(trimmedValue)) {
      // Updates the underlying data
      setState(() {
        _keywords!.add(trimmedValue);
        _keywordsTec.clear();
      });
      
      // Redraws the Dialog/Overlay
      if (localSetState != null) {
        localSetState(() {});
      }
      
      widget.onKeywordsUpdatedCallbackFunction(_keywords!);
    }
  }

  @override
  void initState() {
    super.initState();
                
    if (widgetSequenceDebug) pu.printdLine();
    if (widgetSequenceDebug) pu.printd("GPSKeywordsDeclaration");

    if (widget.keywordsWhenEdition.isNotEmpty) 
      { 
        _keywords = widget.keywordsWhenEdition; 
        if (editDebug) pu.printd("Editing: GPSKeywordsDeclaration: initState: widget.keywordsWhenEdition.isNotEmpty: _keywords: $_keywords");
      }
    else
    { 
      _keywords = Set.from(widget.currentKeywords); 
    }
  }

  @override
  void didUpdateWidget(GPSKeywordsDeclaration oldWidget) {
    if (widgetSequenceDebug) pu.printdLine();
    if (widgetSequenceDebug) pu.printd("GPSKeywordsDeclaration: didUpdateWidget");

    super.didUpdateWidget(oldWidget);
    
    // Checks if the pointer or the content of the list has changed
    if (widget.currentKeywords != oldWidget.currentKeywords) {
      setState(() {
        // Creates a fresh copy from the new parent data
        _keywords = Set<String>.from(widget.currentKeywords);
      });
    }
  }

  @override
  void dispose()
  {
    _keywordsTec.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showAddToSetOverlay
                    (
                      context: context, 
                      overlayTitle: "Keywords for the\nproblem-solving session", 
                      overlayTitleStyle: problemSolvingKeywordsTitleStyle, 
                      overlayCloseIconButtonToolTip: gpsKeywordsDeclarationOverlayCloseIconButtonToolTip, 
                      overlayCloseIconButtonColor: appBarWhite,
                      textEditingControllerKey: const Key("gpsKeywordsField"), 
                      textEditingController: _keywordsTec, 
                      textFieldStyle: analysisTextFieldStyle, 
                      textFieldHintText: "Please enter the keywords here.\n(+ Enter key)", 
                      textFieldHintStyle: analysisTextFieldHintStyle, 
                      onSubmittedCallbackFunction: (value, setLocalState) => _keywordAdd(value, setLocalState), 
                      setToUpdate: _keywords!, 
                      inputChipDeleteIconColor: appBarWhite,
                      onDeletedCallbackFunction: (tag, localSetState) 
                                                  {
                                                    setState( () {_keywords!.remove(tag);});
                                                    localSetState(() {});
                                                    widget.onKeywordsUpdatedCallbackFunction(_keywords!);
                                                  }                   
                    ),
      child: Container(        
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(right: 15),
              child: Icon(Icons.style_rounded),
            ),
            Center(
              child: Text(keywordsDeclarationTitle, style: problemSolvingKeywordsTitle),
            )
          ],
        ),
      ),
    );
  }


}