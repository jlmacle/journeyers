import 'package:flutter/material.dart';

import 'package:journeyers/app_themes.dart';
import 'package:journeyers/core/utils/csv/csv_utils.dart';
import 'package:journeyers/core/utils/form/form_utils.dart';
import 'package:journeyers/core/utils/printing_and_logging/print_utils.dart';

CSVUtils cu = CSVUtils();
PrintUtils pu = PrintUtils();

class ContextAnalysisPreviewWidget extends StatefulWidget 
{
  final String pathToCsvData;

  const ContextAnalysisPreviewWidget({
    super.key, 
    required this.pathToCsvData
  });

  @override
  State<ContextAnalysisPreviewWidget> createState() => _ContextAnalysisPreviewWidgetState();
}

class _ContextAnalysisPreviewWidgetState extends State<ContextAnalysisPreviewWidget> 
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
    pu.printd("pathToCsvData:${widget.pathToCsvData}");
    Map<String, List<dynamic>> perspectiveData = await cu.csvFileToPreviewPerspectiveData(widget.pathToCsvData);
    await perspectiveDataToDataStructures(perspectiveData);
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> perspectiveDataToDataStructures(Map<String, List<dynamic>> perspectiveData) async
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
      if (cu.titlesLevel2.contains(secondValue)) 
      {
        currentTitleLevel2 = secondValue;
        // Adding the level 2 title, as value of the "title" key.
        sectionsIndividual["title"] = secondValue;
      }
      // A title level 3?: "A Balance Issue?" for ex.
      else if (cu.titlesLevel3ForTheIndividualPerspective.contains(secondValue)) 
      {
        // Adding a new map to the list of the key "questions", with the title level 3 as value for the key "title",
        // and an empty list for the key "items".
        sectionsIndividual["questions"].add({"title": secondValue, "items":[]});
        currentTitleLevel3 = secondValue;                
      }
      // A title level 3 item?: "To balance studies and household life?" for ex.
      // Could be a checkbox or a text field.
      else if (cu.mappingLabelsToInputItems.keys.contains(secondValue))
      {
        currentTitleLevel3Item = secondValue;
        // Checking if an 'X' is in front of the title level 3, and if the item is also a checkbox
        if (firstValue == 'X' && cu.mappingLabelsToInputItems[currentTitleLevel3Item] == FormUtils.checkbox) 
          {checkedBox = true;}
        else 
          {checkedBox = false;}

        // Retrieving the map with the same title level 3
        for (var map in sectionsIndividual["questions"])
        {
          // The titles level 3 with sub items are also the ones with checkboxes and text fields
          if (map["title"] == currentTitleLevel3 && cu.titlesLevel3WithSubItems.contains(currentTitleLevel3))
          {
            // Adding a map to the items list, with data related to whether the checkbox is checked or not
            // and an empty value for the "notes" key.
            if (checkedBox)
              {map["items"].add({"text":secondValue, "checked":"yes", "notes":""});}
            else
              {map["items"].add({"text":secondValue, "checked":"", "notes":""});}
          }
          // if no sub items, that should be the text field only
          else if (map["title"] == currentTitleLevel3 && !cu.titlesLevel3WithSubItems.contains(currentTitleLevel3))
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
        if (cu.titlesLevel3WithSubItems.contains(currentTitleLevel3))
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
      if (cu.titlesLevel2.contains(secondValue)) 
      {
        currentTitleLevel2 = secondValue;
        // Adding the level 2 title, as value of the "title" key.
        sectionsGroup["title"] = secondValue;
        // Useful to identify the text only text field
        previousSecondValueFromSegButton = false;        
      }
      // A title level 3?: "What problem(s) are the groups/teams trying to solve?" for ex.
      else if (cu.titlesLevel3ForTheGroupPerspective.contains(secondValue)) 
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
    
    pu.printd("");
    pu.printd("sectionsIndividual:");
    pu.printd(sectionsIndividual);
    pu.printd("");
    pu.printd("sectionsGroup:");
    pu.printd(sectionsGroup);
  }

  @override
  Widget build(BuildContext context) 
  {
    return _isLoading
      ?  Center(child:CircularProgressIndicator())
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
                      Padding
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
              Divider(thickness: 3, color: Colors.black),
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
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
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
                          leading: Icon(Icons.text_snippet),
                          title: Text                            
                          ( 
                            question["items"]["segValue"] == null
                            ?
                            'Notes: ${question["items"]["notes"] ?? ""}'
                            :
                            'Answer: ${question["items"]["segValue"] ?? ""}'
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