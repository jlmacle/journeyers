import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../custom_generic_widgets/editable_deletable_text_list_item.dart';
import '../custom_generic_widgets/text_list_item_deletion_by_bulk.dart';
import '../models/text_lists_storage_externalized_strings.dart';

import '../models/text_lists_storage.dart';

/// Class used to add a text list to a set of text lists.
/// A new list can be saved only if its content is not identical to a previous list content.
/// The widget can be used to load a list for edition.
class AdditionToTextLists extends StatefulWidget 
{
  /// Pre-populated content (from a loaded list).
  final List<String> initialTextValues;

  /// When non-null the screen is read-only and shows this label in the title.
  final String? loadedLabel;

  /// The hint text when saving the list label.
  final String listLabelHintText;

  /// The text inviting to enter a new text in the list.
  final String invitationToEnterTextPlaceholder;

  /// The placeholder text for the new list.
  final String listPlaceholder;

  /// The theme data used.
  final ThemeData themeData;

  const AdditionToTextLists({
    super.key,
    this.initialTextValues = const [],
    this.loadedLabel,
    required this.listLabelHintText,
    required this.listPlaceholder,
    required this.invitationToEnterTextPlaceholder,
    required this.themeData
  });  

  @override
  State<AdditionToTextLists> createState() => _AdditionToTextListsState();
}

class _AdditionToTextListsState extends State<AdditionToTextLists> {

  // bool: a list has been loaded
  bool get _listHasBeenLoaded => widget.loadedLabel != null;

  // Data related to retrieving the list of grouped texts
  final _textListsDB = TextListsDB();
  bool _loadingDB = true;
  String? _errorLoadingDB;
  List<List<String>>? _listOfPreviousGroupedTexts = [];

  // Used to load the list of grouped texts
  Future<void> _loadListOfPreviousGroupedTexts() async {
    setState(() {
      _loadingDB = true;
      _errorLoadingDB = null;
    });
    try {

      List<List<String>> listOfGroupedTexts = await _textListsDB.listOfGroupedTexts(); 

      setState(() {
        _listOfPreviousGroupedTexts = listOfGroupedTexts;
        _loadingDB = false;
        print("_loadListOfGroupedTexts: _listOfGroupedTexts: $_listOfPreviousGroupedTexts");
      });
    } catch (e) {
      setState(() {
        print(e);
        _errorLoadingDB = e.toString();
        _loadingDB = false;
      });
    }
  }

  
  // Data used to adding a text to the list
  var _tecNewText = TextEditingController();
  // To store the new grouped texts data
  late final List<String> _enteredTextItemsList;

  // Data used to edit a text after addition to the list
  var _isEdited = false;
  var _editedIndex = -1;
  var _tecTextEdition = TextEditingController();

  // Data related to deleting texts from the new list
  List<String> _textsSelectedForDeletion = [];
  List<int> _textsSelectedForDeletionIndexes = [];
  bool _areSomeTextItemsForDeletion = false;  

  // Data related to saving the added texts in a list
  // True once the current list has been persisted.
  bool _isSaved = false;
  // True while an async save is in progress (prevents double-tap).
  bool _saving = false;
  // For entering the list label
  var _tecListLabel = TextEditingController();

  // Method used to verify if the newly entered texts have been already saved in a list
  bool listOfPreviousGroupedTextsContainsNewListData(List<List<String>> listOfPreviousGroupedTexts, List<String> newListData)
  {
    bool val = _listOfPreviousGroupedTexts!.any((list) => listEquals(list, _enteredTextItemsList));
    return val;
  }

  bool get canSave =>
      // list has not been loaded from existant list
      !_listHasBeenLoaded 
      // at least one text has been added
      && _enteredTextItemsList.isNotEmpty 
      // added texts are not matching a saved list content
      && !listOfPreviousGroupedTextsContainsNewListData(_listOfPreviousGroupedTexts!, _enteredTextItemsList)  
      // the new list hasn't been saved yet
      && !_isSaved ;

  /// Shows a dialog that asks for a list label.
  /// Requires for the label to not be used already.
  Future<String?> _showListLabelDialog() async {

    String? errorText;

    return showDialog<String>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {

            Future<void> onConfirm() async {
              final label = _tecListLabel.text.trim();
              if (label.isEmpty) {
                setDialogState(() => errorText = 'Label cannot be empty.');
                return;
              }
              // Warn if the label already exists, and prevents the saving of data.
              final listLabelAlreadyExists = await _textListsDB.listLabelExistsAsync(label);
              if (!ctx.mounted) return;
              if (listLabelAlreadyExists) {
                setDialogState(
                  () => errorText = '"$label" already exists. Please choose another.',
                );
                return;
              }
              Navigator.of(ctx).pop(label);
            }

            return AlertDialog(
              title: const Text('Save list'),
              content: TextField(
                controller: _tecListLabel,
                autofocus: true,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) async => await onConfirm(), 
                decoration: InputDecoration(
                  labelText: 'List label',
                  hintText: widget.listLabelHintText,
                  errorText: errorText,
                ),
                onChanged: (_) {
                  // List label non empty or list label modified 
                  if (errorText != null) {
                    setDialogState(() => errorText = null);
                  }
                },
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: onConfirm,
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Method used to save the grouped texts in a list
  Future<void> _saveGroupedTextsList() async {

    // Opening a dialog to enter the list label
    final listLabel = await _showListLabelDialog();

    if (listLabel == null) return; // for user cancellation

    setState(() => _saving = true);

    try {
      // List.from(_enteredTextItemsList)..sort() : 
      // to sort at saving time, without re-ordering the texts on-screen
      await _textListsDB.saveListData(listLabel, List.from(_enteredTextItemsList)..sort());      

      setState(() {
        _isSaved = true;
        _saving = false;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar
      (
        SnackBar(content: Text('Saved as "$listLabel"')),
      );
    } catch (e) 
    {
      setState(() => _saving = false);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar
      (
        SnackBar(content: Text('Save failed: $e')),
      );
    }
  }


  @override
  void initState() {
    super.initState();
    // Loading the previous lists of grouped texts
    _loadListOfPreviousGroupedTexts();
    
    _enteredTextItemsList = List<String>.from(widget.initialTextValues);
  }

  // Disposing of the TextEditingController instances
  @override
  void dispose() {
    _tecNewText.dispose();
    _tecTextEdition.dispose();
    _tecListLabel.dispose();
    super.dispose();
  }

  void onUpdateTheListItemValue({required String stringParam, required int intParam})
  {
    setState(() {
      _enteredTextItemsList[intParam] = stringParam;
    });  
  }


  @override
  Widget build(BuildContext context) {

    if (_loadingDB) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorLoadingDB != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Error loading the lists:\n$_errorLoadingDB',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return 
      _loadingDB
      ? const Center(child: CircularProgressIndicator())
      : Scaffold(
        appBar: AppBar(
          title: Text(_listHasBeenLoaded ? widget.loadedLabel! : 'New list'),
          actions: [
            // If data can be saved
            if (canSave) 
            ...
            [
              _saving
                  // Currently saving data
                  ? const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  // Potentially saving data
                  : IconButton(
                      tooltip: 'Save list',
                      icon: const Icon(Icons.save_outlined),
                      onPressed: _saveGroupedTextsList,
                    ),
            ]
            else 
            // Otherwise
            ...
            [
              // to avoid 'List already saved' at new list declaration
              if (_enteredTextItemsList.isNotEmpty)
                const Padding(
                  padding: EdgeInsets.only(right: 8.0),
                  child: Text('List already saved', ),
                )
            ]            
          ],
        ),

        // ── Texts display ──────────────────────────────────────────────────
        body: 
          Column
          (
            children: 
            [
              TextListItemDeletionByBulk
              (
                areSomeTextItemsSelectedForDeletion: _areSomeTextItemsForDeletion,
                enteredTextItemsList: _enteredTextItemsList,
                indexesOfTextItemsSelectedForDeletion: _textsSelectedForDeletionIndexes,
                callbackFunctionToRefreshTheTextItemsList: () {setState(() {_areSomeTextItemsForDeletion = false;});}
              ),
              // List of added texts or placeholder message
              Expanded(
                child: 
                  _enteredTextItemsList.isEmpty
                  // Placeholder message if empty list
                  ? Center(
                      child: Text(
                        widget.listPlaceholder,
                        textAlign: TextAlign.center,
                        style: widget.themeData.textTheme.bodyLarge
                      ),
                    )
                  :
                        
                  // List of added texts otherwise             
                  ListView.builder
                  (                  
                    padding: const EdgeInsets.only(bottom: 96),
                    itemCount: _enteredTextItemsList.length,
                    itemBuilder: (_, index) 
                    {
                      return 
                        // Text field (edition mode), or ListTile (reading mode)
                        _isEdited && (index == _editedIndex)                        
                          ?
                          // Text field (edition mode)
                          TextField
                          (
                            controller: _tecTextEdition,
                            autofocus: true,
                            decoration: const InputDecoration
                            (                    
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            textAlign: TextAlign.left,
                            onSubmitted: 
                              (value) => setState(() 
                              {
                                _enteredTextItemsList[index] = value; 
                                _isEdited = false;
                                _tecTextEdition.clear();
                              }),
                            
                          )
                          // ListTile (reading mode)
                          : 
                          EditableDeletableTextListItem
                          (
                            itemIndex: index, 
                            itemText: _enteredTextItemsList[index], 
                            onCheckboxChangedCallbackFunction: ({required bool? boolParam, required int intParam}) 
                                                                { 
                                                                  print("value: $boolParam");   
                                                                  print("index: $intParam");                                                               
                                                                  if(boolParam!) 
                                                                  {                                                                    
                                                                    // adding the index to _textsSelectedForDeletionIndexes
                                                                    _textsSelectedForDeletionIndexes.add(index);
                                                                    _textsSelectedForDeletionIndexes.sort();
                                                                    _areSomeTextItemsForDeletion = true;

                                                                    // setState // to do later at bulk widget level
                                                                    setState(() {
                                                                      
                                                                    });
                                                                  }
                                                                  else{
                                                                     _textsSelectedForDeletionIndexes.remove(index);
                                                                     if (_textsSelectedForDeletionIndexes.isEmpty) _areSomeTextItemsForDeletion = false;
                                                                    // setState // to do later at bulk widget level
                                                                    setState(() {
                                                                      
                                                                    });
                                                                  }
                                                                  print("_textsSelectedForDeletionIndexes: $_textsSelectedForDeletionIndexes");
                                                                }, 
                            parentCallbackFunctionToUpdateTheListItemValue: onUpdateTheListItemValue,
                            parentCallbackFunctionToUpdateTheListOfItemsSelectedForDeletion: (index){_textsSelectedForDeletionIndexes.add(index);}, 
                            themeData: Theme.of(context),                          
                          )
                          // Row(
                          //   children: 
                          //   [
                          //     // Checkbox for list item deletion
                          //     Checkbox
                          //     (
                          //       value: false, 
                          //       onChanged: 
                          //         (_)
                          //         {
                          //           _textsSelectedForDeletion.add(_enteredTextItemsList[index]);
                          //           print("Selected for deletion: $_textsSelectedForDeletion");
                          //         }
                          //     ),
                          //     // List tile for reading/to start edition 
                          //     // Expanded for constraints
                          //     Expanded(
                          //       child: ListTile
                          //       (
                          //       key: Key('text$index'),
                          //       dense: true,
                          //       leading: Text(
                          //         '${index + 1}.',
                          //         style: widget.themeData.textTheme.bodySmall,
                          //       ),                            
                          //       title: Text(
                          //         _enteredTextItemsList[index],
                          //         style: widget.themeData.textTheme.titleMedium,
                          //       ),
                          //       trailing: const Icon(Icons.edit),
                          //       onTap: () 
                          //       {
                          //         setState(() 
                          //         {
                          //           _isEdited = true; 
                          //           _editedIndex = index; 
                          //           _tecEdition.text = _enteredTextItemsList[index];
                          //         });
                          //       },
                          //                               ),
                          //     )
                          //   ],
                          // )
                        ;
                    },
                  ),
                ),
              // TextField used to add a new text
              TextField
              (
                controller: _tecNewText,
                textAlign: TextAlign.left,
                decoration: const InputDecoration
                (
                  hint: Text
                  ( 
                    invitationToEnterTextPlaceholder,
                    textAlign: TextAlign.left,                                          
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),                  
                ),
                onSubmitted: (value)
                {
                  setState(() {
                    _enteredTextItemsList.add(value.trim());
                  });
                  _tecNewText.clear();
                  print("_enteredTextItemsList: $_enteredTextItemsList");
                },
              ),
            ]
        )
      );
  }
}
