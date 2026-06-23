import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:journeyers/debug_constants.dart';
import 'package:journeyers/utils/generic/dev/utility_classes_import.dart';
import 'package:journeyers/widgets/custom/interaction_and_inputs/editable_deletable_text_list_item.dart';
import 'package:journeyers/widgets/utility/lists/models/text_lists_storage.dart';
import 'package:journeyers/widgets/utility/lists/new_text_list_externalized_strings.dart';
import 'package:journeyers/widgets/utility/lists/tmp_utility_widgets/new_text_list_deletion_by_bulk.dart';
import 'package:journeyers/widgets/utility/lists/tmp_utility_widgets/new_text_list_keywords_declaration.dart';


/// Class used to add a text list to a set of text lists.
/// A new list can be saved only if its content is not identical to a previous list content.
/// The widget can be used to load a list for edition.
class NewTextList extends StatefulWidget 
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

  /// A callback function called when the participants list is loaded.
  final ValueChanged<List<String>> onParticipantsLoadedCallbackFunction;

  const NewTextList({
    super.key,
    this.initialTextValues = const [],
    this.loadedLabel,
    required this.listLabelHintText,
    required this.listPlaceholder,
    required this.invitationToEnterTextPlaceholder,
    required this.themeData, 
    required this.onParticipantsLoadedCallbackFunction
  });  

  @override
  State<NewTextList> createState() => _NewTextListState();
}

class _NewTextListState extends State<NewTextList> {

  // bool: a list has been loaded
  bool get _listHasBeenLoaded => widget.loadedLabel != null;

  // Data related to retrieving the list of grouped texts
  final _listsDB = ListsDB();
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

      List<List<String>> listOfGroupedTexts = await _listsDB.getListOfGroupedTexts(); 

      setState(() {
        _listOfPreviousGroupedTexts = listOfGroupedTexts;
        _loadingDB = false;
        if (listDebug) pu.printd("List debug: _NewTextListState: _loadListOfGroupedTexts: _listOfGroupedTexts: $_listOfPreviousGroupedTexts");
      });
    } catch (e) {
      setState(() {
        pu.printd("Exception: _NewTextListState: _loadListOfGroupedTexts: $e");
        _errorLoadingDB = e.toString();
        _loadingDB = false;
      });
    }
  }

  
  // Data used to adding a text to the list
  var _tecNewText = TextEditingController();
  // To store the new grouped texts data
  late final List<String> _enteredTextItemsList;

  // Used for entered keywords
  List<String> _newKeywords = [];

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
  bool _listOfPreviousGroupedTextsContainsNewListData(List<List<String>> listOfPreviousGroupedTexts, List<String> newListData)
  {
    var listOfPreviousGroupedTextsCopy = List.from(listOfPreviousGroupedTexts);
    var newListDataCopy = List.from(newListData);
    bool val = listOfPreviousGroupedTextsCopy.any((list) => listEquals(list..sort(), newListDataCopy..sort()));
    return val;
  }

  bool get _canSave =>
      // list has not been loaded from existant list
      !_listHasBeenLoaded 
      // at least one text has been added
      && _enteredTextItemsList.isNotEmpty 
      // added texts are not matching a saved list content
      && !_listOfPreviousGroupedTextsContainsNewListData(_listOfPreviousGroupedTexts!, _enteredTextItemsList)  
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
                setDialogState(() => errorText = emptyLabelError);
                return;
              }
              // Warn if the label already exists, and prevents the saving of data.
              final listLabelAlreadyExists = await _listsDB.listLabelExistsAsync(label);
              if (!ctx.mounted) return;
              if (listLabelAlreadyExists) {
                setDialogState(
                  () => errorText = '${label}${listAlreadySavedErrorEndPart}',
                );
                return;
              }
              // Loading the list
              widget.onParticipantsLoadedCallbackFunction(_enteredTextItemsList);

              // To close the dialog
              Navigator.of(ctx).pop(label);
              // To close the new list widget
              Navigator.of(ctx).pop(label);
              // To close the list loading/creation menu
              Navigator.of(ctx).pop(label);
            }

            return AlertDialog(
              title: const Text('Save list'),
              content: TextField(
                key: const ValueKey('saveListField'),
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
      await _listsDB.saveListData(listLabel, List.from(_enteredTextItemsList)..sort(), _newKeywords);      

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

  void _onUpdateTheListItemValue({required String stringParam, required int intParam})
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
        title: Text
              (
                _listHasBeenLoaded ? widget.loadedLabel! : newListAppBarTitle, 
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.normal)
              ),          
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          // If data can be saved
          if (_canSave) 
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
            // To avoid saving twice the same data, at new list declaration
            // TODO: to move at saving time            
            if (_enteredTextItemsList.isNotEmpty)
              const Padding(
                padding: EdgeInsets.only(right: 8.0),
                child: Text(contentAlreadySavedError),
              )
          ]            
        ],
      ),
    
      // ── Texts display ──────────────────────────────────────────────────
      body:
      SafeArea
      (
        child: 
        Column
        (
          children: 
          [
            NewTextListKeywordsDeclaration
            (
              currentKeywords: {},
              onKeywordsUpdatedCallbackFunction: (newKeywords) 
              {
                if (listDebug) pu.printd("List debug: _NewTextListState: build: newKeywords: $newKeywords");
    
                _newKeywords = newKeywords.toList()..sort();
              }
            ),
            // Deletion by bulk widget
            NewListDeletionByBulk
            (
              areSomeTextItemsSelectedForDeletion: _areSomeTextItemsForDeletion,
              enteredTextItemsList: _enteredTextItemsList,
              textItemsSelectedForDeletionIndexes: _textsSelectedForDeletionIndexes,
              callbackFunctionToRefreshTheList: () {setState(() {_areSomeTextItemsForDeletion = false;});}
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
                          key: ValueKey(_enteredTextItemsList[index]),
                          itemIndex: index, 
                          itemText: _enteredTextItemsList[index], 
                          onCheckboxChangedCallbackFunction: ({required bool? boolParam, required int intParam}) 
                                                              {                                                               
                                                                if(boolParam!) 
                                                                {                                                                    
                                                                  // adding the index to _textsSelectedForDeletionIndexes
                                                                  _textsSelectedForDeletionIndexes.add(index);
                                                                  _textsSelectedForDeletionIndexes.sort();
                                                                  _areSomeTextItemsForDeletion = true;
    
                                                                  // setState // todo later at bulk widget level
                                                                  setState(() {
                                                                    
                                                                  });
                                                                }
                                                                else{
                                                                   _textsSelectedForDeletionIndexes.remove(index);
                                                                   if (_textsSelectedForDeletionIndexes.isEmpty) _areSomeTextItemsForDeletion = false;
                                                                  // setState // todo later at bulk widget level
                                                                  setState(() {
                                                                    
                                                                  });
                                                                }
                                                                if (listDebug) pu.printd("List debug: _NewTextListState: build: _textsSelectedForDeletionIndexes: $_textsSelectedForDeletionIndexes");

                                                              }, 
                          parentCallbackFunctionToUpdateTheListItemValue: _onUpdateTheListItemValue,
                          parentCallbackFunctionToUpdateTheListOfItemsSelectedForDeletion: (index){_textsSelectedForDeletionIndexes.add(index);}, 
                          themeData: Theme.of(context),                          
                        )                          
                      ;
                  },
                ),
              ),
            // TextField used to add a new text
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField
              (
                key: const ValueKey('participantNameField'),
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
                  if (listDebug) pu.printd("List debug: _NewTextListState: build: _enteredTextItemsList: $_enteredTextItemsList");
                },
              ),
            ),
          ]
      )
      )
    );
  }
}
