import 'package:flutter/material.dart';
import 'package:journeyers/app_themes.dart';

/// {@category Context analysis}
/// A widget used for keywords declaration in the context analysis process.
class ContextAnalysisKeywordsDeclaration extends StatefulWidget 
{
  /// A callback function called to update the keywords describing a session.
  final ValueChanged<List<String>> keywordsUpdatedCallbackFunction;

  const ContextAnalysisKeywordsDeclaration
  ({
    super.key,
    required this.keywordsUpdatedCallbackFunction
  });

  @override
  State<ContextAnalysisKeywordsDeclaration> createState() => _ContextAnalysisKeywordsDeclarationState();
}

class _ContextAnalysisKeywordsDeclarationState extends State<ContextAnalysisKeywordsDeclaration> 
{

  final List<String> _keywords = [];
  final TextEditingController _keywordsController = TextEditingController();
    
  // Method used to add keywords to the _keywords list
  void addKeyword(String value)
  {
    var trimmedValue = value.trim();
    if (trimmedValue.isNotEmpty && !_keywords.contains(trimmedValue))
    {
      setState(() 
      {
        _keywords.add(trimmedValue);
        _keywordsController.clear();
      });
    }
    widget.keywordsUpdatedCallbackFunction(_keywords);
  }

  @override
  void dispose()
  {
    _keywordsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column
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
                Text(textAlign: TextAlign.center, 'Please enter keywords\nto describe the analysis.\n(+ Enter key).', style: analysisTextFieldHintStyle)
              )
            ),
            textAlign: TextAlign.center,
            style: analysisTextFieldStyle,
            onSubmitted: addKeyword,
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
    // TODO: to offer pre-defined keywords as well (household, workplace, studies)
  }
}