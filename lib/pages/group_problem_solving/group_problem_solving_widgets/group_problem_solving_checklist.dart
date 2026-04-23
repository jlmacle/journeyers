import 'package:flutter/material.dart';

import 'package:journeyers/app_themes.dart';

/// {@category Group problem-solving}
/// A checklist widget used for the group problem-solving process.
class GPSChecklist extends StatefulWidget {
  const GPSChecklist({super.key});

  @override
  State<GPSChecklist> createState() => _GPSChecklistState();
}

class _GPSChecklistState extends State<GPSChecklist> {
  final Map<String, bool> _checklistItems = {
    "Is our context analysis done?": false,
    "Is the group open to using the app for group problem-solving?": false,
    "Is the group emotionally ready to problem-solve?": false,
    "Did we agree on what to do if emotions become problematic?": false,
    "Do we agree on the problem that needs to be solved?": false,
    "Did we agree on the order in which to offer the solutions?":false,
    "Do we need to further our context analysis?": false,
  };

  // Helper method to check if all items are completed
  bool get _isAllChecked => _checklistItems.values.every((element) => element == true);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showChecklistOverlay(context),
      child: Container(
        decoration: BoxDecoration(
          // Logic: If all checked, color is white; otherwise, orangeShade900
          border: Border.all(
            color: _isAllChecked ? Colors.white : orangeShade900, 
            width: 5.0,
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(right: 15),
              child: Icon(Icons.checklist_rounded),
            ),
            Center(
              child: Text("Checklist", style: problemSolvingChecklistTitle),
            )
          ],
        ),
      ),
    );
  }

  void _showChecklistOverlay(BuildContext context) {
    const String title = "Please consider postponing the group problem-solving if the checklist is incomplete";

    showGeneralDialog(
      context: context,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: true, 
            automaticallyImplyLeading : false,
            title: 
            const Padding
            (
              padding: EdgeInsets.all(16.0), 
              child: Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 20,
                overflow: TextOverflow.visible,
                softWrap: true,
                style: problemSolvingChecklistMessage,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.close),
                color: appBarWhite,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          body: SafeArea(
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setLocalState) {
                return ListView(
                  children: _checklistItems.keys.map((String key) {
                    bool isChecked = _checklistItems[key] ?? false;

                    return CheckboxListTile(
                      title: Text(key),
                      value: isChecked,
                      activeColor: Colors.green,
                      tileColor: isChecked ? const Color(0xFFE8F5E9) : null,
                      onChanged: (bool? value) {
                        setLocalState(() {
                          _checklistItems[key] = value ?? false;
                        });
                        // Triggers a rebuild of the main widget to update the border color
                        setState(() {}); 
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ),
        );
      },
    );
  }
}