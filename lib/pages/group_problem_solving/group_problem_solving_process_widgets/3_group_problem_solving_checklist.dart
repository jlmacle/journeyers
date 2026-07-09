import 'package:flutter/material.dart';

import 'package:journeyers/app_themes.dart';
import 'package:journeyers/debug_constants.dart';
import 'package:journeyers/pages/group_problem_solving/group_problem_solving_process_widgets/_group_problem_solving_externalized_variables.dart';
import 'package:journeyers/utils/generic/dev/utility_classes_import.dart';

/// {@category Group problem-solving}
/// A checklist widget used for the group problem-solving process.
class GPSChecklist extends StatefulWidget {
  const GPSChecklist({super.key});

  @override
  State<GPSChecklist> createState() => _GPSChecklistState();
}

class _GPSChecklistState extends State<GPSChecklist> {  

  // Helper method to check if all items are completed
  bool get _isAllChecked => checklistItems.values.every((element) => element == true);

  @override
  void initState() {
    super.initState();
            
    if (widgetSequenceDebug) pu.printdLine();
    if (widgetSequenceDebug) pu.printd("GPSChecklist");
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showChecklistOverlay(context),
      child: Container(
        decoration: BoxDecoration(
          // Logic: If all checked, color is white; otherwise, orangeShade900
          border: Border.all(
            color: _isAllChecked ? Colors.transparent : rectangleColor, 
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
              child: Text(checkListTitle, style: problemSolvingChecklistTitle),
            )
          ],
        ),
      ),
    );
  }

  void _showChecklistOverlay(BuildContext context) {
    const String title = 'Please consider postponing\n'
                          'the group problem-solving\n'
                          'if the checklist is incomplete.';

    showGeneralDialog(
      context: context,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: true, 
            toolbarHeight: 90.00,
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
                tooltip: closeChecklistTooltipLabel,
                color: appBarWhite,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          body: SafeArea(
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setLocalState) {
                return ListView(
                  children: checklistItems.keys.map((String key) {
                    bool isChecked = checklistItems[key] ?? false;

                    return CheckboxListTile(
                      title: Text(key),
                      value: isChecked,
                      activeColor: checklistItemCheckedColor,
                      tileColor: isChecked ? const Color(0xFFE8F5E9) : null,
                      onChanged: (bool? value) {
                        setLocalState(() {
                          checklistItems[key] = value ?? false;
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