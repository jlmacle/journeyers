import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Persists a map of { label → List<String> } to a single JSON file located in
/// the application-support directory (see [getApplicationSupportDirectory]).
class ParticipantsGroupsListsAsMapsStorage {
  static const _fileName = 'journeyers_gps_participants_groups_lists.json';

  // ── Internal helpers ────────────────────────────────────────────────────────

  // Method used to get the file where the data is stored.
  Future<File> _getFile() async {
    var dir = await getApplicationSupportDirectory();
    return File('${dir.path}/$_fileName');
  }

  // ── public API ───────────────────────────────────────────────────────────────

  /// Retrieves the groups data. Returns an empty map when the file does not exist.
  Future<Map<String, List<String>>> retrieveAllGroupsData() async {
    var f = await _getFile();
    if (!await f.exists()) return {};

    var raw = await f.readAsString();
    var decodedData = jsonDecode(raw) as Map<String, dynamic>;

    return decodedData.map(
      (key, value) => MapEntry(
        key,
        (value as List<dynamic>).cast<String>(),
      ),
    );
  }

  /// Returns all saved group labels, sorted alphabetically.
  Future<List<String>> sortedLabels() async {
    var all = await retrieveAllGroupsData();
    return all.keys.toList()..sort();
  }

  /// Returns all saved groups lists.
  Future<List<List<String>>> groupsLists() async {
    var all = await retrieveAllGroupsData();
    List<List<String>> groupsLists = all.values.toList();
    print("groupsLists(): groupsLists: $groupsLists");
    return groupsLists;
  }

  /// Loads the participants names for [label]. Throws [ArgumentError] when absent.
  Future<List<String>> load(String label) async {
    var all = await retrieveAllGroupsData();
    if (!all.containsKey(label)) {
      throw ArgumentError('No list found for label "$label".');
    }
    return List<String>.from(all[label]!);
  }

  /// Returns `true` when [label] already exists in the store.
  Future<bool> exists(String label) async {
    var all = await retrieveAllGroupsData();
    return all.containsKey(label);
  }

  /// Saves [names] under [label], overwriting any previous entry.
  Future<void> save(String label, List<String> names) async {
    var all = await retrieveAllGroupsData();
    all[label] = names;
    var f = await _getFile();
    await f.writeAsString(jsonEncode(all));
  }

}
