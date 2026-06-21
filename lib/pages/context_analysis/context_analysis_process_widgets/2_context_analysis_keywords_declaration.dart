import 'package:flutter/material.dart';

import 'package:journeyers/app_themes.dart';
import 'package:journeyers/debug_constants.dart';
import 'package:journeyers/utils/generic/dev/utility_classes_import.dart';

/// {@category Context analysis}
/// A widget used for keywords declaration in the context analysis process.
class CAKeywordsDeclaration extends StatefulWidget 
{
  /// A keywords value at edition time.
  final Set<String> keywordsForEdition;

  /// A callback function called to update the keywords describing the session.
  final ValueChanged<Set<String>> onKeywordsUpdatedProcessCallbackFunction;

  const CAKeywordsDeclaration
  ({
    super.key,
    required this.keywordsForEdition,
    required this.onKeywordsUpdatedProcessCallbackFunction
  });

  @override
  State<CAKeywordsDeclaration> createState() => _CAKeywordsDeclarationState();
}

class _CAKeywordsDeclarationState extends State<CAKeywordsDeclaration> 
{

  final Set<String> _keywordsSet = {};
  List<String> _keywordsListSorted = [];
  final TextEditingController _keywordsTfec = .new();
    
  // Method used to add keywords to the _keywords list
  void _keywordAdd(String value)
  {
    var trimmedValue = value.trim();

    if (trimmedValue.isNotEmpty && !_keywordsSet.contains(trimmedValue))
    {
      // Adding the value to the set to avoid duplication
      _keywordsSet.add(trimmedValue);

      // Sorting the list created from the set by alphabetical order
      _keywordsListSorted = _keywordsSet.toList();
      _keywordsListSorted.sort();

      _keywordsTfec.clear();
      
      setState(() {});
    }
    widget.onKeywordsUpdatedProcessCallbackFunction(_keywordsSet);
  }

  @override
  void initState() {
    super.initState();
    _keywordsListSorted = widget.keywordsForEdition.toList();
    if (editDebug) pu.printd("Editing: _CAKeywordsDeclarationState: initState: _keywordsListSorted: $_keywordsListSorted");
  }

  @override
  void dispose()
  {
    _keywordsTfec.dispose();
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
            controller: _keywordsTfec,
            decoration: const InputDecoration
            (
              hint: Center
              (
                child: 
                Text(textAlign: TextAlign.center, 'Please enter keywords\nto describe the analysis.\n(+ Enter key)', style: analysisTextFieldHintStyle)
              )
            ),
            textAlign: TextAlign.center,
            style: analysisTextFieldStyle,
            onSubmitted: _keywordAdd,
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
                // List used to build the input chips
                ..._keywordsListSorted.map
                (
                  (tag) => 
                  InputChip
                  (
                    label: Text(tag),
                    onDeleted: () 
                    {
                      // Removal from the reference set
                      setState( () 
                      {
                        
                        _keywordsSet.remove(tag);                        
                        _keywordsListSorted.removeWhere((item) => item == tag);

                        if (editDebug) pu.printd("Editing: _CAKeywordsDeclarationState: build: _keywordsSet: $_keywordsSet");               
                        if (editDebug) pu.printd("Editing: _CAKeywordsDeclarationState: build: _keywordsListSorted: $_keywordsListSorted");               
                      });
                      widget.onKeywordsUpdatedProcessCallbackFunction(_keywordsSet);
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