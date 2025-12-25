
import "dart:collection";
import "dart:convert";
import "dart:typed_data";

import "package:file_picker/file_picker.dart";
import "package:journeyers/core/utils/form/form_utils.dart";
import "package:journeyers/core/utils/printing_and_logging/print_utils.dart";
import "package:journeyers/pages/context_analysis/context_analysis_context_form_questions.dart";

/// {@category Utils}
/// A utility class related to CSV.
class CSVUtils
{
  // Used in the pre-CSV data
  /// A label used in front of the content of answered questions.
  String notes = "Notes:";
  /// Straight double quotes used to encapsulate the content of answered questions.
  String quotesForCSV = '"';

  // Utility classes
  FormUtils fu = FormUtils();
  PrintUtils pu = PrintUtils();

  //************** Mapping questions to input widgets to process data according to input widgets *************//
  /// A mapping of question labels with the type of input items (text field, checkbox with text field, segmented button with text field) used to answer.
  Map<String,String> mappingLabelsToInputItems 
  = {
    //** Individual perspective **/
    // balance issue
    level3TitleBalanceIssueItem1:FormUtils.checkbox, level3TitleBalanceIssueItem2:FormUtils.checkbox,
    level3TitleBalanceIssueItem3:FormUtils.checkbox, level3TitleBalanceIssueItem4:FormUtils.checkbox,
    // workplace issue
    level3TitleWorkplaceIssueItem1:FormUtils.checkbox, level3TitleWorkplaceIssueItem2:FormUtils.checkbox,
    // legacy issue
    level3TitleLegacyIssueItem1:FormUtils.checkbox,
    // another type
    level3TitleAnotherIssue:FormUtils.textField,

    //** Group/team perspective **/
    // group problematics
    level3TitleGroupsProblematics:FormUtils.textField,
    // same problem?
    level3TitleSameProblem:FormUtils.segmentedButton,
    // harmony at home
    level3TitleHarmonyAtHome:FormUtils.segmentedButton,
    // appreciability at work
    level3TitleAppreciabilityAtWork:FormUtils.segmentedButton,
    // earning ability
    level3TitleIncomeEarningAbility:FormUtils.segmentedButton
  };

  //************** Sets of the level 2, level 3 titles, and related sets *************//
  /// A set of the existing titles level 2.
  var titlesLevel2 = {level2TitleIndividual, level2TitleGroup};

  // Sets of the existing titles level 3.
  /// A set of the titles level 3 related to an individual perspective.
  Set<String> titlesLevel3ForTheIndividualPerspective = {level3TitleBalanceIssue, level3TitleWorkplaceIssue, level3TitleLegacyIssue, level3TitleAnotherIssue};
  /// A set of the titles level 3 related to a team perspective.
  Set<String> titlesLevel3ForTheTeamPerspective = {level3TitleGroupsProblematics, level3TitleSameProblem, level3TitleHarmonyAtHome, level3TitleAppreciabilityAtWork, 
                                                    level3TitleIncomeEarningAbility};

  /// A set of the existing titles level 3 with sub items.
  Set<String>  titlesLevel3WithSubItems = {level3TitleBalanceIssue, level3TitleWorkplaceIssue,
                                            level3TitleLegacyIssue};

  // Sets of the children of the existing titles level 3 with sub items
  /// A set of the children of the title level 3 related to balance issues.
  Set<String> titleLevel3BalanceIssueChildren = {level3TitleBalanceIssueItem1, level3TitleBalanceIssueItem2, level3TitleBalanceIssueItem3, level3TitleBalanceIssueItem4};
  /// A set of the children of the title level 3 related to workplace issues.
  Set<String> titleLevel3WorkplaceIssueChildren = {level3TitleWorkplaceIssueItem1, level3TitleWorkplaceIssueItem2};
  /// A set of the children of the title level 3 related to a legacy issue.
  Set<String> titleLevel3LegacyIssueChildren = {level3TitleLegacyIssueItem1};  

  // A set of the text fields only items
  Set<String> textFieldOnlyItems = {level3TitleAnotherIssue, level3TitleGroupsProblematics};


  //************** The data structure to return *************//
  /// The pre-CSV data structure (before adding extra lines, removing or renaming keywords, ...)
  List<dynamic> preCSVData = [];


  //***************** Methods processing data according to input widgets: beginning  ***********************//

  /// Method extracting information from {checkbox: false/true, textField: "data"/null}
  /// and returning \[\[checkbox,"false"/"true"\],\[Notes:,"data"/""\]\].
  /// Straight double quotes are refused during text field input and removed.
  List<dynamic> checkBoxWithTextFieldDataToPreCSV(LinkedHashMap<String, dynamic> checkBoxWithTextFieldtextData)
  {

    List<dynamic> checkboxPreCSVData = []; 

    // checkbox data converted from bool to String: values can be "true" or "false"
    var dataCheckbox = "${checkBoxWithTextFieldtextData[FormUtils.checkbox]}";
    var data1 = [FormUtils.checkbox,dataCheckbox]; // label in front of the checkbox data in the pre CSV, to help with the processing toward the final CSV

    var dataTextField = checkBoxWithTextFieldtextData[FormUtils.textField] ?? "";
    var data2 = [notes,quotesForCSV+dataTextField+quotesForCSV]; // label in front of the text field data

    checkboxPreCSVData.add(data1);
    checkboxPreCSVData.add(data2);

    return checkboxPreCSVData;
  }

  /// Method extracting information from {segmentedButton: "Yes"/"No"/"I don't know"/null , textField: "data"/null}
  /// and returning \[\[segmentedButton,"Yes"/"No"/"I don't know"/""\],\[Notes:,"data"/""\]\].
  /// Straight double quotes are refused during text field input and removed.
  List<dynamic> segmentedButtonWithTextFieldDataToPreCSV(LinkedHashMap<String, dynamic> segmentedButtonWithTextFieldData)
  {
    List<dynamic> segmentedButtonPreCSVData = []; 

    var dataSegmentedButton = segmentedButtonWithTextFieldData[FormUtils.segmentedButton] ?? "";
    var data1 = [FormUtils.segmentedButton,dataSegmentedButton]; 

    var dataTextField = segmentedButtonWithTextFieldData[FormUtils.textField] ?? "";
    var data2 = [notes,quotesForCSV+dataTextField+quotesForCSV]; 

    segmentedButtonPreCSVData.add(data1);
    segmentedButtonPreCSVData.add(data2);

    return segmentedButtonPreCSVData;
  }

  /// Method extracting information from {textField: "data"/null}
  /// and returning \[\[Notes:,"data"/""\]\].
  /// Straight double quotes are refused during text field input and removed.
  List<dynamic> textFieldDataToPreCSV(LinkedHashMap<String, dynamic> textFieldData)
  {
    List<dynamic> textFieldPreCSVData = []; 

    var dataTextField = textFieldData[FormUtils.textField] ?? "";
    var data = [notes,quotesForCSV+dataTextField+quotesForCSV]; 

    textFieldPreCSVData.add(data);

    return textFieldPreCSVData;
  }

  //***************** Methods processing data according to input widgets: end  ***********************//



  //***************** Method building a list of pair of data for the later saving to CSV ***********************//


  /// Method processing the form data, and returning a list of pair of data, for the saving to CSV.
  /// The data should be either the individual perspective data, or the team perspective data.
  /// The individual perspective data and the team perspective data are planned to be written side by side in the CSV file.
  List<dynamic> dataToPreCSV(LinkedHashMap<String,dynamic> perspectiveData)
  {
    List<dynamic> preCSVData = [];

    /// Method adding to the pre-CSV data according to input type.
    treatmentAccordingToInputType(List<dynamic> preCSVData, String itemOrTitleLabel, LinkedHashMap<String,dynamic> titleLevel2Or3DataAsLinkedHashMap)
    {
      if (mappingLabelsToInputItems[itemOrTitleLabel] == FormUtils.checkbox)
          {
            // checkBoxWithTextFieldDataToPreCSV returns a data similar to [[checkbox, true], [Notes:, a_note]]
            var checkboxPreCSVData = checkBoxWithTextFieldDataToPreCSV(titleLevel2Or3DataAsLinkedHashMap[itemOrTitleLabel]);
            preCSVData.add(checkboxPreCSVData[0]);
            preCSVData.add(checkboxPreCSVData[1]);
          }
          // segmentedButtonWithTextFieldDataToPreCSV returns a data similar to [[segmentedButton, Yes], [Notes:, a_note]]
          else if (mappingLabelsToInputItems[itemOrTitleLabel] == FormUtils.segmentedButton)
          {
            var segmentedButtonPreCSVData = segmentedButtonWithTextFieldDataToPreCSV(titleLevel2Or3DataAsLinkedHashMap[itemOrTitleLabel]);
            preCSVData.add(segmentedButtonPreCSVData[0]);
            preCSVData.add(segmentedButtonPreCSVData[1]);
          }
          // textFieldDataToPreCSV returns a data similar to [[Notes:, a_note]]
          else if (mappingLabelsToInputItems[itemOrTitleLabel] == FormUtils.textField)
          {
            var textFieldpreCSVData = textFieldDataToPreCSV(titleLevel2Or3DataAsLinkedHashMap[itemOrTitleLabel]);          
            preCSVData.add(textFieldpreCSVData[0]);
          }
          else
          {
            pu.printd("");
            pu.printd("Error: treatmentAccordingToInputType: no mapping found");
            pu.printd("Error: level3Title: $itemOrTitleLabel");
            pu.printd("Error: mappingLabelsToInputItems[level3Title]: ${mappingLabelsToInputItems[itemOrTitleLabel]}");
            pu.printd("");
          }
    }

    // There is only one key in the perspective data, one of the two level 2 titles
    var level2TitlePreCSVData = ["",perspectiveData.keys.first];
    // Adding the level 2 title
    preCSVData.add(level2TitlePreCSVData);

    // There is only one value for the title level 2 key, a LinkedHashMap with the form data
    var level2TitleDataValue = perspectiveData.values.first;
    var perspectiveDataAsLinkedHashMap = level2TitleDataValue as LinkedHashMap<String,dynamic>;
    
    // level 3 titles as keys
    for (var level3Title in perspectiveDataAsLinkedHashMap.keys)
    {      
      var level3TitlePreCSVData = ["", level3Title];
      // Adding the level 3 title
      preCSVData.add(level3TitlePreCSVData);

      // 1. Checking if sub-items exist before starting the processing of the level 3 title data
      if(titlesLevel3WithSubItems.contains(level3Title))
      {
        // Going through the sub items
        var level3TitleItemsData  = perspectiveDataAsLinkedHashMap[level3Title];
        // A LinkedHashMap as value
        var level3TitleItemsDataAsLinkedHashMap = level3TitleItemsData as LinkedHashMap<String, dynamic>;
        for (var itemLabel in level3TitleItemsDataAsLinkedHashMap.keys)
        {
            // Adding the item label  
          preCSVData.add(["", itemLabel]);
          // Adding input data
          treatmentAccordingToInputType(preCSVData, itemLabel, level3TitleItemsDataAsLinkedHashMap);
        }

      }
      // 2. No sub items for this level 3 title
      // Checking the type of input item that the level 3 title refers to
      else 
      {
        // Adding input data
        treatmentAccordingToInputType(preCSVData, level3Title, perspectiveDataAsLinkedHashMap);
      }
    }
    return preCSVData;
  }

  /// Method to go from pre-CSV data to CSV-friendly data (before saving the data in a CSV file).
  /// 
  /// Xs in front of the questions with a checked checkbox, 
  /// and for their title level 3 parent if existant.
  /// 
  /// Eventual removal of all checkboxes lines.
  /// Eventual removal of all unanswered segmented buttons.
  /// Eventual removal of all empty notes if not related to a checked checkbox, or an answered segmented button.
  /// 
  /// Removal of "segmentedButton" from the data written.
  /// "textField was replaced with "Notes" during the pre-CSV processing.
  /// 
  /// Addition of a ["",""] before all level 3 titles.
  List<dynamic> preCSVToCSVData(List<dynamic> preCSVData)
  {

    //*************** Analyzing the data for checkboxes with "false", and text fields with empty notes ****************//
    for (var index = 0 ; index < preCSVData.length; index++)
    {    
      var indexedData = preCSVData[index];  
      var indexData_1AsString = indexedData[1] as String;    

      // Removal of all [checkbox, "false"] (unchecked boxes)
      // Removal of all ["Notes:",]  if related to an unchecked checkbox
      if 
      ( 
        (indexedData[0].contains(FormUtils.checkbox)) && 
        (indexData_1AsString.trim() == "false") 
      )  
      {
        preCSVData.removeAt(index);
        // The index now points to the following note
        preCSVData.removeAt(index);
      }

    }

    //*************** Analyzing the data to replace "checkbox"s with 'X's where questions with checkboxes have been checked, 
    //                and in front of the parent title level 3 if existant                               ****************//

    // Getting the indexes for the titles level 3 with children, before starting the analysis
    Map<String,int> indexesOfTitlesLevel3WithChildren = {};
    for (var index = 0 ; index < preCSVData.length; index++)
    {
      var indexedData = preCSVData[index];
      if(indexedData[1].trim() == level3TitleBalanceIssue){indexesOfTitlesLevel3WithChildren[level3TitleBalanceIssue] = index;}
      else if (indexedData[1].trim() == level3TitleWorkplaceIssue){indexesOfTitlesLevel3WithChildren[level3TitleWorkplaceIssue] = index;}
      else if (indexedData[1].trim() == level3TitleLegacyIssue){indexesOfTitlesLevel3WithChildren[level3TitleLegacyIssue] = index;}
    }

    // Analyzing the data for checkboxes with "true" as value,
    // and adding Xs before another processing to remove the checkboxes lines
    for (var index = 0 ; index < preCSVData.length; index++)
    {  
      var indexedData = preCSVData[index];  
      var indexData_1AsString = indexedData[1] as String;
      if ( (indexedData[0].contains(FormUtils.checkbox)) && (indexData_1AsString.trim() == "true")) 
      {
        // Adding X in front of the question
        // With the widget design of a question preceding a checkbox, (index -1) is the index of the question
        var previousIndexData = preCSVData[index-1];
        previousIndexData[0] = 'X';
        
        // Adding an X to the parent title level 3
        var previousIndexData_1AsString = previousIndexData[1];
        if (titleLevel3BalanceIssueChildren.contains(previousIndexData_1AsString))
        {
          var parentIndex = indexesOfTitlesLevel3WithChildren[level3TitleBalanceIssue];
          var parentData = preCSVData[parentIndex!];
          parentData[0]= 'X';
        }
        else if (titleLevel3WorkplaceIssueChildren.contains(previousIndexData_1AsString))
        {
          var parentIndex = indexesOfTitlesLevel3WithChildren[level3TitleWorkplaceIssue];
          var parentData = preCSVData[parentIndex!];
          parentData[0]= 'X';
        }
        else if (titleLevel3LegacyIssueChildren.contains(previousIndexData_1AsString))
        {
          var parentIndex = indexesOfTitlesLevel3WithChildren[level3TitleLegacyIssue];
          var parentData = preCSVData[parentIndex!];
          parentData[0]= 'X';
        }
      }
    } 

    // Analyzing to remove the lines with checkboxes
    // These lines are at least 2 indexes apart. 
    // All the analysis is feasible in one loop, in spite of the removal effect on the indexes
    for (var index = 0 ; index < preCSVData.length; index++)
    {  
      var indexedData = preCSVData[index];  
      if (indexedData[0].contains(FormUtils.checkbox)){preCSVData.removeAt(index);}
    }


    //*************** Analyzing the data to add 'X's in front of the questions where segmented buttons have been answered  
    //                and in front of the parent title level 3 if existant                                                  ****************//

    // Analyzing the data for segmented buttons not null, and adding Xs in front of the question
    for (var index = 0 ; index < preCSVData.length; index++)
    {  
      var indexedData = preCSVData[index]; 
      var indexData_1AsString = indexedData[1] as String;

      if ( indexedData[0].contains(FormUtils.segmentedButton) ) 
      {      
        if (indexData_1AsString.trim() != "")
        {
          // Removing segmentedButton from the data written
          indexedData[0] = "";
          // Adding X in front of the question
          // With the widget design of a question preceding a segmented button, (index -1) is the index of the question
          var previousIndexData = preCSVData[index-1];
          previousIndexData[0] = 'X';
        }
        
        // If the question was not a title level 3, should add an X to the parent title level 3
        // Not for the current interface
        
      }
    } 

    // Removal of all non answered segmented buttons, with their notes.
    for (var index = 0 ; index < preCSVData.length; index++)
    {  
      var indexedData = preCSVData[index];  
      // segmentedButton has already been removed from the answered segmented buttons
      // and replaced with ""
      // Removing all remaining preCSVData lines with segmentedButton
      if (indexedData[0].contains(FormUtils.segmentedButton))
      {
        preCSVData.removeAt(index);
        // The index now points to the following note
        preCSVData.removeAt(index);
      }
    }


    //*************** Analyzing the data to add 'X's where text field widgets (with no checkbox or segmented buttons) have been answered  
    //                and to remove the unanswered ones                                                                                   ****************//
    for (var index = 0 ; index < preCSVData.length; index++)
    {  
      var indexedData = preCSVData[index];  
      var indexData_1AsString = indexedData[1] as String;

      // Getting the labels that are text field only from textFieldOnlyItems
      for (String textFieldOnlyItem in textFieldOnlyItems)
      {
        if (indexData_1AsString.trim() == textFieldOnlyItem)
        {
          // Checking if the note at the next index has content
          int noteIndex = index + 1;
          // Adding the X in front of the question if the note has content
          List<String> noteData = preCSVData[noteIndex];
          if (noteData[1].trim() != '""')
          {
            var questionData = preCSVData[index];
            questionData[0] = 'X';
          }
          else // removing the note
          {
            preCSVData.removeAt(noteIndex);
          }
        }
      }
    }


    //*************** Adding lines before every title level 3 ***************//
    Set<String> titlesLevel3Processed = {};
    for (var index = 0 ; index < preCSVData.length; index++)
    {  
      var indexedData = preCSVData[index];  
      var indexData_1AsString = indexedData[1] as String;
      String indexData_1AsStringTrimmed = indexData_1AsString.trim();

      if 
      (
        // Found titles level 3 
        (titlesLevel3ForTheIndividualPerspective.contains(indexData_1AsStringTrimmed) ||
        titlesLevel3ForTheTeamPerspective.contains(indexData_1AsStringTrimmed))
        &&
        // and not yet processed 
        !(titlesLevel3Processed.contains(indexData_1AsStringTrimmed))
      )
      {
        preCSVData.insert(index, ["",""]);
        titlesLevel3Processed.add(indexData_1AsStringTrimmed);
      }

    }
    return preCSVData;
  }

  //*************** Printing methods ***************//

  /// Method used to print the individual perspective CSV data, or the team perspective CSV data, to a file.
  /// Returns the file name.
  Future<String?> printToCSV(List<dynamic> csvDataIndividualPerspective, List<dynamic> csvDataTeamPerspective) async
  {
    // Complementing the shortest list to have the same length for both lists
    // before printing side to side
    if (csvDataIndividualPerspective.length < csvDataTeamPerspective.length)
    {
      for (var index = csvDataIndividualPerspective.length; index <= csvDataTeamPerspective.length -1; index++)
      {
        // Adding empty lines
        csvDataIndividualPerspective.add(["",""]);
      }
    }
    else if (csvDataIndividualPerspective.length > csvDataTeamPerspective.length)
    {
      for (var index = csvDataTeamPerspective.length; index <= csvDataIndividualPerspective.length -1; index++)
      {
        // Adding empty lines
        csvDataTeamPerspective.add(["",""]);
      }
    }

    String content = "";
    // Building the content line by line (both lists have the same amount of lines)
    for (var index = 0; index < csvDataIndividualPerspective.length; index ++)
    {
      dynamic csvDataIndividualPerspectiveData = csvDataIndividualPerspective[index];
      dynamic csvDataTeamPerspectiveData = csvDataTeamPerspective[index];

      String line = "${csvDataIndividualPerspectiveData[0]},${csvDataIndividualPerspectiveData[1]},,${csvDataTeamPerspectiveData[0]}, ${csvDataTeamPerspectiveData[1]}\n";
      content += line ;  
    }

    pu.printd("");
    pu.printd("csvDataIndividualPerspective:$csvDataIndividualPerspective");
    pu.printd("");  
    pu.printd("csvDataTeamPerspectiveData:$csvDataTeamPerspective");
    pu.printd("");

    final bytes = Uint8List.fromList(utf8.encode(content));
    return await FilePicker.platform.saveFile
    (
      dialogTitle: 'Please enter a file name',
      fileName: '.csv',
      bytes: bytes, // necessary, at least on Windows
      type: FileType.custom, // necessary, at least on macOS
      allowedExtensions: ['csv']
    );

  }
}