import 'package:flutter/material.dart';
import 'package:journeyers/app_themes.dart';

class Checklist extends StatefulWidget {
  const Checklist({super.key});

  @override
  State<Checklist> createState() => _ChecklistState();
}

class _ChecklistState extends State<Checklist> {
  final Map<String, bool> _checklistItems = {
    "Is the context analysis done?": false,
    "Is the group open to use the app for group problem-solving?": false,
    "Is the group emotionally ready to problem-solve?": false,
    "Should we use indirect communication to group problem-solve?": false,
    "Do we agree on the problem needed to be solved?": false,
    "Do we need to further the context analysis?": false,
  };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showChecklistOverlay(context),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: orangeShade900, width: 2.0),
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
      barrierDismissible: true,
      barrierLabel: "Close Preview",
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: true, 
            title: 
            const Text
            (
              textAlign: TextAlign.center, maxLines:20, overflow: TextOverflow.visible, 
              softWrap:true, title, style: problemSolvingChecklistMessage
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
                      // Turns the checkbox itself green when checked
                      activeColor: Colors.green,
                      // Turns the entire tile background green when checked
                      tileColor: isChecked ? const Color(0xFFE8F5E9) : null,
                      onChanged: (bool? value) {
                        setLocalState(() {
                          _checklistItems[key] = value ?? false;
                        });
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