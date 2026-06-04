import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/participants_groups_lists_storage.dart';

/// Class used to add a new group of participants.
class ParticipantsGroupAddition extends StatefulWidget {
  const ParticipantsGroupAddition({
    super.key,
    this.initialNames = const [],
    this.loadedLabel,
  });

  /// Pre-populated strings (from a loaded list).
  final List<String> initialNames;

  /// When non-null the screen is read-only and shows this label in the title.
  final String? loadedLabel;

  @override
  State<ParticipantsGroupAddition> createState() => _ParticipantsGroupAdditionState();
}

class _ParticipantsGroupAdditionState extends State<ParticipantsGroupAddition> {
  bool get _isReadOnly => widget.loadedLabel != null;


  // Data related to retrieving the lists of participants groups
  final _participantsListsStorage = ParticipantsGroupsListsStorage();
  bool _loading = true;
  String? _errorLoading;
  List<List<String>>? _listOfListsOfNames = [];
  
  // To store the new group data
  late final List<String> _newGroupList;

  // Data used to edit the name of a participant after addition to the list
  var _isEdited = false;
  var _editedIndex = -1;
  var _tecNewParticipant = TextEditingController();
  var _tecEdition = TextEditingController();

  // Data related to saving the group list
  // True once the current in-memory list has been persisted.
  bool _isSaved = false;
  // True while an async save is in progress (prevents double-tap).
  bool _saving = false;
  var _tecListName = TextEditingController();

  // Disposing of the TextEditingController instances
  @override
  void dispose() {
    _tecNewParticipant.dispose();
    _tecEdition.dispose();
    _tecListName.dispose();
    super.dispose();
  }
  
  // Used to load the lists of names, within a list
  Future<void> _loadListOfListsOfNames() async {
    setState(() {
      _loading = true;
      _errorLoading = null;
    });
    try {
      List<List<String>> listOfListsOfNames = await _participantsListsStorage.listOfListsOfNames();      
      setState(() {
        _listOfListsOfNames = listOfListsOfNames;
        _loading = false;
        print("_loadListOfListsOfNames: _listOfListsOfNames: $_listOfListsOfNames");
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
    // Loading the previous lists of participants
    _loadListOfListsOfNames();
    
    _newGroupList = List<String>.from(widget.initialNames);

  }

  // ── actions ────────────────────────────────────────────────────────────────

  // Method used to save the participants list
  Future<void> _saveParticipantsList() async {

    final label = await _showLabelDialog();
    if (label == null) return; // for user cancellation

    setState(() => _saving = true);
    try {

      await _participantsListsStorage.saveListData(label, List.from(_newGroupList)..sort());      

      setState(() {
        _isSaved = true;
        _saving = false;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar
      (
        SnackBar(content: Text('Saved as "$label"')),
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

  /// Shows a dialog that asks for a label.
  /// Requires for the label to not be used already.
  Future<String?> _showLabelDialog() async {
    String? errorText;

    return showDialog<String>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            Future<void> onConfirm() async {
              final label = _tecListName.text.trim();
              if (label.isEmpty) {
                setDialogState(() => errorText = 'Label cannot be empty.');
                return;
              }
              // Warn if the label already exists, and prevents the saving of data.
              final alreadyExists = await _participantsListsStorage.existsAsync(label);
              if (!ctx.mounted) return;
              if (alreadyExists) {
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
                controller: _tecListName,
                autofocus: true,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) async => await onConfirm(), 
                decoration: InputDecoration(
                  labelText: 'List label',
                  hintText: 'e.g. Our household members',
                  errorText: errorText,
                ),
                onChanged: (_) {
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
      !_isReadOnly && _newGroupList.isNotEmpty && !listOfListsContainsList(_listOfListsOfNames!, _newGroupList)  && !_isSaved && !_saving;

  bool listOfListsContainsList(List<List<String>> listOfLists, List<String> list)
  {
    bool val = _listOfListsOfNames!.any((list) => listEquals(list, _newGroupList));
    return val;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorLoading != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Error loading the particpants lists:\n$_errorLoading',
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
          title: Text(_isReadOnly ? widget.loadedLabel! : 'New list'),
          actions: [
            if (canSave) 
            ...
            [
              _saving
                  ? const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : IconButton(
                      tooltip: 'Save list',
                      icon: const Icon(Icons.save_outlined),
                      onPressed: _saveParticipantsList,
                    ),
            ]
            else 
            ...
            [
              if (!_newGroupList.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(right: 8.0),
                  child: Text('List already saved', ),
                )
            ]
            
          ],
        ),

        // ── Names display ──────────────────────────────────────────────────
        body: 
          Column
          (
            children: 
            [
              // List of added participants or placeholder message
              Expanded(
                child: 
              _newGroupList.isEmpty
              ? Center(
                  child: Text(
                    'No names yet.\nPlease enter a name to add one.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                )
              :      
              // List of added names              
              ListView.builder
              (                  
                padding: const EdgeInsets.only(bottom: 96),
                itemCount: _newGroupList.length,
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
                            _newGroupList[index] = value; 
                            _isEdited = false;
                            _tecEdition.clear();
                          }),
                        
                      )
                      // ListTile (reading mode)
                      : 
                      Row(
                        children: 
                        [
                          // Checkbox for list item deletion
                          Checkbox(value: false, onChanged: (_){}),
                          // List tile for reading/to start edition 
                            // Expanded for constraints
                          Expanded(
                            child: ListTile
                            (
                            key: Key('participantName$index'),
                            dense: true,
                            leading: Text(
                              '${index + 1}.',
                              style: theme.textTheme.bodySmall,
                            ),
                            trailing: const Icon(Icons.edit),
                            title: Text(
                              _newGroupList[index],
                              style: theme.textTheme.titleMedium,
                            ),
                            onTap: () 
                            {
                              setState(() 
                              {
                                _isEdited = true; 
                                _editedIndex = index; 
                                _tecEdition.text = _newGroupList[index];
                              });
                            },
                                                    ),
                          )
                        ],
                      )
                    ;
                },
              ),
            ),
            // TextField used to add a new participant name
            TextField
            (
              controller: _tecNewParticipant,
              textAlign: TextAlign.left,
              decoration: const InputDecoration
              (
                hint: Text
                (
                  textAlign: TextAlign.left,
                  "Please add a participant's name here"                        
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),                  
              ),
              onSubmitted: (value)
              {
                setState(() {
                  _newGroupList.add(value.trim());
                });
                _tecNewParticipant.clear();
                print("_identifiers: $_newGroupList");
              },
            ),
          ]
        )
      )
      ;
  }
}
