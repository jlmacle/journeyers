import 'package:flutter/material.dart';

import 'package:journeyers/app_themes.dart';

/// {@category Group problem-solving}
/// A widget used to declare keywords, or to retrieve keywords, from previous context analyses.
class GroupProblemSolvingKeywords extends StatefulWidget 
{
  /// The keywords associated to the session data.
  final List<String> currentKeywords;

  /// A callback function called to update the keywords describing a session.
  final ValueChanged<List<String>> keywordsUpdatedCallbackFunction;  

  const GroupProblemSolvingKeywords
  ({
    super.key,
    required this.currentKeywords,
    required this.keywordsUpdatedCallbackFunction
  });


  @override
  State<GroupProblemSolvingKeywords> createState() => _GroupProblemSolvingKeywordsState();
}

class _GroupProblemSolvingKeywordsState extends State<GroupProblemSolvingKeywords> 
{
  // Initializes with the passed keywords instead of an empty list
  late List<String> _keywords;
  final TextEditingController _keywordsController = TextEditingController();
    
  // Method used to add keywords to the _keywords list
  void addKeyword(String value, [StateSetter? localSetState]) 
  {
    var trimmedValue = value.trim();
    if (trimmedValue.isNotEmpty && !_keywords.contains(trimmedValue)) {
      // Updates the underlying data
      setState(() {
        _keywords.add(trimmedValue);
        _keywordsController.clear();
      });
      
      // Redraws the Dialog/Overlay
      if (localSetState != null) {
        localSetState(() {});
      }
      
      widget.keywordsUpdatedCallbackFunction(_keywords);
    }
  }

  @override
  void initState() {
    super.initState();
    _keywords = List.from(widget.currentKeywords); // Syncs at start
  }

  @override
  void didUpdateWidget(GroupProblemSolvingKeywords oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Checks if the pointer or the content of the list has changed
    if (widget.currentKeywords != oldWidget.currentKeywords) {
      setState(() {
        // Creates a fresh copy from the new parent data
        _keywords = List<String>.from(widget.currentKeywords);
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
              child: Text("Keywords", style: problemSolvingKeywordsTitle),
            )
          ],
        ),
      ),
    );
  }

  void _showKeywordsOverlay(BuildContext context) {
    const String title = "Please enter keywords\nto describe the analysis.";

    showGeneralDialog(
      context: context,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: true, 
            automaticallyImplyLeading : false,
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
                        controller: _keywordsController,
                        decoration: const InputDecoration
                        (
                          hint: Center
                          (
                            child: 
                            Text(textAlign: TextAlign.center, 'Please enter the keywords here. \n(+ Enter key).', style: analysisTextFieldHintStyle)
                          )
                        ),
                        textAlign: TextAlign.center,
                        style: analysisTextFieldStyle,
                        onSubmitted: (value) => addKeyword(value, setLocalState),
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
                            ..._keywords.map
                            (
                              (tag) => InputChip
                                      (
                                        label: Text(tag),
                                        onDeleted: () 
                                        {
                                          setState( () {_keywords.remove(tag);});
                                          setLocalState(() {});
                                          widget.keywordsUpdatedCallbackFunction(_keywords);
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