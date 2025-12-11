
import "dart:collection";
import "dart:io";

import "package:journeyers/core/utils/form/form_utils.dart";
import "package:journeyers/core/utils/printing_and_logging/print_utils.dart";
import "package:journeyers/pages/context_analysis/context_analysis_context_form_questions.dart";

// Label used in the pre-CSV data
String notes = "Notes:";


//************** Mapping questions to input widgets to process data according to input widgets *************//
Map<String,String> mappingLabelsToInputItems 
= {
  //** Individual perspective **/
  // balance issue
  level3TitleBalanceIssueItem1:checkbox, level3TitleBalanceIssueItem2:checkbox,
  level3TitleBalanceIssueItem3:checkbox, level3TitleBalanceIssueItem4:checkbox,
  // workplace issue
  level3TitleWorkplaceIssueItem1:checkbox, level3TitleWorkplaceIssueItem2:checkbox,
  // legacy issue
  level3TitleLegacyIssueItem1:checkbox,
  // another type
  level3TitleAnotherIssue:textField,

  //** Group/team perspective **/
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


//************** Sets of the level 2, level 3 titles, and related sets *************//
// Set of the existing titles level 2
var titlesLevel2 = {level2TitleIndividual, level2TitleGroup};

// Set of the existing titles level 3 with sub items
Set<String>  titlesLevel3WithSubItems = {level3TitleBalanceIssue, level3TitleWorkplaceIssue,
                                          level3TitleLegacyIssue};

// Sets of the children of the existing titles level 3 with sub items
Set<String> titleLevel3BalanceIssueChildren = {level3TitleBalanceIssueItem1, level3TitleBalanceIssueItem2, level3TitleBalanceIssueItem3, level3TitleBalanceIssueItem4};
Set<String> titleLevelWorkplaceIssueChildren = {level3TitleWorkplaceIssueItem1, level3TitleWorkplaceIssueItem2};
Set<String> titleLevelLegacyIssueChildren = {level3TitleLegacyIssueItem1};  

// Set of the existing titles level 3
Set<String> titlesLevel3ForTheIndividualPerspective = {level3TitleBalanceIssue, level3TitleWorkplaceIssue, level3TitleLegacyIssue, level3TitleAnotherIssue};
Set<String> titlesLevel3ForTheTeamPerspective = {level3TitleGroupsProblematics, level3TitleSameProblem, level3TitleHarmonyAtHome, level3TitleAppreciabilityAtWork, 
                                                  level3TitleIncomeEarningAbility};

//************** The data structure to return *************//
// pre CSV data structure (before adding adding extra lines, removing or renaming keywords, ...)
List<dynamic> preCSVData = [];


//***************** Methods processing data according to input widgets: beginning  ***********************//

/// Method used to remove the line returns from text field data
String lineReturnsRemoval(String textFieldData)
{
  String dataToReturn = "";
  dataToReturn = textFieldData.replaceAll('\r', '');
  dataToReturn = dataToReturn.replaceAll('\n', '');
  return dataToReturn;
}


/// Method to convert information from {checkbox: false/true/null, textField: "data"/null} to:
/// checkbox, false/true
/// textField, "data"/""
List<dynamic> checkBoxWithTextFieldDataToPreCSV(LinkedHashMap<String, dynamic> checkBoxWithTextFieldtextData)
{
  List<dynamic> checkboxPreCSVData = []; 

  // checkbox data converted from bool to String: values can be "null", "true" or "false"
  var dataCheckbox = "${checkBoxWithTextFieldtextData[checkbox]}";
  var data1 = [checkbox,dataCheckbox]; // label in front of the checkbox data in the pre CSV, to help with the processing toward the final CSV

  var dataTextField = checkBoxWithTextFieldtextData[textField] ?? "";
  var data2 = [notes,lineReturnsRemoval(dataTextField)]; // "Notes:" in front of the text field data in the pre CSV

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

  var dataSegmentedButton = segmentedButtonWithTextFieldData[segmentedButton] ?? "";
  var data1 = ["",dataSegmentedButton]; // No label in front of the checkbox data in the pre CSV

  var dataTextField = segmentedButtonWithTextFieldData[textField] ?? "";
  var data2 = [notes,lineReturnsRemoval(dataTextField)]; // "Notes:" in front of the text field data in the pre CSV

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
  var data = [notes,lineReturnsRemoval(dataTextField)]; // "Notes:" in front of the text field data in the pre CSV

  textFieldPreCSVData.add(data);

  return textFieldPreCSVData;
}

//***************** Methods processing data according to input widgets: end  ***********************//



//***************** Method building a list of pair of data for the later CSV printing ***********************//


/// Method processing the form data, and returning a list of pair of data, for the CSV printing.
/// The data should be either the individual perspective data, or the group perspective data.
/// The individual perspective data and the group perspective data are planned to be printed side by side.
List<dynamic> dataToPreCSV(LinkedHashMap<String,dynamic> enteredData)
{
  List<dynamic> preCSVData = [];

  // Method adding to the 
  treatmentAccordingToInputType(List<dynamic> preCSVData, String itemOrTitleLabel, LinkedHashMap<String,dynamic> titleLevel2Or3DataAsLinkedHashMap)
  {
    if (mappingLabelsToInputItems[itemOrTitleLabel] == checkbox)
        {
          // checkBoxWithTextFieldDataToPreCSV returns a data similar to [[checkbox, true], [Notes:, a_note]]
          var checkboxPreCSVData = checkBoxWithTextFieldDataToPreCSV(titleLevel2Or3DataAsLinkedHashMap[itemOrTitleLabel]);
          preCSVData.add(checkboxPreCSVData[0]);
          preCSVData.add(checkboxPreCSVData[1]);
        }
        // segmentedButtonWithTextFieldDataToPreCSV returns a data similar to [[, Yes], [Notes:, a_note]]
        else if (mappingLabelsToInputItems[itemOrTitleLabel] == segmentedButton)
        {
          var segmentedButtonPreCSVData = segmentedButtonWithTextFieldDataToPreCSV(titleLevel2Or3DataAsLinkedHashMap[itemOrTitleLabel]);
          preCSVData.add(segmentedButtonPreCSVData[0]);
          preCSVData.add(segmentedButtonPreCSVData[1]);
        }
        // textFieldDataToPreCSV returns a data similar to [[Notes:, a_note]]
        else if (mappingLabelsToInputItems[itemOrTitleLabel] == textField)
        {
          var textFieldpreCSVData = textFieldDataToPreCSV(titleLevel2Or3DataAsLinkedHashMap[itemOrTitleLabel]);          
          preCSVData.add(textFieldpreCSVData[0]);
        }
        else
        {
          printd("");
          printd("Error: treatmentAccordingToInputType: no mapping found");
          printd("Error: level3Title: $itemOrTitleLabel");
          printd("Error: mappingLabelsToInputItems[level3Title]: ${mappingLabelsToInputItems[itemOrTitleLabel]}");
          printd("");
        }
  }

  // There is only one key in the entered data, one of the two level 2 titles
  var level2PreCSVData = ["",enteredData.keys.first];
  // Adding the level 2 title
  preCSVData.add(level2PreCSVData);

  // There is only one value for the title level 2 key
  var level2TitleData = enteredData.values.first;
  var level2DataAsLinkedHashMap = level2TitleData as LinkedHashMap<String,dynamic>;
  
  // level 3 titles as keys of the level 2 data
  for (var level3Title in level2DataAsLinkedHashMap.keys)
  {      
    var level3TitlePreCSVData = ["", level3Title];
    // Adding the level 3 title
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

  printd("");
  printd("preCSVData");
  printd(preCSVData);
  // printPreCSVDataToConsole(preCSVData);
  return preCSVData;
}

/// Method to have a vertical view of the list data
void printPreCSVDataToConsole(List<dynamic> data) 
{
  for (var item in data)
  {
    var data = "${item[0]},${item[1]}";
    printd(data);
  }
}

/// Method to test the printing of the individual perspective data, or the group perspective data, to CSV 
void testPrintToCSV(String fileName, List<dynamic> data) async
{
  File file = File("txt.csv");
  var sink = file.openWrite(mode: FileMode.write); 

  for (var item in data)
  {
    var data = "${item[0]},${item[1]}";
    sink.write("$data\n");
  }
  
  await sink.flush();
  await sink.close();
}


/// Method to go from pre-CSV data to CSV-friendly data (before using the data to print a CSV file)
/// Eventual removal of all unchecked checkboxes, after processing of related data
/// Removal of all ["Notes:",] 
///
/// 
/// Addition of a ["",""] before all level 3 title
/// 
/// Addition of a ["",""] after a level 2 title
/// Addition of a ["",""] after an existing last item of a level 3 title
/// Addition of a ["",""] after a level 3 title without sub items

List<dynamic> preCSVToCSVData(List<dynamic> preCSVData)
{

  //*************** Analyzing the data for checkboxes with nulls, and text fields with empty notes ****************//
  for (var index = 0 ; index < preCSVData.length; index++)
  {    
    var indexedData = preCSVData[index];  
    printd("");
    printd("indexedData");
    printd(indexedData);
    printd("");
    var indexData_1AsString = indexedData[1] as String;
    

    // Removal of all [checkbox,"null"] and [checkbox, "false"] (unchecked boxes)
    if 
    ( 
      (indexedData[0].contains(checkbox)) && 
      ( (indexData_1AsString.trim() == "null") || (indexData_1AsString.trim() == "false") )
    )  
    {preCSVData.removeAt(index);}

    // Every checkbox is followed by a note
    // The same index points now to the notes data
    // Removal of all ["Notes:",]  
    indexedData = preCSVData[index];  
    indexData_1AsString = indexedData[1];
    if (indexedData[0].contains(notes) && (indexData_1AsString.trim() == "")) {preCSVData.removeAt(index); }
  }

  //*************** Analyzing the data to add 'X's where checkboxes have been checked, 
  //                and in front of the parent title level 3 if existant                ****************//

  // Getting the indexes for the titles level 3 with children, before starting the analysis
  Map<String,int> indexesOfTitlesLevel3WithChildren = {};
  for (var index = 0 ; index < preCSVData.length; index++)
  {
    var indexedData = preCSVData[index];
    if(indexedData[1].trim() == level3TitleBalanceIssue){indexesOfTitlesLevel3WithChildren[level3TitleBalanceIssue] = index;}
    else if (indexedData[1].trim() == level3TitleWorkplaceIssue){indexesOfTitlesLevel3WithChildren[level3TitleWorkplaceIssue] = index;}
    else if (indexedData[1].trim() == level3TitleLegacyIssue){indexesOfTitlesLevel3WithChildren[level3TitleLegacyIssue] = index;}
  }

  // Analyzing the data for checkboxes not null, and adding Xs before another processing to remove the checkboxes lines
  for (var index = 0 ; index < preCSVData.length; index++)
  {  
    var indexedData = preCSVData[index];  
    var indexData_1AsString = indexedData[1] as String;
    if ( (indexedData[0].contains(checkbox)) && (indexData_1AsString.trim() != "null")) 
    {
      // Adding X in front of the question
      // With the design of a question preceding a checkbox, (index -1) is the index of the question
      var previousIndexData = preCSVData[index-1];
      previousIndexData[0] = 'X';
      
      // If the question was not a title level 3, adding an X to the parent title level 3
      var itemOrTitleLevel3 = previousIndexData[1];
      if (titleLevel3BalanceIssueChildren.contains(itemOrTitleLevel3))
      {
        var parentIndex = indexesOfTitlesLevel3WithChildren[level3TitleBalanceIssue];
        var parentData = preCSVData[parentIndex!];
        parentData[0]= 'X';
      }
      else if (titleLevelWorkplaceIssueChildren.contains(itemOrTitleLevel3))
      {
        var parentIndex = indexesOfTitlesLevel3WithChildren[level3TitleWorkplaceIssue];
        var parentData = preCSVData[parentIndex!];
        parentData[0]= 'X';
      }
      else if (titleLevelLegacyIssueChildren.contains(itemOrTitleLevel3))
      {
        var parentIndex = indexesOfTitlesLevel3WithChildren[level3TitleLegacyIssue];
        var parentData = preCSVData[parentIndex!];
        parentData[0]= 'X';
      }
    }
  } 

  // Analyzing to remove the lines with checkboxes
  // These lines are at least 2 indexes apart. All the analysis is feasible in one loop, in spite of the removal effect on the indexes
  for (var index = 0 ; index < preCSVData.length; index++)
  {  
    var indexedData = preCSVData[index];  
    if (indexedData[0].contains(checkbox)){preCSVData.removeAt(index);}
  }
     
  
  // Getting the indexes for the titles level 3 before the next analysis
  Map<String,int> indexesForTitlesLevel3ForTheIndividualPerspective = {};
  Map<String,int> indexesForTitlesLevel3ForTheGroupPerspective = {};

  List<String> level2TitleData = preCSVData[0];
  String level2Title = level2TitleData[1].trim();

  for (var index = 0 ; index < preCSVData.length; index++)
  {
    var indexedData = preCSVData[index];
    if(level2Title == level2TitleIndividual)
    {
      if(indexedData[1].trim() == level3TitleBalanceIssue){indexesForTitlesLevel3ForTheIndividualPerspective[level3TitleBalanceIssue] = index;}
      else if (indexedData[1].trim() == level3TitleWorkplaceIssue){indexesForTitlesLevel3ForTheIndividualPerspective[level3TitleWorkplaceIssue] = index;}
      else if (indexedData[1].trim() == level3TitleLegacyIssue){indexesForTitlesLevel3ForTheIndividualPerspective[level3TitleLegacyIssue] = index;}
      else if (indexedData[1].trim() == level3TitleAnotherIssue){indexesForTitlesLevel3ForTheIndividualPerspective[level3TitleAnotherIssue] = index;}
    }
    else if(level2Title == level2TitleGroup)
    {
      if (indexedData[1].trim() == level3TitleGroupsProblematics){indexesForTitlesLevel3ForTheGroupPerspective[level3TitleGroupsProblematics] = index;}
      else if (indexedData[1].trim() == level3TitleSameProblem){indexesForTitlesLevel3ForTheGroupPerspective[level3TitleSameProblem] = index;}
      else if (indexedData[1].trim() == level3TitleHarmonyAtHome){indexesForTitlesLevel3ForTheGroupPerspective[level3TitleHarmonyAtHome] = index;}
      else if (indexedData[1].trim() == level3TitleAppreciabilityAtWork){indexesForTitlesLevel3ForTheGroupPerspective[level3TitleAppreciabilityAtWork] = index;}
      else if (indexedData[1].trim() == level3TitleIncomeEarningAbility){indexesForTitlesLevel3ForTheGroupPerspective[level3TitleIncomeEarningAbility] = index;}
    }
    
  }


  // Using a copy of the structure to add the extra lines (still a work in progress)
  var preCSVDataCopy = [...preCSVData];
  // Doing one level at a time to avoid index issues
  
  // for (var titleLevel3 in titlesLevel3)
  // {
  //   for (var index = titlesLevel3Indexes[titleLevel3]!; index < preCSVData.length; index++)
  //   { 
  //     // print("preCSVData.length: ${preCSVData.length}");
  //     // print("index: $index");
  //     var indexedData = preCSVData[index];  
  //     var indexData_1AsString = indexedData[1] as String;
  //     // Searching for the level 3 title
  //     if (titlesLevel3.contains(indexData_1AsString.trim()))
  //     { 
  //       preCSVDataCopy.insert(index, ["",""]);
  //       // print(" \n ***********insert********* \n");
  //       // Adding 1 to the other level 3 titles indexes
  //       for (var titleLevel3 in titlesLevel3Indexes.keys)
  //       {
  //         var titleLevel3Index = titlesLevel3Indexes[titleLevel3];
  //         titleLevel3Index = titleLevel3Index! + 1;
  //       }
  //       // Stopping the search to avoid indexes issues
  //       break;
  //     }
  //     else{
  //       // print("\n${indexData_1AsString.trim()} not in: $titlesLevel3\n");
  //     }
  //   }
  // }

  // Addition of a ["",""] after the level 2 title at index 0
  // preCSVData.insert(1,["",""]);

  // print("");
  // print("Exiting preCSVToCSVData");
  // print("preCSVData");
  // print(preCSVData);

  // print("");
  // print("preCSVDataCopy");
  // print(preCSVDataCopy);


  // preCSVData = preCSVDataCopy;

  return preCSVData;
}

