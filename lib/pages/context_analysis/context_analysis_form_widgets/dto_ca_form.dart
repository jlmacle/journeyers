
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

import 'package:journeyers/debug_constants.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_form_widgets/context_analysis_form_const_strings_sets_maps_and_ints.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_form_widgets/dto_custom_checkbox_with_text_field.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_form_widgets/dto_custom_segmented_button_with_text_field.dart';
import 'package:journeyers/utils/generic/dev/utility_classes_import.dart';
import 'package:journeyers/utils/generic/text_fields/text_field_utils.dart';

/// {@category Context analysis}
/// A DTO for the context analysis form widget.
class DTOCAForm 
{
  // ─── FIELDS: INDIVIDUAL PERSPECTIVE : beginning ───────────────────────────────────────
  /// The DTOCheckboxWithTextField instance for the question related to the balance between studies and household life.
  var indivBalanceStudiesHousehold              = DTOCheckboxWithTextField();

  /// The DTOCheckboxWithTextField instance for the question related to the balance between accessing income and household life.
  var indivBalanceAccessingIncomeHousehold      = DTOCheckboxWithTextField();

  /// The DTOCheckboxWithTextField instance for the question related to the balance between earning income and household life.
  var indivBalanceEarningIncomeHousehold        = DTOCheckboxWithTextField();

  /// The DTOCheckboxWithTextField instance for the question related to the balance between helping others and household life.
  var indivBalanceHelpingOthersHouseholds        = DTOCheckboxWithTextField();

  /// The DTOCheckboxWithTextField instance for the question related to the need to be more appreciated at work.
  var indivAtWorkMoreAppreciated       = DTOCheckboxWithTextField();

  /// The DTOCheckboxWithTextField instance for the question related to need to remain appreciated at work.
  var indivAtWorkRemainingAppreciated  = DTOCheckboxWithTextField();

  /// The DTOCheckboxWithTextField instance for the question related to the legacies we leave to our children/others.
  var indivBetterLegacies              = DTOCheckboxWithTextField();

  /// The String for the question related to an issue of another type.
  String indivAnotherIssueStr = '';
  // ─── FIELDS: INDIVIDUAL PERSPECTIVE : end ───────────────────────────────────────


  // ─── FIELDS: GROUP PERSPECTIVE : beginning ───────────────────────────────────────
  /// The String for the question related to the problems that the group/teams are trying to solve.
  String groupProblemsToSolveStr = '';

  /// The DTOSegmentedButtonWithTextField instance for the question related to solving the same problem(s) as our groups/teams.
  var groupSameProblemsToSolve                = DTOSegmentedButtonWithTextField();

  /// The DTOSegmentedButtonWithTextField instance for the question related to a group problem-solving process consistent with harmony at home.
  var groupHarmonyHome                 = DTOSegmentedButtonWithTextField();

  /// The DTOSegmentedButtonWithTextField instance for the question related to a group problem-solving process consistent with appreciability at work.
  var groupAppreciabilityAtWork        = DTOSegmentedButtonWithTextField();

  /// The DTOSegmentedButtonWithTextField instance for the question related to a group problem-solving process consistent with our income earning ability.
  var groupEarningAbility              = DTOSegmentedButtonWithTextField();
  // ─── FIELDS: GROUP PERSPECTIVE : end ───────────────────────────────────────

  // ─── DATA STRUCTURE BUILDING : LINKEDHASHMAP : HELPER METHODS: beginning ───────────────────────────────────────
  // Converts a [DTOCheckboxWithTextField] to the standard [LinkedHashMap] wire format.
  // The text value is omitted (left empty) when the checkbox is unchecked.
  LinkedHashMap<String, String> _checkboxDataToMap(DTOCheckboxWithTextField f) =>
      LinkedHashMap<String, String>.from({
        checkbox:  '${f.checked}',
        textField: f.checked ? f.text : '',
      });

  // Converts a [DTOSegmentedButtonWithTextField] to the standard [LinkedHashMap] wire format.
  // Both values are omitted (left empty) when nothing is selected.
  LinkedHashMap<String, String> _segmentedDataToMap(DTOSegmentedButtonWithTextField f) =>
      LinkedHashMap<String, String>.from({
        segmentedButton: f.selection.isNotEmpty ? _segmentedToString(f.selection) : '',
        textField:       f.selection.isNotEmpty ? f.text : '',
        });

  // Serialises a segmented-button selection to a slash-separated string.
  String _segmentedToString(Set<String> values) => values.join('/');
  // ─── DATA STRUCTURE BUILDING : LINKEDHASHMAP : HELPER METHODS: beginning ───────────────────────────────────────

  // ─── DATA STRUCTURE BUILDING : LINKEDHASHMAP : beginning ───────────────────────────────────────
  /// Method used to gather the form data into a LinkedHashMap.
  Future<LinkedHashMap<String, Object> > dataStructureBuilding() async {
  final LinkedHashMap<String, Object> enteredData = LinkedHashMap<String, Object>.from({});

  // Individual perspective
  final individualData = LinkedHashMap<String, Object>.from
  ({
      level2TitleIndividual: 
      LinkedHashMap<String, LinkedHashMap<String, Object>>.from
      ({
        level3TitleBalanceIssue: 
        LinkedHashMap<String, LinkedHashMap<String, Object>>.from
        ({
          level3TitleBalanceIssueItem1: _checkboxDataToMap(indivBalanceStudiesHousehold),
          level3TitleBalanceIssueItem2: _checkboxDataToMap(indivBalanceAccessingIncomeHousehold),
          level3TitleBalanceIssueItem3: _checkboxDataToMap(indivBalanceEarningIncomeHousehold),
          level3TitleBalanceIssueItem4: _checkboxDataToMap(indivBalanceHelpingOthersHouseholds),
        }),

        level3TitleWorkplaceIssue: 
        LinkedHashMap<String, LinkedHashMap<String, Object>>.from
        ({
          level3TitleWorkplaceIssueItem1: _checkboxDataToMap(indivAtWorkMoreAppreciated),
          level3TitleWorkplaceIssueItem2: _checkboxDataToMap(indivAtWorkRemainingAppreciated),
        }),

        level3TitleLegacyIssue: 
        LinkedHashMap<String, LinkedHashMap<String, Object>>.from
        ({
          level3TitleLegacyIssueItem1: _checkboxDataToMap(indivBetterLegacies),
        }),
        
        level3TitleAnotherIssue: LinkedHashMap<String, Object>.from
        ({
          textField: indivAnotherIssueStr,
        }),
      }),
    });

    // Groups/teams perspective
  final groupData = LinkedHashMap<String, Object>.from
    ({
      level2TitleGroup: 
      LinkedHashMap<String, LinkedHashMap<String, Object>>.from
      ({
        level3TitleGroupsProblematics: LinkedHashMap<String, Object>.from({textField: groupProblemsToSolveStr}),

        level3TitleSameProblem:          _segmentedDataToMap(groupSameProblemsToSolve),

        level3TitleHarmonyAtHome:        _segmentedDataToMap(groupHarmonyHome),

        level3TitleAppreciabilityAtWork: _segmentedDataToMap(groupAppreciabilityAtWork),

        level3TitleIncomeEarningAbility: _segmentedDataToMap(groupEarningAbility),
      }),
    });

    enteredData.addAll({"individualPerspective": individualData, "groupPerspective": groupData});

    if (sessionDataDebug) {
      pu.printd('Session Data');
      pu.printd('Session Data: enteredData');
      pu.printd('Session Data: $enteredData');
      pu.printd('Session Data');
    }

    return enteredData;
  }
  // ─── DATA STRUCTURE BUILDING : LINKEDHASHMAP : end ───────────────────────────────────────


    /// Method extracting information from {checkbox: false/true, textField: "data"/null}
  /// and returning \[\[checkbox,"false"/"true"\],\[Notes:,"data"/""\]\].
  /// Straight double quotes are refused during text field input and removed.
  Future<List<Object>> checkboxWithTextFieldDataToPreCSV({
    required LinkedHashMap<String, Object> checkboxWithTextFieldData,
  }) async 
  {
    List<Object> checkboxPreCSVData = [];

    // checkbox data converted from bool to String: values can be "true" or "false"
    var dataCheckbox = "${checkboxWithTextFieldData[checkbox]}";
    var data1 = [
      checkbox,
      dataCheckbox,
    ]; // label in front of the checkbox data in the pre CSV, to help with the processing toward the final CSV

    String dataTextField = (checkboxWithTextFieldData[textField] ?? "") as String;
    var data2 = [
      notes,
      quotesForCSV + dataTextField + quotesForCSV,
    ]; // label in front of the text field data

    checkboxPreCSVData.add(data1);
    checkboxPreCSVData.add(data2);

    return checkboxPreCSVData;
  }



  // Used in the pre-CSV data
  // A label used in front of the content of answered questions.
  String notes = "Notes:";

  // Straight double quotes used to encapsulate the content of answered questions.
  String quotesForCSV = '"';



  // A mapping of question labels with the type of input items (text field, checkbox with text field, segmented button with text field) used to answer.
  

  /// Method extracting information from {segmentedButton: "Yes"/"No"/"I don't know"/null , textField: "data"/null}
  /// and returning \[\[segmentedButton,"Yes"/"No"/"I don't know"/""\],\[Notes:,"data"/""\]\].
  /// Straight double quotes are refused during text field input and removed.
  Future<List<List<String>>> segmentedButtonWithTextFieldDataToPreCSV({
    required LinkedHashMap<String, String> segmentedButtonWithTextFieldData,
  }) async
  {
    List<List<String>> segmentedButtonPreCSVData = [];

    var dataSegmentedButton =
        segmentedButtonWithTextFieldData[segmentedButton] ?? "";
    var data1 = [segmentedButton, dataSegmentedButton];

    var dataTextField =
        segmentedButtonWithTextFieldData[textField] as String;
    List<String> data2 = [notes, quotesForCSV + dataTextField + quotesForCSV];

    segmentedButtonPreCSVData.add(data1);
    segmentedButtonPreCSVData.add(data2);

    return segmentedButtonPreCSVData;
  }

  /// Method extracting information from {textField: "data"/null}
  /// and returning \[\[Notes:,"data"/""\]\].
  /// Straight double quotes are refused during text field input and removed.
  Future<List<List<String>>> textFieldDataToPreCSV({
    required LinkedHashMap<String, Object?> textFieldData,
  }) async
  {
    List<List<String>> textFieldPreCSVData = [];

    var dataTextField = textFieldData[textField] as String;
    List<String> data = [notes, quotesForCSV + dataTextField + quotesForCSV];

    textFieldPreCSVData.add(data);

    return textFieldPreCSVData;
  }

  /// Method processing the form data, and returning a list of pair of data, for the saving to CSV.
  /// The data should be either the individual perspective data, or the group/team perspective data.
  /// The individual perspective data and the group/team perspective data are planned to be written side by side in the CSV file.
  Future<List<List<String>>> dataToPreCSV
  ({
    required LinkedHashMap<String, Object> perspectiveData,
  }) async 
  {
    List<List<String>> preCSVData = [];

    /// Method adding to the pre-CSV data according to input type.
    Future<List<List<String>>> treatmentAccordingToInputType(
      List<List<String>> preCSVData,
      String itemOrTitleLabel,
      LinkedHashMap<String, LinkedHashMap<String, Object>> titleLevel2Or3DataAsLinkedHashMap,
    ) async
    {
      if (mappingLabelsToInputItems[itemOrTitleLabel] == checkbox) {
        // checkboxWithTextFieldDataToPreCSV returns a data similar to [[checkbox, true], [Notes:, a_note]]
        var checkboxPreCSVData = await checkboxWithTextFieldDataToPreCSV(
          checkboxWithTextFieldData:
              titleLevel2Or3DataAsLinkedHashMap[itemOrTitleLabel] as LinkedHashMap<String, Object>,
        );
        
        preCSVData.add(checkboxPreCSVData[0] as List<String>);
        preCSVData.add(checkboxPreCSVData[1] as List<String>);
      }
      // segmentedButtonWithTextFieldDataToPreCSV returns a data similar to [[segmentedButton, Yes], [Notes:, a_note]]
      else if (mappingLabelsToInputItems[itemOrTitleLabel] ==
          segmentedButton) {
        var segmentedButtonPreCSVData =
            await segmentedButtonWithTextFieldDataToPreCSV(
              segmentedButtonWithTextFieldData:
                  titleLevel2Or3DataAsLinkedHashMap[itemOrTitleLabel] as LinkedHashMap<String, String>,
            );
        preCSVData.add(segmentedButtonPreCSVData[0]);
        preCSVData.add(segmentedButtonPreCSVData[1]);
      }
      // textFieldDataToPreCSV returns a data similar to [[Notes:, a_note]]
      else if (mappingLabelsToInputItems[itemOrTitleLabel] ==
          textField) {
        var textFieldpreCSVData = await textFieldDataToPreCSV(
          textFieldData: titleLevel2Or3DataAsLinkedHashMap[itemOrTitleLabel] as LinkedHashMap<String, Object?>,
        );
        preCSVData.add(textFieldpreCSVData[0]);
      } 
      else 
      {
        if (csvBuildingDebug) pu.printd("CSV Building");
        if (csvBuildingDebug) pu.printd("CSV Building: Error: treatmentAccordingToInputType: no mapping found");
        if (csvBuildingDebug) pu.printd("CSV Building: Error: level3Title: $itemOrTitleLabel");
        if (csvBuildingDebug) pu.printd("CSV Building: Error: mappingLabelsToInputItems[level3Title]: ${mappingLabelsToInputItems[itemOrTitleLabel]}");
        if (csvBuildingDebug) pu.printd("CSV Building");
      }
      return preCSVData;
    }

    // There is only one key in the perspective data, one of the two level 2 titles
    var level2TitlePreCSVData = ["", perspectiveData.keys.first];
    // Adding the level 2 title
    preCSVData.add(level2TitlePreCSVData);

    // There is only one value for the title level 2 key, a LinkedHashMap with the form data
    var level2TitleDataValue = perspectiveData.values.first;
    var perspectiveDataAsLinkedHashMap =
        level2TitleDataValue as LinkedHashMap<String, LinkedHashMap<String, Object> >;

    // level 3 titles as keys
    for (var level3Title in perspectiveDataAsLinkedHashMap.keys) {
      var level3TitlePreCSVData = ["", level3Title];
      // Adding the level 3 title
      preCSVData.add(level3TitlePreCSVData);

      // 1. Checking if sub-items exist before starting the processing of the level 3 title data
      if (titlesLevel3WithSubItems.contains(level3Title)) {
        // Going through the sub items
        var level3TitleItemsData = perspectiveDataAsLinkedHashMap[level3Title];
        // A LinkedHashMap as value
        var level3TitleItemsDataAsLinkedHashMap =
            level3TitleItemsData as LinkedHashMap<String, LinkedHashMap<String, Object>>;
        for (var itemLabel in level3TitleItemsDataAsLinkedHashMap.keys) {
          // Adding the item label
          preCSVData.add(["", itemLabel]);
          // Adding input data
          await treatmentAccordingToInputType(
            preCSVData,
            itemLabel,
            level3TitleItemsDataAsLinkedHashMap,
          );
        }
      }
      // 2. No sub items for this level 3 title
      // Checking the type of input item that the level 3 title refers to
      else {
        // Adding input data
        await treatmentAccordingToInputType(
          preCSVData,
          level3Title,
          perspectiveDataAsLinkedHashMap,
        );
      }
    }
    return preCSVData;
  }

     /// Method used to go from pre-CSV data to CSV-friendly data (before saving the data in a CSV file).
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
  /// Addition of a \["",""\] before all level 3 titles.
  Future<List<List<String>>> preCSVToCSVData({required List<List<String>> preCSVData}) async
  {
    // List<LinkedHashMap<String, Object>> _enteredData = [];
    // LinkedHashMap<String, LinkedHashMap<String, LinkedHashMap<String, Object>>> level2TitleIndividualData 
    // LinkedHashMap<String, LinkedHashMap<String, LinkedHashMap<String, Object>>> level2TitleGroupData
    // List<List<String>> csvDataIndividualPerspective = await cu.preCSVToCSVData(preCSVData: preCSVDataIndividualPerspective);
    // List<List<String>> csvDataGroupPerspective = await cu.preCSVToCSVData(preCSVData: preCSVDataGroupPerspective);

    // ─── ANALYZING THE DATA FOR CHECKBOXES WITH "FALSE", AND TEXT FIELDS WITH EMPTY NOTES ───────────────────────────────────────
    for (var index = 0; index < preCSVData.length; index++) {
      var indexedData = preCSVData[index];
      var indexData_1AsString = indexedData[1];

      // Removal of all [checkbox, "false"] (unchecked boxes)
      // Removal of all ["Notes:",]  if related to an unchecked checkbox
      if ((indexedData[0].contains(checkbox)) &&
          (indexData_1AsString.trim() == "false")) {
        preCSVData.removeAt(index);
        // The index now points to the following note
        preCSVData.removeAt(index);
      }
    }

    // ─── ANALYZING THE DATA TO REPLACE "CHECKBOX"S WITH 'X'S  ───────────────────────────────────────
    // ─── WHERE QUESTIONS WITH CHECKBOXES HAVE BEEN CHECKED, ───────────────────────────────────────
    // ─── AND IN FRONT OF THE PARENT TITLE LEVEL 3 IF EXISTANT ───────────────────────────────────────

    // Getting the indexes for the titles level 3 with children, before starting the analysis
    Map<String, int> indexesOfTitlesLevel3WithChildren = {};
    for (var index = 0; index < preCSVData.length; index++) {
      var indexedData = preCSVData[index];
      if (indexedData[1].trim() == level3TitleBalanceIssue) {
        indexesOfTitlesLevel3WithChildren[level3TitleBalanceIssue] = index;
      } else if (indexedData[1].trim() == level3TitleWorkplaceIssue) {
        indexesOfTitlesLevel3WithChildren[level3TitleWorkplaceIssue] = index;
      } else if (indexedData[1].trim() == level3TitleLegacyIssue) {
        indexesOfTitlesLevel3WithChildren[level3TitleLegacyIssue] = index;
      }
    }

    // Analyzing the data for checkboxes with "true" as value,
    // and adding Xs before another processing to remove the checkboxes lines
    for (var index = 0; index < preCSVData.length; index++) {
      var indexedData = preCSVData[index];
      var indexData_1AsString = indexedData[1];
      if ((indexedData[0].contains(checkbox)) &&
          (indexData_1AsString.trim() == "true")) {
        // Adding X in front of the question
        // With the widget design of a question preceding a checkbox, (index -1) is the index of the question
        var previousIndexData = preCSVData[index - 1];
        previousIndexData[0] = 'X';

        // Adding an X to the parent title level 3
        var previousIndexData_1AsString = previousIndexData[1];
        if (childrenOfTitleLevel3BalanceIssue.contains(
          previousIndexData_1AsString,
        )) {
          var parentIndex =
              indexesOfTitlesLevel3WithChildren[level3TitleBalanceIssue];
          var parentData = preCSVData[parentIndex!];
          parentData[0] = 'X';
        } else if (childrenOfTitleLevel3WorkplaceIssue.contains(
          previousIndexData_1AsString,
        )) {
          var parentIndex =
              indexesOfTitlesLevel3WithChildren[level3TitleWorkplaceIssue];
          var parentData = preCSVData[parentIndex!];
          parentData[0] = 'X';
        } else if (childrenOfTitleLevel3LegacyIssue.contains(
          previousIndexData_1AsString,
        )) {
          var parentIndex =
              indexesOfTitlesLevel3WithChildren[level3TitleLegacyIssue];
          var parentData = preCSVData[parentIndex!];
          parentData[0] = 'X';
        }
      }
    }

    // Analyzing to remove the lines with checkboxes
    // These lines are at least 2 indexes apart.
    // All the analysis is feasible in one loop, in spite of the removal effect on the indexes
    for (var index = 0; index < preCSVData.length; index++) {
      var indexedData = preCSVData[index];
      if (indexedData[0].contains(checkbox)) {
        preCSVData.removeAt(index);
      }
    }

    // ─── ANALYZING THE DATA TO ADD 'X'S ───────────────────────────────────────
    // ─── IN FRONT OF THE QUESTIONS WHERE SEGMENTED BUTTONS HAVE BEEN ANSWERED ───────────────────────────────────────
    // ─── AND IN FRONT OF THE PARENT TITLE LEVEL 3 IF EXISTANT ───────────────────────────────────────
    
    // Analyzing the data for segmented buttons not null, and adding Xs in front of the question
    for (var index = 0; index < preCSVData.length; index++) {
      var indexedData = preCSVData[index];
      var indexData_1AsString = indexedData[1];

      if (indexedData[0].contains(segmentedButton)) {
        if (indexData_1AsString.trim() != "") {
          // Removing segmentedButton from the data written
          indexedData[0] = "";
          // Adding X in front of the question
          // With the widget design of a question preceding a segmented button, (index -1) is the index of the question
          var previousIndexData = preCSVData[index - 1];
          previousIndexData[0] = 'X';
        }

        // If the question was not a title level 3, should add an X to the parent title level 3
        // Not for the current interface
      }
    }

    // Removal of all non answered segmented buttons, with their notes.
    for (var index = 0; index < preCSVData.length; index++) {
      var indexedData = preCSVData[index];
      // segmentedButton has already been removed from the answered segmented buttons
      // and replaced with ""
      // Removing all remaining preCSVData lines with segmentedButton
      if (indexedData[0].contains(segmentedButton)) {
        preCSVData.removeAt(index);
        // The index now points to the following note
        preCSVData.removeAt(index);
      }
    }

    // ─── ANALYZING THE DATA TO ADD 'X'S  ───────────────────────────────────────
    // ─── WHERE TEXT FIELD WIDGETS (WITH NO CHECKBOX OR SEGMENTED BUTTONS) HAVE BEEN ANSWERED ───────────────────────────────────────
    for (var index = 0; index < preCSVData.length; index++) {
      var indexedData = preCSVData[index];
      var indexData_1AsString = indexedData[1];

      // Getting the labels that are text field only from textFieldOnlyItems
      for (String textFieldOnlyItem in textFieldOnlyItems) {
        if (indexData_1AsString.trim() == textFieldOnlyItem) {
          // Checking if the note at the next index has content
          int noteIndex = index + 1;
          // Adding the X in front of the question if the note has content
          List<String> noteData = preCSVData[noteIndex];
          if (noteData[1].trim() != '""') {
            var questionData = preCSVData[index];
            questionData[0] = 'X';
          } else // removing the note
          {
            preCSVData.removeAt(noteIndex);
          }
        }
      }
    }

    // ─── ADDING LINES BEFORE EVERY TITLE LEVEL 3 ───────────────────────────────────────
    Set<String> titlesLevel3Processed = {};
    for (var index = 0; index < preCSVData.length; index++) {
      var indexedData = preCSVData[index];
      var indexData_1AsString = indexedData[1];
      String indexData_1AsStringTrimmed = indexData_1AsString.trim();

      if (
      // Found titles level 3
      (titlesLevel3ForTheIndividualPerspective.contains(
                indexData_1AsStringTrimmed,
              ) ||
              titlesLevel3ForTheGroupPerspective.contains(
                indexData_1AsStringTrimmed,
              )) &&
          // and not yet processed
          !(titlesLevel3Processed.contains(indexData_1AsStringTrimmed))) {
        preCSVData.insert(index, ["", ""]);
        titlesLevel3Processed.add(indexData_1AsStringTrimmed);
      }
    }
    return preCSVData;
  }

  // ─── PRINTING/SAVING METHODS ───────────────────────────────────────

  /// Method used to print the individual perspective CSV data, or the group/team perspective CSV data, to a file.
  /// Returns the file name.
  Future<String?> printToCSV({
    required List<List<String>> csvDataIndividualPerspective,
    required List<List<String>> csvDataGroupPerspective,
    String? fileName
  }) async {
    String fileExtension = TextFieldUtils.extensionCSV;
    // Complementing the shortest list to have the same length for both lists
    // before printing side to side
    if (csvDataIndividualPerspective.length < csvDataGroupPerspective.length) {
      for (
        var index = csvDataIndividualPerspective.length;
        index <= csvDataGroupPerspective.length - 1;
        index++
      ) {
        // Adding empty lines
        csvDataIndividualPerspective.add(["", ""]);
      }
    } else if (csvDataIndividualPerspective.length >
        csvDataGroupPerspective.length) {
      for (
        var index = csvDataGroupPerspective.length;
        index <= csvDataIndividualPerspective.length - 1;
        index++
      ) {
        // Adding empty lines
        csvDataGroupPerspective.add(["", ""]);
      }
    }

    String content = "";
    // Building the content line by line (both lists have the same amount of lines)
    for (var index = 0; index < csvDataIndividualPerspective.length; index++) {
      var csvDataIndividualPerspectiveData =
          csvDataIndividualPerspective[index];
      var csvDataGroupPerspectiveData = csvDataGroupPerspective[index];

      String line =
          "${csvDataIndividualPerspectiveData[0]},${csvDataIndividualPerspectiveData[1]},,${csvDataGroupPerspectiveData[0]}, ${csvDataGroupPerspectiveData[1]}\n";
      content += line;
    }

    if (csvBuildingDebug) pu.printd("CSV Building");
    if (csvBuildingDebug) pu.printd("CSV Building: csvDataIndividualPerspective:$csvDataIndividualPerspective");
    if (csvBuildingDebug) pu.printd("CSV Building");
    if (csvBuildingDebug) pu.printd("CSV Building: csvDataGroupPerspective:$csvDataGroupPerspective");
    if (csvBuildingDebug) pu.printd("CSV Building");


    final dataBytes = Uint8List.fromList(utf8.encode(content));
    String? filePath;

    if (Platform.isAndroid)
    {
      filePath = await fu.saveFileOnAndroid(fileName!, fileExtension, dataBytes);      
    }
    else if (Platform.isIOS)
    {
      filePath = await fu.saveFileOniOS(fileName!, fileExtension, dataBytes);
    }
    else if (Platform.isLinux || Platform.isMacOS | Platform.isWindows)
    {
      filePath = await FilePicker.platform.saveFile
      (
        dialogTitle: 'Please enter a file name',
        fileName: '.csv',
        bytes: dataBytes, // necessary, at least on Windows
        type: FileType.custom, // necessary, at least on macOS
        allowedExtensions: ['csv'],
      );
    }
    
    return filePath;
  }


}