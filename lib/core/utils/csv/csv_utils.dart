
import "dart:collection";

import "package:journeyers/core/utils/printing_and_logging/print_utils.dart";
import "package:journeyers/pages/context_analysis/context_analysis_context_form_questions.dart";

// Labels used in the form data
String inputTypeCheckboxWithTextField = "checkbox";
String inputTypeTextField = "textField";
String inputTypeSegmentedButton = "segmentedButton";

// Mapping questions to input widgets to process data according to input widgets
Map<String,String> mappingLabelsToInputItems 
= {
  //*********** Individual perspective ***********/
  // balance issue
  level3TitleBalanceIssueItem1:inputTypeCheckboxWithTextField, level3TitleBalanceIssueItem2:inputTypeCheckboxWithTextField,
  level3TitleBalanceIssueItem3:inputTypeCheckboxWithTextField, level3TitleBalanceIssueItem4:inputTypeCheckboxWithTextField,
  // workplace issue
  level3TitleWorkplaceIssueItem1:inputTypeCheckboxWithTextField, level3TitleWorkplaceIssueItem2:inputTypeCheckboxWithTextField,
  // legacy issue
  level3TitleLegacyIssueItem1:inputTypeCheckboxWithTextField,
  // another type
  level3TitleAnotherIssue:inputTypeTextField,
  //*********** Group/team perspective ***********/
  // group problematics
  level3TitleGroupsProblematics:inputTypeTextField,
  // same problem?
  level3TitleSameProblem:inputTypeSegmentedButton,
  // harmony at home
  level3TitleHarmonyAtHome:inputTypeSegmentedButton,
  // appreciability at work
  level3TitleAppreciabilityAtWork:inputTypeSegmentedButton,
  // earning ability
  level3TitleIncomeEarningAbility:inputTypeSegmentedButton
 };

 // Defining the titles level 2
 var titlesLevel2 = {level2TitleIndividual, level2TitleGroup};

 // Defining the level 3 titles with items 1,2,
 Set<String>  titlesLevel3WithSubItems = {level3TitleBalanceIssue, level3TitleWorkplaceIssue,
                                          level3TitleLegacyIssue};

// pre CSV data  structure (before adding adding extra lines, removing or renaming keywords, ...)
List<dynamic> preCSVData = [];

//***************** Processing data according to input widgets: beginning  ***********************/

// Method to convert information from {checkbox: false/true/null, textfield: "data"/null} to:
// checkbox, false/true
// textfield, "data"/""
List<dynamic> checkBoxWithTextFieldDataToPreCSV(LinkedHashMap<String, dynamic> checkBoxWithTextFieldtextData)
{
  List<dynamic> checkboxPreCSVData = []; 

  var dataCheckbox = checkBoxWithTextFieldtextData["checkbox"] ?? false;
  var data1 = ["checkbox",dataCheckbox];

  var dataTextField = checkBoxWithTextFieldtextData["textfield"] ?? "";
  var data2 = ["textfield",dataTextField];

  checkboxPreCSVData.add(data1);
  checkboxPreCSVData.add(data2);

  // print(checkBoxWithTextFieldtextData);
  // printd(data1);
  // printd(data2);
  // printd(checkboxPreCSVData);

  return checkboxPreCSVData;
}

// Method to convert information from {segmentedButton: Yes/No/I don't know/null , textfield: "data"/null} to:
// segmentedButton,Yes/No/I don't know/""
// textfield, "data"/""
List<dynamic> segmentedButtonWithTextFieldDataToPreCSV(LinkedHashMap<String, dynamic> segmentedButtonWithTextFieldData)
{
  List<dynamic> segmentedButtonPreCSVData = []; 

  var dataSegmentedButton = segmentedButtonWithTextFieldData["segmentedButton"] ?? false;
  var data1 = ["segmentedButton",dataSegmentedButton];

  var dataTextField = segmentedButtonWithTextFieldData["textfield"] ?? "";
  var data2 = ["textfield",dataTextField];

  segmentedButtonPreCSVData.add(data1);
  segmentedButtonPreCSVData.add(data2);

  // print(checkBoxWithTextFieldtextData);
  // printd(data1);
  // printd(data2);
  // printd(checkboxPreCSVData);

  return segmentedButtonPreCSVData;
}

// Method to convert information from {textfield: "data"/null} to:
// textfield, "data"/""
List<dynamic> textFieldDataToPreCSV(LinkedHashMap<String, dynamic> textFieldData)
{
  List<dynamic> textFieldPreCSVData = []; 

  var dataTextField = textFieldData["textfield"] ?? "";
  var data = ["textfield",dataTextField];

  textFieldPreCSVData.add(data);

  return textFieldPreCSVData;
}

//***************** Processing data according to input widgets: beginning  ***********************/


// The data should be either the individual perspective data, or the group perspective data
List<dynamic> dataToPreCSV(LinkedHashMap<String,dynamic> enteredData)
{
  treatmentAccordingToInputType(List<dynamic> preCSVData, String itemOrTitleLable, LinkedHashMap<String,dynamic> level2Or3DataAsLinkedHashMap)
  {
    if (mappingLabelsToInputItems[itemOrTitleLable] == inputTypeCheckboxWithTextField)
        {
          var checkboxPreCSVData = checkBoxWithTextFieldDataToPreCSV(level2Or3DataAsLinkedHashMap[itemOrTitleLable]);
          preCSVData.add(checkboxPreCSVData[0]);
          preCSVData.add(checkboxPreCSVData[1]);
        }
        else if (mappingLabelsToInputItems[itemOrTitleLable] == inputTypeSegmentedButton)
        {
          var segmentedButtonPreCSVData = segmentedButtonWithTextFieldDataToPreCSV(level2Or3DataAsLinkedHashMap[itemOrTitleLable]);
          preCSVData.add(segmentedButtonPreCSVData[0]);
          preCSVData.add(segmentedButtonPreCSVData[1]);
        }
        else if (mappingLabelsToInputItems[itemOrTitleLable] == inputTypeTextField)
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
    print("${item[0]},${item[1]}");
  }
}

