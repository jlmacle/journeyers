import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:path/path.dart' as path;

import 'package:journeyers/debug_constants.dart';
import 'package:journeyers/utils/generic/dev/externalized_test_strings.dart';
import 'package:journeyers/utils/generic/dev/utility_classes_import.dart';

/// {@category Group problem-solving}
/// A preview widget used for the group problem-solving dashboard.
class GPSPreviewWidget extends StatefulWidget {
  /// The path to a stored group problem-solving session data.
  final String pathToStoredData;

  const GPSPreviewWidget({
    super.key,
    required this.pathToStoredData,
  });

  @override
  State<GPSPreviewWidget> createState() =>
      _GPSPreviewWidgetState();
}

// TODO: to clean
class _GPSPreviewWidgetState
    extends State<GPSPreviewWidget> {

  bool _isLoading = true;
  String _sessionTitle = "";
  String _dateString = "";
  List<String> _solutions = [];

  @override
  void initState() {
    super.initState();
    _fetchingData();
  }

  Future<void> _fetchingData() async {
    List<String> txtLines = [];

    try {
      if (pathsForTestFiles.contains(widget.pathToStoredData)) 
      {
        _solutions = [testDataMessage];
        return;
      }

      String fileNameWithExtension = path.basename(widget.pathToStoredData);
      final String content;
      // Retrieving the TXT content
      if (Platform.isAndroid)
      {
        if (previewBuildingDebug) pu.printd("Preview Building: GPS: on Android");

        try
        {
          // Outside of testing: reading file using SAF
          if (!runningTests) { content= await fu.readTextFileOnAndroid(fileNameWithExtension: fileNameWithExtension); }
          // While testing
          else 
          { 
            if (testingDebug) pu.printd("Testing Debug: Preview Building: GPS: Reading $fileNameWithExtension from tmp folder");
            content = await File(widget.pathToStoredData).readAsString();
          }
          txtLines = LineSplitter.split(content).toList();
        }
        on Exception
        catch(e) {pu.printd("Preview Building: Exception: GPS: on Android: $e");}
      }
      else if (Platform.isIOS)
      {
        
        if (previewBuildingDebug) pu.printd("Preview Building: GPS: on iOS");
        try
        {
          // Outside of testing
          if (!runningTests) { content = await fu.readTextFileOnIOS(fileNameWithExtension: fileNameWithExtension); }
          // While testing
          else 
          { 
            if (testingDebug) pu.printd("Testing Debug: Preview Building: GPS: Reading $fileNameWithExtension from tmp folder");
            content = await File(widget.pathToStoredData).readAsString();
          }
          txtLines = LineSplitter.split(content).toList();
        }
        on Exception
        catch(e) {pu.printd("Preview Building: Exception: GPS: on iOS: $e"); }
      }
      else if (Platform.isLinux || Platform.isMacOS | Platform.isWindows)
      {
        // Checking if the CSV file exists
        File csvFile = File(widget.pathToStoredData);
        if (!csvFile.existsSync()) throw Exception("The CSV file doesn't exist: ${widget.pathToStoredData} (${Platform.operatingSystem})");
        // Loading the file content
        txtLines = csvFile.readAsLinesSync();
      }

      // Building the preview
      if (txtLines.length >= 2) {
        _sessionTitle = txtLines[1];
        // Extracting date from the second line: "Date: MMMM dd, yyyy h:mm a"
        _dateString = txtLines[2].replaceFirst("Date: ", "");
        
        // Solutions start after the "---" separator (index 3 onwards)
        // We strip the "1. ", "2. " numbering prefix
        _solutions = txtLines
            .skip(4)
            .where((line) => line.trim().isNotEmpty)
            .map((line) => line.replaceFirst(RegExp(r'^\d+\.\s'), ''))
            .toList();         
        
      }
    } catch (e) {
      debugPrint("Error reading preview data: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_solutions.isEmpty) {
      return const Center(child: Text("No solutions found."));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            _dateString,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        const Divider(),
        ..._solutions.map((solution) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              // Rows with the solutions texts
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.arrow_forward, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(solution)),
                ],
              ),
            )),
      ],
    );
  }
}