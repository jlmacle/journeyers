import 'package:flutter/material.dart';

import 'package:journeyers/app_themes.dart';
import 'package:journeyers/debug_constants.dart';
import 'package:journeyers/pages/group_problem_solving/group_problem_solving_process_widgets/_group_problem_solving_externalized_variables.dart';
import 'package:journeyers/utils/generic/dev/utility_classes_import.dart';
import 'package:journeyers/widgets/custom/interaction_and_inputs/editable_deletable_text_list_item.dart';
import 'package:journeyers/widgets/utility/lists/tmp_utility_widgets/new_text_list_deletion_by_bulk.dart';

/// {@category Group problem-solving}
/// A widget used to list the ideas found during a group problem-solving process.
class GPSIdeasList extends StatefulWidget 
{
  /// The ideas for the group problem-solving process.
  final List<String> ideas;

  const GPSIdeasList({super.key, required this.ideas});

  @override
  State<GPSIdeasList> createState() => _GPSIdeasListState();
}

class _GPSIdeasListState extends State<GPSIdeasList> {

  // Data related to deleting texts from the new list
  bool _ideasAreSomeForDeletion = false;  
  final List<int> _ideasSelectedForDeletionIndexes = [];
  late final List<String> _ideasEnteredList;  
  final _ideaNewTfec = TextEditingController();


  void _ideaOnUpdateTheValue({required String stringParam, required int intParam})
  {
    setState(() {
      _ideasEnteredList[intParam] = stringParam;
      if (editDebug) pu.printd("Editing: GPSIdeasList: onUpdateTheIdeaValue: _enteredIdeasList (updated): $_ideasEnteredList");
    });  
  }

  @override
  void initState() {
    super.initState();
                    
    if (widgetSequenceDebug) pu.printdLine();
    if (widgetSequenceDebug) pu.printd("GPSIdeasList");
    
    _ideasEnteredList = widget.ideas;
  }

  @override
  void dispose() {
    _ideaNewTfec.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector
    (    
      onTap: ()
             {
              // List edition if list not empty
              if (widget.ideas.isNotEmpty)
              {
                _ideasShowEditOverlay(context);
              }
             },
      child : 
      Column(
        children: [
           ListTile(
              leading: const Icon(Icons.add_circle_outline),
              title: const Text(ideasListTitle, style: problemSolvingIdeasTitle),              
              onTap: () => _ideasShowEditOverlay(context),
            ),
          const SizedBox(height: 10),
          if (widget.ideas.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(ideasListPlaceholder, style: TextStyle(fontStyle: FontStyle.italic)),
            ),
          
          ...widget.ideas.asMap().entries.map(
          (entry) {
            final index = entry.key;
            final idea = entry.value;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
              child: Card(
                child: ListTile(
                  leading: const Icon(Icons.edit),
                  title: Text(
                    key: ValueKey('idea-$index'), // Use the index in the key
                    idea,
                  ),
                ),
              ),
            );
          },
        ),
        ],
      )

    );
  }


  // Method used to display an overlay with the ideas to edit. 
  void _ideasShowEditOverlay(BuildContext context) 
  {
    
    showGeneralDialog
    (
      context: context,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) 
      {
        return Scaffold
        (
          appBar:AppBar
          (
            centerTitle: true, 
            title: 
            const Text
            (
              textAlign: TextAlign.center, maxLines:20, overflow: TextOverflow.visible, 
              softWrap:true, 'Ideas List', style: previewTitleStyle
            ),
 
            // Right side: Close Button
            actions: [
              IconButton(
                icon: const Icon(Icons.close),
                color: appBarWhite,
                onPressed: () => Navigator.of(context).pop(),
                tooltip: overlayClosingTooltip,
              ),
            ],
          ),
          body: 
          SafeArea(
            child:  
            StatefulBuilder(
              builder: (BuildContext context, StateSetter setLocalState) 
              {   
                return      
                Column(
                  children: [
                    NewTextListDeletionByBulk
                      (
                        areSomeTextItemsSelectedForDeletion: _ideasAreSomeForDeletion,
                        enteredTextItemsList: _ideasEnteredList,
                        textItemsSelectedForDeletionIndexes: _ideasSelectedForDeletionIndexes,
                        callbackFunctionToRefreshTheList: 
                        () 
                        {
                          setLocalState((){});
                          setState(() {_ideasAreSomeForDeletion = false;});
                        }
                      ),
                    // List of added texts or placeholder message
                    Expanded(
                      child: 
                        ListView.builder
                            (                  
                              padding: const EdgeInsets.only(bottom: 96),
                              itemCount: widget.ideas.length,
                              itemBuilder: (_, index) 
                              {
                                return 
                                  
                                    EditableDeletableTextListItem
                                    (
                                      key: ValueKey(widget.ideas[index]),
                                      itemIndex: index, 
                                      itemText: widget.ideas[index], 
                                      onCheckboxChangedCallbackFunction: ({required bool? boolParam, required int intParam}) 
                                                                          { 
                                                             
                                                                            if(boolParam!) 
                                                                            {                                                                    
                                                                              // adding the index to _ideasSelectedForDeletionIndexes
                                                                              _ideasSelectedForDeletionIndexes.add(index);
                                                                              _ideasSelectedForDeletionIndexes.sort();
                                                                              _ideasAreSomeForDeletion = true;                                    
                                                                              
                                                                              setLocalState(() {});
                                                                            }
                                                                            else{
                                                                              _ideasSelectedForDeletionIndexes.remove(index);
                                                                              if (_ideasSelectedForDeletionIndexes.isEmpty) _ideasAreSomeForDeletion = false;
                                                                              
                                                                              setLocalState(() {});
                                                                            }
                                                                            if (editDebug) pu.printd("Editing: GPSIdeasList: onCheckboxChangedCallbackFunction: _ideasSelectedForDeletionIndexes : $_ideasSelectedForDeletionIndexes");
                                                                          }, 
                                      // parentCallbackFunctionToUpdateTheListItemValue: onUpdateTheIdeaValue,
                                      parentCallbackFunctionToUpdateTheListItemValue: 
                                      ({required intParam, required stringParam}) 
                                      {
                                        setLocalState(() {});
                                        _ideaOnUpdateTheValue(stringParam: stringParam, intParam: intParam);
                                      },
                                      parentCallbackFunctionToUpdateTheListOfItemsSelectedForDeletion: (index){_ideasSelectedForDeletionIndexes.add(index);}, 
                                      themeData: Theme.of(context),                          
                                    )                          
                                  ;
                              },
                            )
                    ),
                    // TextField used to add a new text
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField
                      (
                        key: const ValueKey('ideaOverlayTextField'),
                        controller: _ideaNewTfec,
                        textAlign: TextAlign.left,
                        decoration: const InputDecoration
                        (
                          hint: Text
                          ( 
                            newIdeaTextFieldHint,
                            textAlign: TextAlign.left,                                          
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),                  
                        ),
                        onSubmitted: (value)
                        {
                          setLocalState(() {
                            _ideasEnteredList.add(value.trim());
                          });
                          setState(() {
                            
                          });
                          _ideaNewTfec.clear();
                          if (editDebug) pu.printd("Editing: GPSIdeasList: _showEditOverlay: onSubmitted: _enteredIdeasList : $_ideasEnteredList");
                        },
                      ),
                    ),
                  ]
              );
              }
          ),
        )
        );
      }
    );
  }


}