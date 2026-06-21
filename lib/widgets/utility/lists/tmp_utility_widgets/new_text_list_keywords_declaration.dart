import 'package:flutter/material.dart';

import 'package:journeyers/app_themes.dart';
import 'package:journeyers/pages/group_problem_solving/group_problem_solving_process_widgets/_group_problem_solving_externalized_variables.dart';

/// {@category Lists}
/// A widget used to declare keywords, or to retrieve keywords from previous context analyses.
class NewTextListKeywordsDeclaration extends StatefulWidget 
{
  /// The keywords associated to the session data.
  final Set<String> currentKeywords;

  /// A callback function called to update the keywords describing the session.
  final ValueChanged<Set<String>> onKeywordsUpdatedCallbackFunction;  

  const NewTextListKeywordsDeclaration
  ({
    super.key,
    required this.currentKeywords,
    required this.onKeywordsUpdatedCallbackFunction
  });


  @override
  State<NewTextListKeywordsDeclaration> createState() => _NewTextListKeywordsDeclarationState();
}

class _NewTextListKeywordsDeclarationState extends State<NewTextListKeywordsDeclaration> 
{
  // Initializes with the passed keywords instead of an empty list
  Set<String>? _keywords;
  final TextEditingController _keywordsController = .new();
    
  // Method used to add keywords to the _keywords list
  void _addKeyword(String value, [StateSetter? localSetState]) 
  {
    var trimmedValue = value.trim();
    if (trimmedValue.isNotEmpty && !_keywords!.contains(trimmedValue)) {
      // Updates the underlying data
      setState(() {
        _keywords!.add(trimmedValue);
        _keywordsController.clear();
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
    _keywords = Set.from(widget.currentKeywords); // Syncs at start
  }

  @override
  void didUpdateWidget(NewTextListKeywordsDeclaration oldWidget) {
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
    _keywordsController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showKeywordsOverlay(context),
      child: Container(        
        padding: const EdgeInsets.symmetric(vertical: 10),
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
    const String title = "Please enter keywords\n related to this group.";

    showGeneralDialog(
      context: context,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: true, 
            // automaticallyImplyLeading : false,
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
                tooltip: closeKeywordsDeclarationTooltipLabel,
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
                        key: const ValueKey('keywordField'),
                        controller: _keywordsController,
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
                        onSubmitted: (value) => _addKeyword(value, setLocalState),
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
                                        onDeleted: () 
                                        {
                                          setState( () {_keywords!.remove(tag);});
                                          setLocalState(() {});
                                          widget.onKeywordsUpdatedCallbackFunction(_keywords!);
                                        }, 
                                        deleteIconColor: appBarWhite,
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