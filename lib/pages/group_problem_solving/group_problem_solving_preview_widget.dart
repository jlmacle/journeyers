import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:path/path.dart' as path;

import 'package:journeyers/debug_constants.dart';
import 'package:journeyers/utils/generic/dev/test_externalized_strings.dart';
import 'package:journeyers/utils/generic/dev/test_utils.dart';
import 'package:journeyers/utils/generic/dev/utility_classes_import.dart';

/// {@category Group problem-solving}
/// A preview widget used for the group problem-solving dashboard.
class GPSPreview extends StatefulWidget {
  /// The path to a stored group problem-solving session data.
  final String gpsPreviewPathToStoredData;

  /// The ideas listed in the preview.
  final List<String> gpsPreviewIdeasStored;

  /// Callback function used to update the temporary file path used for sharing a session data.
  final ValueChanged<String> gpsPreviewCallbackFunctionToUpdateTmpFilePath;

  const GPSPreview({
    super.key,
    required this.gpsPreviewPathToStoredData,
    // todo: to clean
    required this.gpsPreviewIdeasStored,
    required this.gpsPreviewCallbackFunctionToUpdateTmpFilePath
  });

  @override
  State<GPSPreview> createState() =>
      _GPSPreviewState();
}

// TODO: to clean
class _GPSPreviewState
    extends State<GPSPreview> {

  bool _isPreviewDataLoading = true;
  // Data displayed
  String _dataSessionTitle = "";
  String _dataDateString = "";
  List<String> _dataIdeas = [];

  // only runs once, at widget creation
  @override
  void initState() {
    super.initState();

    pu.printdLine();
    pu.printd("GPSPreview");
    
    if (editDebug) pu.printd("Editing: GPSPreview: initState: widget.ideas: ${widget.gpsPreviewIdeasStored}");
    
    _dataIdeas = widget.gpsPreviewIdeasStored;
    if (_dataIdeas.isEmpty) 
    {
      if (editDebug) pu.printd("Editing: GPSPreview: initState: _fetchingData");
      _fetchingData();
    }
    else
    {
      setState(() {
        _isPreviewDataLoading = false;
      });
    }     
  }

  Future<void> _fetchingData() async {
    List<String> txtLines = [];

    try {
      if (pathsForTestFiles.contains(widget.gpsPreviewPathToStoredData)) 
      {
        _dataIdeas = [testDataMessage];
        return;
      }

      String fileNameWithExtension = path.basename(widget.gpsPreviewPathToStoredData);
      final String content;
      // Retrieving the TXT content
      if (Platform.isAndroid)
      {
        if (previewBuildingDebug) pu.printd("Preview Building: GPS: on Android");

        try
        {
          // Outside of testing: reading file using SAF
          if (!isInTestEnvironment) { content= await fu.readTextFileOnAndroid(fileNameWithExtension: fileNameWithExtension); }
          // While testing
          else 
          { 
            if (testingDebug) pu.printd("Testing Debug: Preview Building: GPS: Reading $fileNameWithExtension from tmp folder");
            content = await File(widget.gpsPreviewPathToStoredData).readAsString();
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
          if (!isInTestEnvironment) { content = await fu.readTextFileOnIOS(fileNameWithExtension: fileNameWithExtension); }
          // While testing
          else 
          { 
            if (testingDebug) pu.printd("Testing Debug: Preview Building: GPS: Reading $fileNameWithExtension from tmp folder");
            content = await File(widget.gpsPreviewPathToStoredData).readAsString();
          }
          txtLines = LineSplitter.split(content).toList();
        }
        on Exception
        catch(e) {pu.printd("Preview Building: Exception: GPS: on iOS: $e");}
      }
      else if (Platform.isLinux || Platform.isMacOS | Platform.isWindows)
      {
        // Checking if the CSV file exists
        File csvFile = File(widget.gpsPreviewPathToStoredData);
        if (!csvFile.existsSync()) throw Exception("The CSV file doesn't exist: ${widget.gpsPreviewPathToStoredData} (${Platform.operatingSystem})");
        // Loading the file content
        txtLines = csvFile.readAsLinesSync();
      }
      
      // To clean
      // Writing the content in a temporary file for data sharing
      Directory testTmpDir = await Directory.systemTemp.createTemp('group_problem_solving_preview_temp');
      String tmpFilePathWithExtension = path.join(testTmpDir.path, widget.gpsPreviewPathToStoredData.split("/").last);
      var dataBytes = Uint8List.fromList(utf8.encode(txtLines.toString()));      
      String tmpFilePath = await fu.saveFileUsingWriteAsBytes(filePathWithExtension: tmpFilePathWithExtension, dataBytes: dataBytes);
      if (previewBuildingDebug) pu.printd("Preview Building: GPSPreview: _fetchingData: saved tmp file path for file sharing: $tmpFilePath");
      // Updating the value for the session list item
      widget.gpsPreviewCallbackFunctionToUpdateTmpFilePath(tmpFilePath);   

      // Building the preview
      if (txtLines.length >= 2) {
        _dataSessionTitle = txtLines[1];
        // Extracting date from the second line: "Date: MMMM dd, yyyy h:mm a"
        _dataDateString = txtLines[2].replaceFirst("Date: ", "");
        
        // Ideas start after the "---" separator (index 3 onwards)
        // We strip the "1. ", "2. " numbering prefix
        _dataIdeas = txtLines
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
          _isPreviewDataLoading = false;
        });
      }
    }
  }


  @override
  void didUpdateWidget(covariant GPSPreview oldWidget) {
    pu.printdLine();
    pu.printd("GPSPreview: didUpdateWidget");
    
    if (editDebug) pu.printd("Editing: GPSPreview: didUpdateWidget: widget.ideas: ${widget.gpsPreviewIdeasStored}");
    if (editDebug) pu.printd("Editing: GPSPreview: didUpdateWidget: oldWidget.ideas: ${oldWidget.gpsPreviewIdeasStored}");

    super.didUpdateWidget(oldWidget);

    // Updating with new values
    if (widget.gpsPreviewIdeasStored != oldWidget.gpsPreviewIdeasStored && widget.gpsPreviewIdeasStored.isNotEmpty) {
      setState(() {
        _dataIdeas = widget.gpsPreviewIdeasStored;
        _isPreviewDataLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isPreviewDataLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_dataIdeas.isEmpty) {
      return const Center(child: Text("No ideas found."));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            _dataDateString,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        const Divider(),
        ..._dataIdeas.map((idea) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              // Rows with the ideas texts
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.arrow_forward, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(idea)),
                ],
              ),
            )),
      ],
    );
  }
}