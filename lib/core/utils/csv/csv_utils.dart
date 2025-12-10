
import "dart:collection";
import "dart:io";

import "package:journeyers/core/utils/printing_and_logging/print_utils.dart";
import "package:journeyers/pages/context_analysis/context_analysis_context_form_questions.dart";

// Labels used in the form data
String checkbox = "checkbox";
String textField = "textField";
String segmentedButton = "segmentedButton";
String notes = "Notes:";


// Mapping questions to input widgets to process data according to input widgets
Map<String,String> mappingLabelsToInputItems 
= {
  //*********** Individual perspective ***********/
  // balance issue
  level3TitleBalanceIssueItem1:checkbox, level3TitleBalanceIssueItem2:checkbox,
  level3TitleBalanceIssueItem3:checkbox, level3TitleBalanceIssueItem4:checkbox,
  // workplace issue
  level3TitleWorkplaceIssueItem1:checkbox, level3TitleWorkplaceIssueItem2:checkbox,
  // legacy issue
  level3TitleLegacyIssueItem1:checkbox,
  // another type
  level3TitleAnotherIssue:textField,
  //*********** Group/team perspective ***********/
  // group problematics
  level3TitleGroupsProblematics:textField,
  // same problem?
  level3TitleSameProblem:segmentedButton,
  // harmony at home
  level3TitleHarmonyAtHome:segmentedButton,
  // appreciability at work
  level3TitleAppreciabilityAtWork:segmentedButton,
  // earning ability
  level3TitleIncomeEarningAbility:segmentedButton
 };

 // Defining the titles level 2
 var titlesLevel2 = {level2TitleIndividual, level2TitleGroup};

 // Defining the level 3 titles with items 1,2,
 Set<String>  titlesLevel3WithSubItems = {level3TitleBalanceIssue, level3TitleWorkplaceIssue,
                                          level3TitleLegacyIssue};

// pre CSV data  structure (before adding adding extra lines, removing or renaming keywords, ...)
List<dynamic> preCSVData = [];

//***************** Processing data according to input widgets: beginning  ***********************/

/// Method to convert information from {checkbox: false/true/null, textField: "data"/null} to:
/// checkbox, false/true
/// textField, "data"/""
List<dynamic> checkBoxWithTextFieldDataToPreCSV(LinkedHashMap<String, dynamic> checkBoxWithTextFieldtextData)
{
  List<dynamic> checkboxPreCSVData = []; 

  var dataCheckbox = "${checkBoxWithTextFieldtextData[checkbox]}";
  var data1 = [checkbox,dataCheckbox]; // label in front of the checkbox data in the pre CSV, to help with the processing toward the final CSV

  var dataTextField = checkBoxWithTextFieldtextData[textField] ?? "";
  var data2 = [notes,dataTextField]; // "Notes:" in front of the text field data in the pre CSV

  checkboxPreCSVData.add(data1);
  checkboxPreCSVData.add(data2);

  return checkboxPreCSVData;
}

// Method to convert information from {segmentedButton: Yes/No/I don't know/null , textField: "data"/null} to:
// segmentedButton,Yes/No/I don't know/""
// textField, "data"/""
List<dynamic> segmentedButtonWithTextFieldDataToPreCSV(LinkedHashMap<String, dynamic> segmentedButtonWithTextFieldData)
{
  List<dynamic> segmentedButtonPreCSVData = []; 

  var dataSegmentedButton = segmentedButtonWithTextFieldData[segmentedButton] ?? false;
  var data1 = ["",dataSegmentedButton]; // No label in front of the checkbox data in the pre CSV

  var dataTextField = segmentedButtonWithTextFieldData[textField] ?? "";
  var data2 = [notes,dataTextField]; // "Notes:" in front of the text field data in the pre CSV

  segmentedButtonPreCSVData.add(data1);
  segmentedButtonPreCSVData.add(data2);

  return segmentedButtonPreCSVData;
}

// Method to convert information from {textField: "data"/null} to:
// textField, "data"/""
List<dynamic> textFieldDataToPreCSV(LinkedHashMap<String, dynamic> textFieldData)
{
  List<dynamic> textFieldPreCSVData = []; 

  var dataTextField = textFieldData[textField] ?? "";
  var data = [notes,dataTextField]; // "Notes:" in front of the text field data in the pre CSV

  textFieldPreCSVData.add(data);

  return textFieldPreCSVData;
}

//***************** Processing data according to input widgets: beginning  ***********************/


// The data should be either the individual perspective data, or the group perspective data
List<dynamic> dataToPreCSV(LinkedHashMap<String,dynamic> enteredData)
{
  treatmentAccordingToInputType(List<dynamic> preCSVData, String itemOrTitleLable, LinkedHashMap<String,dynamic> level2Or3DataAsLinkedHashMap)
  {
    if (mappingLabelsToInputItems[itemOrTitleLable] == checkbox)
        {
          var checkboxPreCSVData = checkBoxWithTextFieldDataToPreCSV(level2Or3DataAsLinkedHashMap[itemOrTitleLable]);
          preCSVData.add(checkboxPreCSVData[0]);
          preCSVData.add(checkboxPreCSVData[1]);
        }
        else if (mappingLabelsToInputItems[itemOrTitleLable] == segmentedButton)
        {
          var segmentedButtonPreCSVData = segmentedButtonWithTextFieldDataToPreCSV(level2Or3DataAsLinkedHashMap[itemOrTitleLable]);
          preCSVData.add(segmentedButtonPreCSVData[0]);
          preCSVData.add(segmentedButtonPreCSVData[1]);
        }
        else if (mappingLabelsToInputItems[itemOrTitleLable] == textField)
        {
          var textFieldpreCSVData = textFieldDataToPreCSV(level2Or3DataAsLinkedHashMap[itemOrTitleLable]);          
          preCSVData.add(textFieldpreCSVData[0]);
        }
        else
        {
          printd("treatmentAccordingToInputType: no mapping found");
          printd("level3Title: $itemOrTitleLable");
          printd("mappingLabelsToInputItems[level3Title]: ${mappingLabelsToInputItems[itemOrTitleLable]}");
        }
  }

  List<dynamic> preCSVData = [];

  // There is only one key, the level 2 title
  var level2PreCSVData = ["",enteredData.keys.first];
  // Adding the level 2 title  //***Successful***/
  preCSVData.add(level2PreCSVData);

  // The values have the level 3 labels as keys
  for (var level2TitleData in enteredData.values)
  {
    var level2DataAsLinkedHashMap = level2TitleData as LinkedHashMap<String,dynamic>;
    
    // level 3 titles as keys of the level 2 data
    for (var level3Title in level2DataAsLinkedHashMap.keys)
    {      
      var level3TitlePreCSVData = ["", level3Title];
      // Adding the level 3 title  //***Successful***/
      preCSVData.add(level3TitlePreCSVData);

      // Checking if sub-items exist before processing the level 3 title data
      if(titlesLevel3WithSubItems.contains(level3Title))
      {
        // Going through the sub items
        var level3TitleItemsData  = level2DataAsLinkedHashMap[level3Title];
        var level3TitleItemsDataAsLinkedList = level3TitleItemsData as LinkedHashMap<String, dynamic>;
        for (var itemLabel in level3TitleItemsDataAsLinkedList.keys)
        {
           // Adding the item label  
          preCSVData.add(["", itemLabel]);

          // Adding input data
          treatmentAccordingToInputType(preCSVData, itemLabel, level3TitleItemsDataAsLinkedList);
        }

      }
      // Checking the type of input item that the level 3 title refers to
      else 
      {
        // Adding input data
        treatmentAccordingToInputType(preCSVData, level3Title, level2DataAsLinkedHashMap);
      }
    }
  }

  printd("");
  printd(preCSVData);
  return preCSVData;
}

// temporary method
void printPreCSVDataToConsole(List<dynamic> data) 
{
  for (var item in data)
  {
    var data = "${item[0]},${item[1]}";
    print(data);
  }
}

void printToCSV(String fileName, List<dynamic> data) async
{
  File file = File("txt.csv");
  var sink = file.openWrite(mode: FileMode.write); 

  for (var item in data)
  {
    var data = "${item[0]},${item[1]}";
    sink.write(data+ '\n');
  }
  
  await sink.flush();
  await sink.close();
}


/// Method to go from pre CSV data to CSV data (before using the data to print a CSV file)
/// Removal of all ["Notes:",] 
/// 
/// 
/// Addition of a ["",""] after a level 2 title
/// Addition of a ["",""] after an existing last item of a level 3 title
/// Addition of a ["",""] after a level 3 title without sub items

/// 
List<dynamic> preCSVToCSVData(List<dynamic> preCSVData)
{
  // List<dynamic> csvData = [];
  print("");
  print("Entering preCSVToCSVData");
  print("preCSVData");
  print(preCSVData);

  // Analyzing the data for checkboxes with nulls and empty notes 
  for (var index = 0 ; index < preCSVData.length; index++)
  {    
    var indexedData = preCSVData[index];  
    var indexData_1AsString = indexedData[1] as String;

    // Removal of all [,null] (unchecked boxes)
    if ( (indexedData[0].contains(checkbox)) && (indexData_1AsString.trim() == "null"))  {preCSVData.removeAt(index);}
    // Every checkbox is followed by a note
    // The same index points now to the notes data
    // Removal of all ["Notes:",]  
    indexedData = preCSVData[index];  
    indexData_1AsString = indexedData[1];
    if (indexedData[0].contains(notes) && (indexData_1AsString.trim() == "")) {preCSVData.removeAt(index); }
  }

  // Getting the indexes for the titles level 3 with children before the next analysis
  Map<String,int> titlesLevel3WithChildrenIndexes = {};
  for (var index = 0 ; index < preCSVData.length; index++)
  {
    var indexedData = preCSVData[index];
    if(indexedData[1].trim() == level3TitleBalanceIssue){titlesLevel3WithChildrenIndexes[level3TitleBalanceIssue] = index;}
    else if (indexedData[1].trim() == level3TitleWorkplaceIssue){titlesLevel3WithChildrenIndexes[level3TitleWorkplaceIssue] = index;}
    else if (indexedData[1].trim() == level3TitleLegacyIssue){titlesLevel3WithChildrenIndexes[level3TitleLegacyIssue] = index;}
  }

  var level3TitleBalanceIssueChildren = [level3TitleBalanceIssueItem1, level3TitleBalanceIssueItem2, level3TitleBalanceIssueItem3, level3TitleBalanceIssueItem4];
  var level3TitleWorkplaceIssueChildren = [level3TitleWorkplaceIssueItem1, level3TitleWorkplaceIssueItem2];
  var level3TitleLegacyIssueChildren = [level3TitleLegacyIssueItem1];  
  // Analyzing the data for checkboxes not null, and adding Xs before another processing to remove the checkboxes lines
  for (var index = 0 ; index < preCSVData.length; index++)
  {  
    var indexedData = preCSVData[index];  
    var indexData_1AsString = indexedData[1] as String;
    if ( (indexedData[0].contains(checkbox)) && (indexData_1AsString.trim() != "null")) 
    {
      // Adding X in front of the question
      // possible with this design of a question preceding a checkbox
      var previousIndexData = preCSVData[index-1];
      previousIndexData[0] = 'X';
      var itemOrTitleLevel3 = previousIndexData[1];
      // if the question was not a title level 3, adding an X to the parent title level 3, if none yet
      if (level3TitleBalanceIssueChildren.contains(itemOrTitleLevel3))
      {
        var parentIndex = titlesLevel3WithChildrenIndexes[level3TitleBalanceIssue];
        var parentData = preCSVData[parentIndex!];
        parentData[0]= 'X';
      }
      else if (level3TitleWorkplaceIssueChildren.contains(itemOrTitleLevel3))
      {
        var parentIndex = titlesLevel3WithChildrenIndexes[level3TitleWorkplaceIssue];
        var parentData = preCSVData[parentIndex!];
        parentData[0]= 'X';
      }
      else if (level3TitleLegacyIssueChildren.contains(itemOrTitleLevel3))
      {
        var parentIndex = titlesLevel3WithChildrenIndexes[level3TitleLegacyIssue];
        var parentData = preCSVData[parentIndex!];
        parentData[0]= 'X';
      }
    }
  } 

  // Analyzing to remove the lines with checkbox
  // These lines are at least 2 indexes apart
  for (var index = 0 ; index < preCSVData.length; index++)
  {  
    var indexedData = preCSVData[index];  
    var indexData_1AsString = indexedData[1] as String;
    if (indexedData[0].contains(checkbox)){preCSVData.removeAt(index);}
  }

  var titlesLevel3 = {level3TitleBalanceIssue, level3TitleWorkplaceIssue, level3TitleLegacyIssue, level3TitleAnotherIssue,
                      level3TitleGroupsProblematics, level3TitleSameProblem, level3TitleHarmonyAtHome, level3TitleAppreciabilityAtWork, 
                      level3TitleIncomeEarningAbility};

      
  
  // TODO: Extra lines to add 


  // Addition of a ["",""] after the level 2 title at index 0
  // preCSVData.insert(1,["",""]);

  print("");
  print("Exiting preCSVToCSVData");
  print("preCSVData");
  print(preCSVData);


  return preCSVData;
}

