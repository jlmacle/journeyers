import 'dart:convert';

import 'package:flutter/material.dart';

import 'dart:io';

import 'package:journeyers/core/utils/files/files_utils.dart';

/// {@category Group problem-solving}
/// A preview widget used for the group problem-solving dashboard.
class GroupProblemSolvingPreviewWidget extends StatefulWidget {
  final String pathToStoredData;

  const GroupProblemSolvingPreviewWidget({
    super.key,
    required this.pathToStoredData,
  });

  @override
  State<GroupProblemSolvingPreviewWidget> createState() =>
      _GroupProblemSolvingPreviewWidgetState();
}

class _GroupProblemSolvingPreviewWidgetState
    extends State<GroupProblemSolvingPreviewWidget> {
    // Utility classes
  final FileUtils fu = FileUtils();   

  bool _isLoading = true;
  String _title = "";
  String _dateString = "";
  List<String> _solutions = [];

  @override
  void initState() {
    super.initState();
    _fetchingData();
  }

  Future<void> _fetchingData() async {
    try {
      List<String> lines = [];
      if (Platform.isAndroid || Platform.isIOS)
      {
        String content = await fu.readTextContentOnMobile(pathToData: widget.pathToStoredData);
        lines = LineSplitter.split(content).toList();
      }
      else
      {
        final file = File(widget.pathToStoredData);
        if (await file.exists()) 
        {
          lines = await file.readAsLines();
        }
      }

      if (lines.length >= 2) {
        _title = lines[1];
        // Extract date from the second line: "Date: MMMM dd, yyyy h:mm a"
        _dateString = lines[2].replaceFirst("Date: ", "");
        
        // Solutions start after the "---" separator (index 3 onwards)
        // We strip the "1. ", "2. " numbering prefix
        _solutions = lines
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
            "Solutions for $_title\n$_dateString",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        const Divider(),
        ..._solutions.map((solution) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
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