import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_form_widgets/context_analysis_form_text_field_misc_constants.dart';
import 'package:journeyers/utils/project_specific/dev/utility_classes_import.dart';

import 'package:path/path.dart' as path;

import 'package:journeyers/app_themes.dart';
import 'package:journeyers/debug_constants.dart';
import 'package:journeyers/utils/generic/dev/externalized_test_strings.dart';
import 'package:journeyers/utils/generic/dev/utility_classes_import.dart';


/// {@category Context analysis}
/// A preview widget used in the context analysis dashboard.
class CAPreviewWidget extends StatefulWidget 
{
  /// The path to the stored context analysis data.
  final String pathToStoredData;

  const CAPreviewWidget({
    super.key, 
    required this.pathToStoredData
  });

  @override
  State<CAPreviewWidget> createState() => _CAPreviewWidgetState();
}

class _CAPreviewWidgetState extends State<CAPreviewWidget> 
{
  bool _isLoading = true;
  final Map<String, dynamic> sectionsIndividual = {};
  final Map<String, dynamic> sectionsGroup = {};
  
  @override
  void initState() 
  {
    super.initState();
    _fetchingData();
  }

  Future<void> _fetchingData() async
  {
    if (previewBuildingDebug) pu.printd("Preview Building: pathToCsvData:${widget.pathToStoredData}");

    if (pathsForTestFiles.contains(widget.pathToStoredData)) 
    {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }
        
    
    Map<String, List<dynamic>> perspectiveData = await caCSVFileToPreviewPerspectiveData(widget.pathToStoredData);
    await _perspectiveDataToDataStructures(perspectiveData);
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // ─── METHODS RETRIEVING THE CSV DATA FOR VIEWING : beginning ───────────────────────────────────────
  // Method used to map a line of CSV to data
  Future<List<String>> _csvLineToData(String line) async
  {
    List<String> data = [];
    bool inQuotes = false;
    String itemData = "";

    for (var index = 0; index < line.length ;  index++)
    {
      var char = line[index]; 

      // reaching a ',' while not being inside quotes
      // reaching the end of the itemData
      if (char == "," && inQuotes == false)
      {
        data.add(itemData);
        // resetting itemData
        itemData = "";
      }
      // adding to the itemData
      else
      {
        itemData += char;
        if (char == quotesForCSV) inQuotes = !inQuotes;
      }      
    }
    // Adding the last item data (no ',' reachable for the last item with the current code)
    data.add(itemData);
    print("data: $data");

    return data;
  }
  
  Future<void> _perspectiveDataToDataStructures(Map<String, List<dynamic>> perspectiveData) async
  {
    List<dynamic> individualPerspective = perspectiveData["individualPerspective"]!;
    List<dynamic> groupPerspective = perspectiveData["groupPerspective"]!;

    sectionsIndividual["questions"] = [];
    String currentTitleLevel2 = "";
    String currentTitleLevel3 = "";
    String currentTitleLevel3Item = "";
    bool checkedBox = false;
         
    // Data structure for the preview of the individual perspective 
    //  {
    //    questions: 
    //    [
    //      {
    //        title: A Balance Issue?, 
    //        items: 
    //        [
    //          {text: To balance studies and household life?, checked: yes, notes: about studies}, 
    //          {text: To balance accessing income and household life?, checked: , notes: }, 
    //          {text: To balance earning an income and household life?, checked: , notes: }, 
    //          {text: To balance helping others and household life?, checked: , notes: }
    //        ]
    //      }, 
    //      ...,
    //    ], 
    //    title: As an individual: What problem am I trying to solve?
    //  }

    // Building the structure related to the individual perspective
    // [, As an individual: What problem am I trying to solve?], 
    // [X, A Balance Issue?], 
    // [X, To balance studies and household life?], 
    // [Notes:, "about studies"]
    // [X, Is the issue of another type?], 
    // [Notes:, "another issue"]]
    // To be noted that the last 'X' is not related to a checkbox, but to a choice in the CSV formatting.

    //****** The individual perspective is made of checkboxes displaying a text field when checked, ******//
    //****** except for the last input item made of a text field.                                   ******//
    // The second value can be a title level 2, a title level 3, a title level 3 item, or a note
    for (var individualPerspectiveItem in individualPerspective)
    {
      String firstValue = individualPerspectiveItem[0];
      String secondValue = individualPerspectiveItem[1];    
      
      // A title Level 2?: "As an individual: What problem am I trying to solve?", in the case of the individual perspective.
      if (qf.titlesLevel2.contains(secondValue)) 
      {
        currentTitleLevel2 = secondValue;
        // Adding the level 2 title, as value of the "title" key.
        sectionsIndividual["title"] = secondValue;
      }
      // A title level 3?: "A Balance Issue?" for ex.
      else if (qf.titlesLevel3ForTheIndividualPerspective.contains(secondValue)) 
      {
        // Adding a new map to the list of the key "questions", with the title level 3 as value for the key "title",
        // and an empty list for the key "items".
        sectionsIndividual["questions"].add({"title": secondValue, "items":[]});
        currentTitleLevel3 = secondValue;                
      }
      // A title level 3 item?: "To balance studies and household life?" for ex.
      // Could be a checkbox or a text field.
      else if (qf.mappingLabelsToInputItems.keys.contains(secondValue))
      {
        currentTitleLevel3Item = secondValue;
        // Checking if an 'X' is in front of the title level 3, and if the item is also a checkbox
        if (firstValue == 'X' && qf.mappingLabelsToInputItems[currentTitleLevel3Item] == qf.keyCheckbox) 
          {checkedBox = true;}
        else 
          {checkedBox = false;}

        // Retrieving the map with the same title level 3
        for (var map in sectionsIndividual["questions"])
        {
          // The qf.titles level 3 with sub items are also the ones with checkboxes and text fields
          if (map["title"] == currentTitleLevel3 && qf.titlesLevel3WithSubItems.contains(currentTitleLevel3))
          {
            // Adding a map to the items list, with data related to whether the checkbox is checked or not
            // and an empty value for the "notes" key.
            if (checkedBox)
              {map["items"].add({"text":secondValue, "checked":"yes", "notes":""});}
            else
              {map["items"].add({"text":secondValue, "checked":"", "notes":""});}
          }
          // if no sub items, that should be the text field only
          else if (map["title"] == currentTitleLevel3 && !qf.titlesLevel3WithSubItems.contains(currentTitleLevel3))
          {
            // Adding a map to the items list, with the notesTextField with an empty value.
            map["items"].add({"notesTextField":""});
          }
        }
      }
      // That should be a field with notes, either from a checkbox, or from a text field only
      else 
      {
        // If the current title level 3 has sub items, then a note for a checkbox
        if (qf.titlesLevel3WithSubItems.contains(currentTitleLevel3))
        {
          for(var map in sectionsIndividual["questions"])
          {
            // Searching for the current title level 3
            if (map["title"] == currentTitleLevel3)
            {
              for (var itemMap in map["items"])
              {
                // Searching for the current title level 3 item
                if (itemMap["text"] == currentTitleLevel3Item)
                {
                  // Removing added straight quotes before adding the note content
                  itemMap["notes"] = secondValue.replaceAll('"', '');
                }
              }
            }
          }
        }
        // Otherwise, a note for a text field only
        else
        {
          for(var map in sectionsIndividual["questions"])
          {
            if (map["title"] == currentTitleLevel3)
            {
              // At this point, no item is set yet + Removing added straight quotes
              map["items"].add({"notesTextField": secondValue.replaceAll('"', '')});
            }
          }          
        }
      }
    }

    // Building the structure related to the group perspective  
    sectionsGroup["questions"] = [];
    currentTitleLevel2 = "";
    currentTitleLevel3 = "";
    currentTitleLevel3Item = "";
    bool previousSecondValueFromSegButton = false; 

    // Data structure for the preview of the group perspective
    // To note: the structure for the items is different. 
    // {
    //   questions: 
    //   [
    //      {
    //        title: What problem(s) are the groups/teams trying to solve?, 
    //        items: {notes: group problematics}
    //      }, 
    //      {
    //        title: Am I trying to solve the same problem(s) as my groups/teams?, 
    //        items: {segValue: Yes, notes: }
    //      }, 
    //      {
    //        title: Is entering the group problem-solving process consistent with harmony at home?, 
    //        items: {segValue: No, notes: }
    //      }, 
    //      {
    //        title: Is entering the group problem-solving process consistent with appreciability at work?, 
    //        items: {segValue: I don't know, notes: about appreciability at work}
    //      }, 
    //      {
    //        title: Is entering the group problem-solving process consistent with my income earning ability?, 
    //        items: {segValue: Yes, notes: }
    //      }
    //    ], 
    //    title: As a member of groups/teams: What problem(s) are we trying to solve?
    //  }

    // [, As a member of groups/teams: What problem(s) are we trying to solve?], 
    // [X, What problem(s) are the groups/teams trying to solve?], 
    // [Notes:, "group problematics"], 
    // [X, Am I trying to solve the same problem(s) as my groups/teams?], 
    // [, Yes], 
    // [Notes:, ""]

    //****** The group perspective is made of segmented buttons displaying a text field when an selection occurs,  ******//
    //****** except for the first input item made of a text field.                                                 ******//
    // The second value can be a title level 2, a title level 3, a segmented button value, or a note.
    
    // For the preview of the group data, all fields are kept, even if empty.
    for (var groupPerspectiveItem in groupPerspective)
    {
      String firstValue = groupPerspectiveItem[0]; 
      String secondValue = groupPerspectiveItem[1]; 

      // A title Level 2?: "As a member of groups/teams: What problem(s) are we trying to solve?", in the case of the group perspective.
      if (qf.titlesLevel2.contains(secondValue)) 
      {
        currentTitleLevel2 = secondValue;
        // Adding the level 2 title, as value of the "title" key.
        sectionsGroup["title"] = secondValue;
        // Useful to identify the text only text field
        previousSecondValueFromSegButton = false;        
      }
      // A title level 3?: "What problem(s) are the groups/teams trying to solve?" for ex.
      else if (qf.titlesLevel3ForTheGroupPerspective.contains(secondValue)) 
      {
        sectionsGroup["questions"].add({"title": secondValue, "items":{}});
        currentTitleLevel3 = secondValue;
        previousSecondValueFromSegButton = false;
      }
      // A segmented button ?
      else if (firstValue.trim() == "")
      {
        for (var map in sectionsGroup["questions"])
        { 
          // Looking for the right map in the values of "questions"
          if (map["title"] == currentTitleLevel3)
          {
            // Adding the value linked to the segmented button, potentially "".
            map["items"]["segValue"] = secondValue;
            previousSecondValueFromSegButton = true;
            break;
          }
        }
      }
      // A note either with a segmented button, or of a text field only
      else
      {
        // a note of a text field only
        if (previousSecondValueFromSegButton == false) 
        {
          for (var map in sectionsGroup["questions"])
          {
            if (map["title"] == currentTitleLevel3)
            {
              // Removing added straight quotes
              map["items"]["notes"] = secondValue.replaceAll('"', '');
              previousSecondValueFromSegButton = false;
              break;
            }
          }            
        }
        // a note with a segmented button
        else
        { 
          for (var map in sectionsGroup["questions"])
          {
            if (map["title"] == currentTitleLevel3)
            {
              // Removing added straight quotes
              map["items"]["notes"] = secondValue.replaceAll('"', '');
              previousSecondValueFromSegButton = true;
              break;
            }
          }   
        }
      }
    }
    
    if (previewBuildingDebug) pu.printd("Preview Building");
    if (previewBuildingDebug) pu.printd("Preview Building: sectionsIndividual:");
    if (previewBuildingDebug) pu.printd(sectionsIndividual);
    if (previewBuildingDebug) pu.printd("Preview Building");
    if (previewBuildingDebug) pu.printd("Preview Building: sectionsGroup:");
    if (previewBuildingDebug) pu.printd(sectionsGroup);
  }

  /// Method used to retrieve data from the CSV file and to return a list of csvDataIndividualPerspective and csvDataGroupPerspective structures
  Future<Map<String,List<Object>>> caCSVFileToPreviewPerspectiveData(String pathToCSVFile) async
  {
    // Checking if the path is a path for a test (TODO: to cleanup/dto)
    if (pathsForTestFiles.contains(pathToCSVFile)) {
      return 
      {
        "individualPerspective":
        [["", "As an individual: What problem am I trying to solve?"], ["", "A Balance Issue?"], 
      ["", "To balance studies and household life?"], ["", "To balance accessing income and household life?"], 
      ["", "To balance earning an income and household life?"], ["", "To balance helping others and household life?"], 
      ["", "A Workplace Issue?"], ["", "To solve a need to be more appreciated at work?"], 
      ["", "To solve a need to remain appreciated at work?"], ["", "A Legacy Issue?"], 
      ["", "To have better legacies to leave to our children/others?"], ["", "Is the issue of another type?"]], 
      "groupPerspective":
      [["", "As a member of groups/teams: What problem(s) are we trying to solve?"], 
      ["X", "What problem(s) are the groups/teams trying to solve?"], ["Notes:", "b1"], 
      ["X", "Am I trying to solve the same problem(s) as my groups/teams?"], ["", "Yes/No"], 
      ["Notes:", "b2"], ["", "Is entering the group problem-solving process consistent with harmony at home?"], 
      ["", "Is entering the group problem-solving process consistent with appreciability at work?"], 
      ["", "Is entering the group problem-solving process consistent with my income earning ability?"]]
      };
    }

    Map<String,List<Object>> perspectiveData = {};
    // Some empty lines have been added for the csv formatting
    List<List<String>> individualPerspective = [];
    List<List<String>> groupPerspective = [];

    List<String> csvLines = [""];

    if (Platform.isAndroid)
    {
      String fileName = path.basename(pathToCSVFile);
      if (previewBuildingDebug) pu.printd("Preview Building: caCSVFileToPreviewPerspectiveData on Android");
      final String content = await fu.readTextContentOnAndroid(fileName: fileName);
      csvLines = LineSplitter.split(content).toList();
    }
    else if (Platform.isIOS)
    {
      String fileName = path.basename(pathToCSVFile);
      if (previewBuildingDebug) pu.printd("Preview Building: caCSVFileToPreviewPerspectiveData on iOS");
      final String content;
      try
      {
        content = await fu.readTextContentOnIOS(fileName: fileName);
        csvLines = LineSplitter.split(content).toList();
      }
      on PlatformException
      catch(e) {pu.printd("CSV Utils: ${e.message}"); }
    }
    else if (Platform.isLinux || Platform.isMacOS | Platform.isWindows)
    {
      // Checking if the CSV file exists
      File csvFile = File(pathToCSVFile);
      if (!csvFile.existsSync()) throw Exception("The CSV file doesn't exist: $pathToCSVFile");
      // Loading the file content
      csvLines = csvFile.readAsLinesSync();
    }

    // Mapping the data toward the individual and group perspectives
    for(var line in csvLines)
    {
      List<String> lineData = await _csvLineToData(line);

      // 5 fields
      // the first 2 fields are for the individual perspective
      // the last 2 fields are for the group perspective
      List<String> individualPerspectiveItem = [];
      List<String> groupPerspectiveItem = [];

      for (var index = 0; index < 5; index++)
      {
        if (index == 0 || index == 1)
        {
          individualPerspectiveItem.add(lineData[index].trim());
          if (index == 1)
          {
            individualPerspective.add(individualPerspectiveItem);
            individualPerspectiveItem = [];
          }
        }
        else if (index == 3 || index == 4)
        {
          groupPerspectiveItem.add(lineData[index].trim());
          if (index == 4)
          {
            groupPerspective.add(groupPerspectiveItem);
            groupPerspectiveItem = [];
          }
        }
      }
    }

    // Removing empty lines
    List<List<String>> individualPerspectiveWithoutEmptyLines = [];
    List<List<String>> groupPerspectiveWithoutEmptyLines = [];

    individualPerspectiveWithoutEmptyLines = 
      individualPerspective.where
      (
        (data) => data.join().trim().isNotEmpty
      ).toList();

    groupPerspectiveWithoutEmptyLines = 
      groupPerspective.where
      (
        (data) => data.join().trim().isNotEmpty
      ).toList();

    if (previewBuildingDebug) pu.printd("Preview Building: Data after removing empty lines:");
    if (previewBuildingDebug) pu.printd("Preview Building: individualPerspectiveWithoutEmptyLines: $individualPerspectiveWithoutEmptyLines");
    if (previewBuildingDebug) pu.printd("Preview Building: groupPerspectiveWithoutEmptyLines: $groupPerspectiveWithoutEmptyLines");

    perspectiveData["individualPerspective"] = individualPerspectiveWithoutEmptyLines;
    perspectiveData["groupPerspective"] = groupPerspectiveWithoutEmptyLines;

    return perspectiveData;
  }
  // ─── METHODS RETRIEVING THE CSV DATA FOR VIEWING : end ───────────────────────────────────────

  @override
  Widget build(BuildContext context) 
  {
    return _isLoading
      ?  const Center(child:CircularProgressIndicator())
      : (pathsForTestFiles.contains(widget.pathToStoredData)) 
        ? const Text(testDataMessage)
        :  Column
          (
            crossAxisAlignment: CrossAxisAlignment.start,
            children: 
            [
                Column
                (
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: 
                  [
                    Padding
                    (
                      padding: const EdgeInsets.all(16.0),
                      child: Text
                      (
                        sectionsIndividual['title'] ?? "Untitled",
                        style: styleExpansionTileTitle
                      ),
                    ),

                    // Questions and potential answers for the individual perspective
                    ...
                    [
                      // "questions": list of maps with "title" and "items" as keys
                      // If no checkbox checked and no value for the text field only, a message to display
                      if 
                      (
                        sectionsIndividual['questions'].where
                        (
                          (question) => 
                            (question['items'] as List).any((item) => item['checked'] == "yes") 
                            ||
                            (question['items'] as List).any((item) => item['notesTextField'] != null && item['notesTextField'] != "")
                        ).isEmpty
                      )
                        const Padding
                        (
                          padding: EdgeInsets.only(left:16, top:8, bottom:8),
                          child: Text
                          (
                            'No question checked and no data in the last text field.',
                            style: styleDataAbsent
                          ),
                        )
                      else
                        // Otherwise, an expansion tile for each title level 3 with a checked checkbox or a text field only answer
                        for 
                        (
                          var question in sectionsIndividual['questions'].where
                          (
                            (question) => 
                              (question['items'] as List).any((item) => item['checked'] == 'yes') 
                              ||
                              (question['items'] as List).any((item) => item['notesTextField'] != null && item['notesTextField'] != "")
                          )
                      
                        )
                          ExpansionTile
                          (
                            // to remove the borders
                            shape: Border.all(color: Colors.transparent, width: 0),
                            initiallyExpanded: true,
                            title: Text
                            (
                              question['title'],
                              style: styleExpansionTileTitle
                            ),
                            children: 
                            [
                              // "items" in the individual perspective: list of maps with "text", "checked", "notes" and "notesTextField" as keys
                              for 
                              (var item in (question['items'] as List).where
                                (
                                  (item) => item['checked'] == 'yes' 
                                  ||
                                  item['notesTextField'] != null && item['notesTextField'] != ""                          
                                )
                              )
                                ListTile
                                (
                                  leading: Icon
                                  (
                                    item['checked'] != null
                                    ? Icons.check_box
                                    : Icons.text_snippet
                                  ),
                                  title: Text
                                  (
                                    item['text'] != null 
                                    ? item['text']
                                    :(item['notesTextField'] != null && item['notesTextField'] != "")
                                    ? "Notes: ${item['notesTextField']}"
                                    : "",
                                    style: styleExpandedTitleSubTitle                              
                                  ),
                                  subtitle: (item['notes'] != null)
                                    ? Text("Notes: ${item['notes']}", style: styleExpandedTitleSubTitle)
                                    : null,
                                ),
                            ],
                          ),
                      ],
                  ],
                ),
                const Divider(thickness: 3, color: Colors.black),
                Column
                (
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: 
                  [
                    Padding
                    (
                      padding: const EdgeInsets.only(left: 16, top: 8, bottom:8),
                      child: Text
                      (
                        sectionsGroup['title'],
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                      ),
                    ),
                    // Questions and potential answers for the group perspective
                    for (var question in sectionsGroup['questions'])
                      ExpansionTile
                      (
                        // to remove the borders
                        shape: Border.all(color: Colors.transparent, width: 0),                      
                        initiallyExpanded: true, 
                        title: Text
                        (
                          question['title'], 
                          style: styleExpansionTileTitle
                        ),
                        children: 
                        [
                          ListTile
                          (
                            leading: const Icon(Icons.text_snippet),
                            title: Text                            
                            ( 
                              question["items"]["segValue"] == null
                              ?
                              'Notes: ${question["items"]["notes"] ?? ""}'
                              :
                              'Answer(s): ${question["items"]["segValue"] ?? ""}'
                              '\nNotes: ${question["items"]["notes"] ?? ""}'
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
            ],
          );
    }
  }