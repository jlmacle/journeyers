import 'package:flutter/material.dart';

import '../custom_generic_widgets/editable_text_list_item.dart';
import '../models/text_lists_storage_externalized_strings.dart';

import '../models/text_lists_storage.dart';
import 'addition_to_text_lists.dart';

/// Displays all saved list labels.
///
/// Tapping a label loads the corresponding numbers and pushes a read-only
/// [AdditionToTextLists] for that list.
class TextListsDisplay extends StatefulWidget {
  const TextListsDisplay({super.key});

  @override
  State<TextListsDisplay> createState() => _TextListsDisplayState();
}

class _TextListsDisplayState extends State<TextListsDisplay> {
  final _store = TextListsStorage();

  // Tracks whether we are currently loading data from disk.
  bool _loading = true;

  // Null means an error occurred; empty list means no saved lists yet.
 List<dynamic>? _dataStructure; 
  List<String>? _labels;
  String? _error;

  // For edition 
  var _isEdited = false;
  var _tecEdition = TextEditingController();

  @override
  void dispose() {
    _tecEdition.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();  

    // Loading the labels specifically, and also the stored data  
    _loadLabelsAndData();
    
  }

  Future<void> _loadLabelsAndData() async {
    _dataStructure = await _store.loadDataStructure();
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final labels = await _store.sortedLabels(dataStructure: _dataStructure);
      setState(() {
        _labels = labels;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _openList(String label) async {
    try {
      final texts = _store.loadTextsByListLabelSync(label: label, dataStructure: _dataStructure!);
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => AdditionToTextLists(
            initialTextValues: texts,
            loadedLabel: label,
            listLabelHintText: listLabelHintText,
            listPlaceholder: listPlaceholder,
            invitationToEnterTextPlaceholder: invitationToEnterTextPlaceholder,
            themeData: Theme.of(context),
          ),
        ),
      );
      // Refresh in case the user navigated back (no-op here, but good practice).
      await _loadLabelsAndData();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not load "$label": $e')),
      );
    }
  }

  // ── build ──────────────────────────────────────────────────────────────────

  Widget _buildListCard(String listLabel, List<String> listItems) {
  return ListTile( 
    title: Card
    (
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Editable list label
            // parentCallbackFunctionToUpdateTheListItemValue to add
            EditableTextListItem(itemText: listLabel, itemIndex: -1),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: listItems.map
              (
                (listItem) 
                // parentCallbackFunctionToUpdateTheListItemValue to add
                  => Chip(label: EditableTextListItem(itemText: listItem, itemIndex:-1,))
              ).toList(),
            ),
          ],
        ),
      ),      
    ),
  );
}

Widget _listItemBuilder({required dynamic listItem})
  {
    print("listItem: $listItem");
    var listItemAsMap = listItem as Map<String, dynamic>;
    return _buildListCard(listItemAsMap.keys.first, listItemAsMap.values.first);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Lists'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: _loadLabelsAndData,
          ),
        ],
      ),
      body: _buildList(),
    );
  }

  // Method used to build the list displayed
  Widget _buildList() 
  {
    // During data loading
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    // In case of error during the loading of the list data
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Error loading lists:\n$_error',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    // In case of empty list
    final labels = _labels!;
    if (labels.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No saved lists yet.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.5),
                  ),
            ),
          ],
        ),
      );
    }

    // return buildList(listAsAMap: _savedListsData!, listItemBuilder: _listItemBuilder);

    return ListView.separated(
      shrinkWrap: true,
      // physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: labels.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final label = labels[index];
        // print("savedListsData![label]!: ${_savedListsData![label]!}");
        return _buildListCard(label, _store.loadTextsByListLabelSync(label: label, dataStructure : _dataStructure!));
        // return _buildListCard(label, ["jkkjkj"]);
      },
    );
  }
}
