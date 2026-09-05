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

  late LocalizedGPSStrings lgps;

  // Localized checklist items.
  Map<String, bool> checklistItems = {};

  @override
  void initState() {
    super.initState();

    if (widgetSequenceDebug) pu.printdLine();
    if (widgetSequenceDebug) pu.printd("GPSChecklist");
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Safe place for InheritedWidget-based lookups per the Flutter docs:
    // https://api.flutter.dev/flutter/widgets/State/didChangeDependencies.html
    lgps = .new(context);

    // Building the checklist map once, the first time strings are available.
    checklistItems = {
      lgps.checkListQuestion1: false,
      lgps.checkListQuestion2: false,
      lgps.checkListQuestion3: false,
      lgps.checkListQuestion4: false,
      lgps.checkListQuestion5: false,
      lgps.checkListQuestion6: false,
      lgps.checkListQuestion7: false,
      lgps.checkListQuestion8: false,
      lgps.checkListQuestion9: false,
    };

  }

  @override
  Widget build(BuildContext context) {

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
                tooltip: lgps.closeChecklistTooltipLabel,
                color: appBarWhite,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          body: SafeArea(
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setLocalState) {
                final keys = checklistItems.keys.toList();
                return 
                ListView(
                  key: const Key("gps-checklist-process-scrollview"),
                  children: keys.asMap().entries.map((entry) {
                    final int index = entry.key;
                    final String key = entry.value;
                    bool isChecked = checklistItems[key] ?? false;

                    return CheckboxListTile(
                      key: Key("gps-checklist-checkbox-$index"),
                      title: Text(key),
                      value: isChecked,
                      activeColor: checkboxCheckedColor,
                      tileColor: isChecked ? checkboxCheckedListTileColor : white,
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