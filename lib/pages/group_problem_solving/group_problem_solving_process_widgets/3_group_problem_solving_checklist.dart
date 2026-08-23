import "package:flutter/material.dart";

import "package:journeyers/app_themes.dart";
import "package:journeyers/debug_constants.dart";
import "package:journeyers/l10n/app_localizations.dart";
import "package:journeyers/l10n/localized_gps_strings.dart";
import "package:journeyers/pages/group_problem_solving/group_problem_solving_process_widgets/_group_problem_solving_externalized_variables.dart";
import "package:journeyers/utils/generic/dev/utility_classes_import.dart";

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

  // Localized strings for the checklist
  late LocalizedGPSStrings lgps;
  late Map<String, bool> checklistItems;    

  @override
  void initState() {
    super.initState();
            
    if (widgetSequenceDebug) pu.printdLine();
    if (widgetSequenceDebug) pu.printd("GPSChecklist");
  }

  @override
  Widget build(BuildContext context) {
    // Accessing the localized data
    LocalizedGPSStrings lgps = .new(context);

    checklistItems = {
      lgps.checkListQuestion1: false,
      "Is our context analysis done?": false,
      "Is the group open to using the app for group problem-solving?": false,    
      "Is the group emotionally ready to problem-solve?": false,    
      "Did we agree on what to do if emotions become problematic?": false,
      "Do we agree on the problem that needs to be solved?": false,
      "Did we agree on the order in which to offer the ideas?":false,
      "Can we find reasons why presenting or receiving the ideas, in a neutral tone, could be important?":false,
      "Do we need to further our context analysis?": false,
    };

    return 
    GestureDetector(
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.only(right: 15),
              child: Icon(Icons.checklist_rounded),
            ),
            Center(
              child: Text
              (
                AppLocalizations.of(context)?.gps_process_checklist_title ?? "Issue with the default title for the checklist-related widget.",
                style: problemSolvingChecklistTitle
              ),
            )
          ],
        ),
      ),
    );
  }

  void _showChecklistOverlay(BuildContext context) {
    LocalizedGPSStrings lgps = .new(context);
    var title = lgps.checkListAppBarTitle;

    showGeneralDialog(
      context: context,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: true, 
            toolbarHeight: 90.00,
            title: 
            Padding
            (
              padding: const EdgeInsets.all(8.0), 
              child: Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 20,
                overflow: TextOverflow.visible,
                softWrap: true,
                style: problemSolvingChecklistMessageStyle,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.close),
                tooltip: AppLocalizations.of(context)?.gps_process_checklist_close_overlay_tooltip ?? "Issue with the l10n for the 'Close checklist' tooltip",
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