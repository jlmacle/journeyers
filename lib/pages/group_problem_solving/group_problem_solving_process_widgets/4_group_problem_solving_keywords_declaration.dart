import 'package:flutter/material.dart';

import 'package:journeyers/app_themes.dart';
import 'package:journeyers/debug_constants.dart';
import 'package:journeyers/pages/group_problem_solving/group_problem_solving_process_widgets/_group_problem_solving_externalized_variables.dart';
import 'package:journeyers/utils/generic/dev/utility_classes_import.dart';

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
  final TextEditingController _keywordsTfec = .new();
    
  // Method used to add keywords to the _keywords list
  void _keywordAdd(String value, [StateSetter? localSetState]) 
  {
    var trimmedValue = value.trim();
    if (trimmedValue.isNotEmpty && !_keywords!.contains(trimmedValue)) {
      // Updates the underlying data
      setState(() {
        _keywords!.add(trimmedValue);
        _keywordsTfec.clear();
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
    _keywordsTfec.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showKeywordsOverlay(context),
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

  void _showKeywordsOverlay(BuildContext context) {
    const String title = "Keywords for the\nproblem-solving session";

    showGeneralDialog(
      context: context,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: true, 
            title: 
            const Padding
            (
              padding: EdgeInsets.all(16.0), 
              child: Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 20,
                overflow: TextOverflow.visible,
                softWrap: true,
                style: problemSolvingKeywordsMessage,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.close),
                tooltip: closeGPSKeywordsDeclarationTooltipLabel,
                color: appBarWhite,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          body: SafeArea(
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setLocalState) {
                return 
                Column
                (
                  children: 
                  [                     
                    Padding
                    (
                      padding: const EdgeInsets.only(left:20, right:20, top:10, bottom:0),
                      child: TextField
                      (
                        key: const Key("gpsKeywordsField"),
                        controller: _keywordsTfec,
                        decoration: const InputDecoration
                        (
                          hint: Center
                          (
                            child: 
                            Text(textAlign: TextAlign.center, 'Please enter the keywords here.\n(+ Enter key)', style: analysisTextFieldHintStyle)
                          )
                        ),
                        textAlign: TextAlign.center,
                        style: analysisTextFieldStyle,
                        onSubmitted: (value) => _keywordAdd(value, setLocalState),
                      ),
                    ),
                    // Display of the keywords
                    Center
                    (
                      child: Padding
                      (
                        padding: const EdgeInsets.only(bottom: 0),
                        child: Wrap
                        (
                          spacing: 8.0,
                          runSpacing: 4.0,
                          children: 
                          [
                            ..._keywords!.map
                            (
                              (tag) => InputChip
                                      (
                                        label: Text(tag),
                                        deleteIcon: const Icon(Icons.close),
                                        deleteIconColor: appBarWhite,
                                        onDeleted: () 
                                        {
                                          setState( () {_keywords!.remove(tag);});
                                          setLocalState(() {});
                                          widget.onKeywordsUpdatedCallbackFunction(_keywords!);
                                        },
                                        
                                      )
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ); 
              },
            ),
          ),
        );
      },
    );
  }
}