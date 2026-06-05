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
  bool get _listIsLoaded => widget.loadedLabel != null;

  // Data related to retrieving the list of grouped texts
  final _textListsStorage = TextListsStorage();
  bool _loading = true;
  String? _errorLoading;
  List<List<String>>? _listOfPreviousGroupedTexts = [];
  
  // To store the new grouped texts data
  late final List<String> _enteredTextItemsList;

  // Data used to edit a text after addition to the list
  var _isEdited = false;
  var _editedIndex = -1;
  var _tecNewText = TextEditingController();
  var _tecEdition = TextEditingController();

  // Data related to deleting texts from the new list
  List<String> textsSelectedForDeletion = [];
  bool _areSomeTextItemsForDeletion = false;
  List<int> _indexesOfTextItemsSelectedForDeletion = [];

  // Data related to saving the added texts in a list
  // True once the current list has been persisted.
  bool _isSaved = false;
  // True while an async save is in progress (prevents double-tap).
  bool _saving = false;
  // For entering the list label
  var _tecListLabel = TextEditingController();

  // Disposing of the TextEditingController instances
  @override
  void dispose() {
    _tecNewText.dispose();
    _tecEdition.dispose();
    _tecListLabel.dispose();
    super.dispose();
  }
  
  // Used to load the list of grouped texts
  Future<void> _loadListOfGroupedTexts() async {
    setState(() {
      _loading = true;
      _errorLoading = null;
    });
    try {
      List<List<String>> listOfGroupedTexts = await _textListsStorage.listOfGroupedTexts();      
      setState(() {
        _listOfPreviousGroupedTexts = listOfGroupedTexts;
        _loading = false;
        print("_loadListOfGroupedTexts: _listOfGroupedTexts: $_listOfPreviousGroupedTexts");
      });
    } catch (e) {
      setState(() {
        print(e);
        _errorLoading = e.toString();
        _loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Loading the previous lists of grouped texts
    _loadListOfGroupedTexts();
    
    _enteredTextItemsList = List<String>.from(widget.initialTextValues);

  }

  // ── actions ────────────────────────────────────────────────────────────────

  // Method used to save the grouped texts in a list
  Future<void> _saveGroupTextsList() async {

    // Opening a dialog to enter the list label
    final listLabel = await _showListLabelDialog();

    if (listLabel == null) return; // for user cancellation

    setState(() => _saving = true);

    try {
      // List.from(_newTextsList)..sort() : 
      // to sort at saving time, without re-ordering the texts on-screen
      await _textListsStorage.saveListData(listLabel, List.from(_enteredTextItemsList)..sort());      

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
              final listLabelAlreadyExists = await _textListsStorage.listLabelExistsAsync(label);
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

  // ── build ──────────────────────────────────────────────────────────────────

  bool get canSave =>
      // list has not been loaded from existant list
      !_listIsLoaded 
      // at least one text has been added
      && _enteredTextItemsList.isNotEmpty 
      // added texts are not matching a saved list content
      && !listOfPreviousGroupedTextsContainsNewListData(_listOfPreviousGroupedTexts!, _enteredTextItemsList)  
      // the new list hasn't been saved yet
      && !_isSaved ;

  // Method used to verify 
  bool listOfPreviousGroupedTextsContainsNewListData(List<List<String>> listOfPreviousGroupedTexts, List<String> newListData)
  {
    bool val = _listOfPreviousGroupedTexts!.any((list) => listEquals(list, _enteredTextItemsList));
    return val;
  }

  void onUpdateTheListItemValue({required String stringParam, required int intParam})
  {
    setState(() {
      _enteredTextItemsList[intParam] = stringParam;
    });  
  }


  @override
  Widget build(BuildContext context) {

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorLoading != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Error loading the lists:\n$_errorLoading',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return 
      _loading
      ? const Center(child: CircularProgressIndicator())
      : Scaffold(
        appBar: AppBar(
          title: Text(_listIsLoaded ? widget.loadedLabel! : 'New list'),
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
                      onPressed: _saveGroupTextsList,
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
                indexesOfTextItemsSelectedForDeletion: _indexesOfTextItemsSelectedForDeletion,
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
                            controller: _tecEdition,
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
                                _tecEdition.clear();
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
                                                                    // adding the index to _indexesOfTextItemsSelectedForDeletion
                                                                    _indexesOfTextItemsSelectedForDeletion.add(index);
                                                                    _indexesOfTextItemsSelectedForDeletion.sort();
                                                                    _areSomeTextItemsForDeletion = true;

                                                                    // setState // to do later at bulk widget level
                                                                    setState(() {
                                                                      
                                                                    });
                                                                  }
                                                                  else{
                                                                     _indexesOfTextItemsSelectedForDeletion.remove(index);
                                                                     if (_indexesOfTextItemsSelectedForDeletion.isEmpty) _areSomeTextItemsForDeletion = false;
                                                                    // setState // to do later at bulk widget level
                                                                    setState(() {
                                                                      
                                                                    });
                                                                  }
                                                                  print("_indexesOfTextItemsSelectedForDeletion: $_indexesOfTextItemsSelectedForDeletion");
                                                                }, 
                            parentCallbackFunctionToUpdateTheListItemValue: onUpdateTheListItemValue,
                            parentCallbackFunctionToUpdateTheListOfItemsSelectedForDeletion: (index){_indexesOfTextItemsSelectedForDeletion.add(index);}, 
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
                          //           textsSelectedForDeletion.add(_newTextsList[index]);
                          //           print("Selected for deletion: $textsSelectedForDeletion");
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
                          //         _newTextsList[index],
                          //         style: widget.themeData.textTheme.titleMedium,
                          //       ),
                          //       trailing: const Icon(Icons.edit),
                          //       onTap: () 
                          //       {
                          //         setState(() 
                          //         {
                          //           _isEdited = true; 
                          //           _editedIndex = index; 
                          //           _tecEdition.text = _newTextsList[index];
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
