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

  //  The following structure, more complex to build, was producing an easier preview code
  Future<void> perspectiveDataToDataStructures(Map<String, List<dynamic>> perspectiveData) async
  {
    List<dynamic> individualPerspective = perspectiveData["individualPerspective"]!;
    List<dynamic> groupPerspective = perspectiveData["groupPerspective"]!;

    // Building the structure related to the individual perspective
    // [, As an individual: What problem am I trying to solve?], 
    // [X, A Balance Issue?], [X, To balance studies and household life?], [Notes:, "studies/household"]
    // [X, Is the issue of another type?], [Notes:, "another, issue"]]
    sectionsIndividual["questions"] = [];
    String currentLevel2Title = "";
    String currentLevel3Title = "";
    String currentLevel3TitleItem = "";
    bool checkedBox = false;
    
    for (var individualPerspectiveItem in individualPerspective)
    {
      String firstValue = individualPerspectiveItem[0];
      String secondValue = individualPerspectiveItem[1];    

      if (cu.titlesLevel2.contains(secondValue)) 
      {
        sectionsIndividual["title"] = secondValue;
        currentLevel2Title = secondValue;
        // Adding the level 2 title 
        sectionsIndividual["title"] = secondValue;
      }
      else if (cu.titlesLevel3ForTheIndividualPerspective.contains(secondValue)) 
      {
        sectionsIndividual["questions"].add({"title": secondValue, "items":[]});
        currentLevel3Title = secondValue;                
      }
      else if (cu.mappingLabelsToInputItems.keys.contains(secondValue))
      {
        currentLevel3TitleItem = secondValue;
        // checking if an 'X' is in front of the title level 3 that is also a checkbox
        if (firstValue == 'X' && cu.mappingLabelsToInputItems[currentLevel3TitleItem] == FormUtils.checkbox) 
          {checkedBox = true;}
        else 
          {checkedBox = false;}

        // Retrieving the map with the right level 3 title
        for (var map in sectionsIndividual["questions"])
        {
          // the titles level 3 with sub items are also the ones with checkboxes and text fields
          if (map["title"] == currentLevel3Title && cu.titlesLevel3WithSubItems.contains(currentLevel3Title))
          {
            // Adding the items list the notes
            if (checkedBox)
              {map["items"].add({"text":secondValue, "checked":"yes", "notes":""});}
            else
              {map["items"].add({"text":secondValue, "checked":"", "notes":""});}
          }
          // no sub items, that should be the text field only
          else if (map["title"] == currentLevel3Title && !cu.titlesLevel3WithSubItems.contains(currentLevel3Title))
          {
            // Removing straight quotes
            map["items"].add({"notesTextField":secondValue.replaceAll('"', '')});
          }
        }
      }
      // That should be a field with notes
      else 
      {
        // if sub items, then checkbox item with a note
        if (cu.titlesLevel3WithSubItems.contains(currentLevel3Title))
        {
          for(var map in sectionsIndividual["questions"])
          {
            if (map["title"] == currentLevel3Title)
            {
              for (var itemMap in map["items"])
              {
                if (itemMap["text"] == currentLevel3TitleItem)
                {
                  // Removing straight quotes
                  itemMap["notes"] = secondValue.replaceAll('"', '');
                }
              }
            }
          }
        }
        // otherwise, a text field only
        else
        {
          for(var map in sectionsIndividual["questions"])
          {
            if (map["title"] == currentLevel3Title)
            {
              // at this point, no item is set yet
              map["items"].add({"notesTextField": secondValue.replaceAll('"', '')});
            }
          }          
        }
      }
    }

    // Building the structure related to the group perspective
    // [, As a member of groups/teams: What problem(s) are we trying to solve?], 
    // [X, What problem(s) are the groups/teams trying to solve?], [Notes:, " "groups/teamsProblems"], 
    // [X, Am I trying to solve the same problem(s) as my groups/teams?], 
    //    [, Yes], [Notes:, " "sameProblems"]

    // The structure for items is different
   
    sectionsGroup["questions"] = [];
    currentLevel2Title = "";
    currentLevel3Title = "";
    currentLevel3TitleItem = "";
    bool previousSecondValueFromSegButton = false; 

    for (var groupPerspectiveItem in groupPerspective)
    {
      String firstValue = groupPerspectiveItem[0]; 
      String secondValue = groupPerspectiveItem[1]; 

      if (cu.titlesLevel2.contains(secondValue)) 
      {
        currentLevel2Title = secondValue;
        // Adding the level 2 title 
        sectionsGroup["title"] = secondValue;
        previousSecondValueFromSegButton = false;        
      }
      else if (cu.titlesLevel3ForTheGroupPerspective.contains(secondValue)) 
      {
        sectionsGroup["questions"].add({"title": secondValue, "items":{}});
        currentLevel3Title = secondValue;
        previousSecondValueFromSegButton = false;
      }
      // Segmented button 
      else if (firstValue.trim() == "")
      {
        for (var map in sectionsGroup["questions"])
        {
          if (map["title"] == currentLevel3Title)
          {
            map["items"]["segValue"] = secondValue;
            previousSecondValueFromSegButton = true;
            break;
          }
        }
      }
      // a note either with a segmented button, or of a text field only
      else
      {
        // a note of a text field only
        if (previousSecondValueFromSegButton == false) 
        {
          for (var map in sectionsGroup["questions"])
          {
            if (map["title"] == currentLevel3Title)
            {
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
            if (map["title"] == currentLevel3Title)
            {
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