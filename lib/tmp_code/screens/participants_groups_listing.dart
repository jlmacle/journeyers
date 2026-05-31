import 'package:flutter/material.dart';

import '../list_logic/list_logic.dart';
import '../models/participants_groups_lists_storage.dart';
import 'participants_group_addition.dart';

/// Displays all saved lists data.
class ParticipantsGroupsListing extends StatefulWidget {
  const ParticipantsGroupsListing({super.key});

  @override
  State<ParticipantsGroupsListing> createState() => _ParticipantsGroupsListingState();
}

class _ParticipantsGroupsListingState extends State<ParticipantsGroupsListing> {
  final _store = ParticipantsGroupsListsAsMapsStorage();

  // Tracks whether we are currently loading data from disk.
  bool _loading = true;

  // Null means an error occurred; empty list means no saved lists yet.
  Map<String, List<String>>? _savedListsData; 
  List<String>? _labels;
  String? _error;

  @override
  void initState() {
    super.initState();    
    _loadLabelsAndData();
    
  }

  Future<void> _loadLabelsAndData() async {
    _savedListsData = await _store.retrieveAllGroupsData();
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final labels = await _store.sortedLabels();
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
      final numbers = await _store.load(label);
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ParticipantsGroupAddition(
            initialNames: numbers,
            loadedLabel: label,
          ),
        ),
      );
      // Refresh in case the user navigated back.
      await _loadLabelsAndData();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not load "$label": $e')),
      );
    }
  }

  // ── build ──────────────────────────────────────────────────────────────────

  Widget _buildListCard(String listTitle, List<String> listItems) {
  return ListTile( 
    title: Card
    (
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(listTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: listItems.map((item) => Chip(label: Text(item))).toList(),
            ),
          ],
        ),
      ),
    ),
    trailing: const Icon(Icons.edit),
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
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

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

    return buildList(listAsAMap: _savedListsData!, listItemBuilder: _listItemBuilder);
  }
}
