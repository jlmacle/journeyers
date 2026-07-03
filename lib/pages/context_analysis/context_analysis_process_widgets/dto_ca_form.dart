
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;

import 'package:journeyers/debug_constants.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_process_widgets/_context_analysis_form_misc_constants.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_process_widgets/dto_custom_checkbox_with_text_field.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_process_widgets/dto_custom_segmented_button_with_text_field.dart';
import 'package:journeyers/utils/generic/dev/test_utils.dart';
import 'package:journeyers/utils/generic/dev/utility_classes_import.dart';
import 'package:journeyers/utils/generic/text_fields/text_field_utils.dart';
import 'package:journeyers/utils/project_specific/dev/utility_classes_import.dart';

/// {@category Context analysis}
/// A DTO for the context analysis form widget.
class DTOCAForm 
{
  /// Default unnamed constructor.
  /// Required because adding [DTOCAForm.fromJson] suppresses
  /// Dart's implicit default constructor.
  DTOCAForm();

  // ─── FIELDS: INDIVIDUAL PERSPECTIVE : beginning ───────────────────────────────────────
  /// The DTOCheckboxWithTextField instance for the question related to the balance between studies and household life.
  var indivBalanceStudiesHousehold              = DTOCheckboxWithTextField();

  /// The DTOCheckboxWithTextField instance for the question related to the balance between accessing income and household life.
  var indivBalanceAccessingIncomeHousehold      = DTOCheckboxWithTextField();

  /// The DTOCheckboxWithTextField instance for the question related to the balance between earning income and household life.
  var indivBalanceEarningIncomeHousehold        = DTOCheckboxWithTextField();

  /// The DTOCheckboxWithTextField instance for the question related to the balance between helping others and household life.
  var indivBalanceHelpingOthersHousehold        = DTOCheckboxWithTextField();

  /// The DTOCheckboxWithTextField instance for the question related to the need to be more appreciated at work.
  var indivAtWorkMoreAppreciated       = DTOCheckboxWithTextField();

  /// The DTOCheckboxWithTextField instance for the question related to the need to remain appreciated at work.
  var indivAtWorkRemainingAppreciated  = DTOCheckboxWithTextField();

  /// The DTOCheckboxWithTextField instance for the question related to the legacies we leave to our children/others.
  var indivBetterLegacies              = DTOCheckboxWithTextField();

  /// The string for the question related to an issue of another type.
  String indivAnotherIssueStr = '';
  // ─── FIELDS: INDIVIDUAL PERSPECTIVE : end ───────────────────────────────────────


  // ─── FIELDS: GROUP PERSPECTIVE : beginning ───────────────────────────────────────
  /// The string for the question related to the problems that the groups/teams are trying to solve.
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

  // ─── DATA STRUCTURE BUILDING : LINKEDHASHMAP : beginning ───────────────────────────────────────
  /// Method used to gather the form data into a LinkedHashMap.
  Future<LinkedHashMap<String, Object> > dataStructureBuilding() async {
  final LinkedHashMap<String, Object> enteredData = LinkedHashMap<String, Object>.from({});

  // Individual perspective
  final individualData = LinkedHashMap<String, Object>.from
  ({
      qf.level2TitleIndividual: 
      LinkedHashMap<String, LinkedHashMap<String, Object>>.from
      ({
        qf.level3TitleBalanceIssue: 
        LinkedHashMap<String, LinkedHashMap<String, Object>>.from
        ({
          qf.level3TitleBalanceIssueItem1:  await _checkboxDataToMap(indivBalanceStudiesHousehold),
          qf.level3TitleBalanceIssueItem2:  await _checkboxDataToMap(indivBalanceAccessingIncomeHousehold),
          qf.level3TitleBalanceIssueItem3:  await _checkboxDataToMap(indivBalanceEarningIncomeHousehold),
          qf.level3TitleBalanceIssueItem4:  await _checkboxDataToMap(indivBalanceHelpingOthersHousehold),
        }),

        qf.level3TitleWorkplaceIssue: 
        LinkedHashMap<String, LinkedHashMap<String, Object>>.from
        ({
          qf.level3TitleWorkplaceIssueItem1:  await _checkboxDataToMap(indivAtWorkMoreAppreciated),
          qf.level3TitleWorkplaceIssueItem2:  await _checkboxDataToMap(indivAtWorkRemainingAppreciated),
        }),

        qf.level3TitleLegacyIssue: 
        LinkedHashMap<String, LinkedHashMap<String, Object>>.from
        ({
          qf.level3TitleLegacyIssueItem1:  await _checkboxDataToMap(indivBetterLegacies),
        }),
        
        qf.level3TitleAnotherIssue: LinkedHashMap<String, Object>.from
        ({
          qf.labelTextField: indivAnotherIssueStr,
        }),
      }),
    });

    // Groups/teams perspective
  final groupData = LinkedHashMap<String, Object>.from
    ({
      qf.level2TitleGroup: 
      LinkedHashMap<String, LinkedHashMap<String, Object>>.from
      ({
        qf.level3TitleGroupsProblematics: LinkedHashMap<String, Object>.from({qf.labelTextField: groupProblemsToSolveStr}),

        qf.level3TitleSameProblem:          await _segmentedDataToMap(groupSameProblemsToSolve),

        qf.level3TitleHarmonyAtHome:        await _segmentedDataToMap(groupHarmonyHome),

        qf.level3TitleAppreciabilityAtWork: await _segmentedDataToMap(groupAppreciabilityAtWork),

        qf.level3TitleIncomeEarningAbility: await _segmentedDataToMap(groupEarningAbility),
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

  // ─── DATA STRUCTURE BUILDING : LINKEDHASHMAP : HELPER METHODS: beginning ───────────────────────────────────────
  // Converts a [DTOCheckboxWithTextField] to the standard [LinkedHashMap] wire format.
  // The text value is omitted (left empty) when the checkbox is unchecked.
  Future<LinkedHashMap<String, String>> _checkboxDataToMap(DTOCheckboxWithTextField f) async

    =>  LinkedHashMap<String, String>.from({
        qf.labelCheckbox:  '${f.checked}',
        qf.labelTextField: f.checked ? f.text : '',
      });

  // Converts a [DTOSegmentedButtonWithTextField] to the standard [LinkedHashMap] wire format.
  // Both values are omitted (left empty) when nothing is selected.
  Future<LinkedHashMap<String, String>> _segmentedDataToMap(DTOSegmentedButtonWithTextField f) async =>
      LinkedHashMap<String, String>.from({
        // Sorting the options before saving
        qf.labelSegmentedButton: f.selection.isNotEmpty ? 
                                        _segmentedToString( ((f.selection).toList()..sort()).toSet() ) : '',
        qf.labelTextField:       f.selection.isNotEmpty ? f.text : '',
        });

  // Serialises a segmented-button selection to a slash-separated string.
  String _segmentedToString(Set<String> values) => values.join('/');
  // ─── DATA STRUCTURE BUILDING : LINKEDHASHMAP : HELPER METHODS: beginning ───────────────────────────────────────

  /// Method extracting information from {labelCheckbox: false/true, labelTextField: data/""}
  /// and returning \[\[labelCheckbox,"false"/"true"\],\[labelNotes, data/""\]\].
  /// Straight double quotes are refused during text field input and removed.
  Future<List<Object>> _checkboxWithTextFieldDataToPreCSV({
    required LinkedHashMap<String, Object> checkboxWithTextFieldData,
  }) async 
  {
    List<Object> checkboxPreCSVData = [];

    // checkbox data converted from bool to String: values can be "true" or "false"
    var dataCheckbox = "${checkboxWithTextFieldData[qf.labelCheckbox]}";
    var data1 = [
      qf.labelCheckbox,
      dataCheckbox,
    ]; // label in front of the checkbox data in the pre CSV, to help with the processing toward the final CSV

    String dataTextField = (checkboxWithTextFieldData[qf.labelTextField] ?? "") as String;
    var data2 = [
      _labelNotes,
      CAFormMiscConstants.quotesForCSV + dataTextField + CAFormMiscConstants.quotesForCSV,
    ]; // label in front of the text field data

    checkboxPreCSVData.add(data1);
    checkboxPreCSVData.add(data2);

    return checkboxPreCSVData;
  }



  // Used in the pre-CSV and CSV data
  /// A label used in front of the content of the answered questions, in the pre-CSV data and in the CSV file.
  final String _labelNotes = "Notes:";


  /// Method extracting information from {labelSegmentedButton: "Yes"/"No"/"I don't know", labelTextField: data/""}
  /// and returning \[\[labelSegmentedButton,"Yes"/"No"/"I don't know"/""\],\[labelNotes, data/""\]\].
  /// Straight double quotes are refused during text field input and removed.
  Future<List<List<String>>> _segmentedButtonWithTextFieldDataToPreCSV({
    required LinkedHashMap<String, String> segmentedButtonWithTextFieldData,
  }) async
  {
    List<List<String>> segmentedButtonPreCSVData = [];

    var dataSegmentedButton =
        segmentedButtonWithTextFieldData[qf.labelSegmentedButton] ?? "";
    var data1 = [qf.labelSegmentedButton, dataSegmentedButton];

    var dataTextField =
        segmentedButtonWithTextFieldData[qf.labelTextField] as String;
    List<String> data2 = [_labelNotes, CAFormMiscConstants.quotesForCSV + dataTextField + CAFormMiscConstants.quotesForCSV];

    segmentedButtonPreCSVData.add(data1);
    segmentedButtonPreCSVData.add(data2);

    return segmentedButtonPreCSVData;
  }

  /// Method extracting information from {labelTextField: data/""}
  /// and returning \[\[labelNotes, data/""\]\].
  /// Straight double quotes are refused during text field input and removed.
  Future<List<List<String>>> _textFieldDataToPreCSV({
    required LinkedHashMap<String, Object?> textFieldData,
  }) async
  {
    List<List<String>> textFieldPreCSVData = [];

    var dataTextField = textFieldData[qf.labelTextField] as String;
    List<String> data = [_labelNotes, CAFormMiscConstants.quotesForCSV + dataTextField + CAFormMiscConstants.quotesForCSV];

    textFieldPreCSVData.add(data);

    return textFieldPreCSVData;
  }

  /// Method processing the form data, and returning a list of pair of data, for the saving to CSV.
  /// The data should be either the individual perspective data, or the group/team perspective data.
  /// The individual perspective data and the group/team perspective data are written side by side in the CSV file.
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
      if (qf.questionsToInputItemsMapping[itemOrTitleLabel] == qf.labelCheckbox) {
        // checkboxWithTextFieldDataToPreCSV returns a data similar to [[checkbox, true], [Notes:, a_note]]
        var checkboxPreCSVData = await _checkboxWithTextFieldDataToPreCSV(
          checkboxWithTextFieldData:
              titleLevel2Or3DataAsLinkedHashMap[itemOrTitleLabel] as LinkedHashMap<String, Object>,
        );
        
        preCSVData.add(checkboxPreCSVData[0] as List<String>);
        preCSVData.add(checkboxPreCSVData[1] as List<String>);
      }
      // segmentedButtonWithTextFieldDataToPreCSV returns a data similar to [[segmentedButton, Yes], [Notes:, a_note]]
      else if (qf.questionsToInputItemsMapping[itemOrTitleLabel] ==
          qf.labelSegmentedButton) {
        var segmentedButtonPreCSVData =
            await _segmentedButtonWithTextFieldDataToPreCSV(
              segmentedButtonWithTextFieldData:
                  titleLevel2Or3DataAsLinkedHashMap[itemOrTitleLabel] as LinkedHashMap<String, String>,
            );
        preCSVData.add(segmentedButtonPreCSVData[0]);
        preCSVData.add(segmentedButtonPreCSVData[1]);
      }
      // textFieldDataToPreCSV returns a data similar to [[Notes:, a_note]]
      else if (qf.questionsToInputItemsMapping[itemOrTitleLabel] ==
          qf.labelTextField) {
        var textFieldpreCSVData = await _textFieldDataToPreCSV(
          textFieldData: titleLevel2Or3DataAsLinkedHashMap[itemOrTitleLabel] as LinkedHashMap<String, Object?>,
        );
        preCSVData.add(textFieldpreCSVData[0]);
      } 
      else 
      {
        if (csvBuildingDebug) pu.printd("CSV Building");
        if (csvBuildingDebug) pu.printd("CSV Building: Error: treatmentAccordingToInputType: no mapping found");
        if (csvBuildingDebug) pu.printd("CSV Building: Error: level3Title: $itemOrTitleLabel");
        if (csvBuildingDebug) pu.printd("CSV Building: Error: mappingLabelsToInputItems[level3Title]: ${qf.questionsToInputItemsMapping[itemOrTitleLabel]}");
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
      if (qf.level3TitlesWithSubItems.contains(level3Title)) {
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

  /// Method used to go from pre-CSV data to CSV data.
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
      if ((indexedData[0].contains(qf.labelCheckbox)) &&
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
      if (indexedData[1].trim() == qf.level3TitleBalanceIssue) {
        indexesOfTitlesLevel3WithChildren[qf.level3TitleBalanceIssue] = index;
      } else if (indexedData[1].trim() == qf.level3TitleWorkplaceIssue) {
        indexesOfTitlesLevel3WithChildren[qf.level3TitleWorkplaceIssue] = index;
      } else if (indexedData[1].trim() == qf.level3TitleLegacyIssue) {
        indexesOfTitlesLevel3WithChildren[qf.level3TitleLegacyIssue] = index;
      }
    }

    // Analyzing the data for checkboxes with "true" as value,
    // and adding Xs before another processing to remove the checkboxes lines
    for (var index = 0; index < preCSVData.length; index++) {
      var indexedData = preCSVData[index];
      var indexData_1AsString = indexedData[1];
      if ((indexedData[0].contains(qf.labelCheckbox)) &&
          (indexData_1AsString.trim() == "true")) {
        // Adding X in front of the question
        // With the widget design of a question preceding a checkbox, (index -1) is the index of the question
        var previousIndexData = preCSVData[index - 1];
        previousIndexData[0] = 'X';

        // Adding an X to the parent title level 3
        var previousIndexData_1AsString = previousIndexData[1];
        if (qf.childrenOfLevel3TitleBalanceIssue.contains(
          previousIndexData_1AsString,
        )) {
          var parentIndex =
              indexesOfTitlesLevel3WithChildren[qf.level3TitleBalanceIssue];
          var parentData = preCSVData[parentIndex!];
          parentData[0] = 'X';
        } else if (qf.childrenOfLevel3TitleWorkplaceIssue.contains(
          previousIndexData_1AsString,
        )) {
          var parentIndex =
              indexesOfTitlesLevel3WithChildren[qf.level3TitleWorkplaceIssue];
          var parentData = preCSVData[parentIndex!];
          parentData[0] = 'X';
        } else if (qf.childrenOfLevel3TitleLegacyIssue.contains(
          previousIndexData_1AsString,
        )) {
          var parentIndex =
              indexesOfTitlesLevel3WithChildren[qf.level3TitleLegacyIssue];
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
      if (indexedData[0].contains(qf.labelCheckbox)) {
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

      if (indexedData[0].contains(qf.labelSegmentedButton)) {
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
      if (indexedData[0].contains(qf.labelSegmentedButton)) {
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
      for (String textFieldOnlyItem in qf.textFieldOnlyItems) {
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
      (qf.level3TitlesIndividual.contains(
                indexData_1AsStringTrimmed,
              ) ||
              qf.level3TitlesGroup.contains(
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

  /// Method used to print the individual perspective CSV data, and the group/team perspective CSV data, to a file.
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
    String? filePathWithExtension;

    if (Platform.isAndroid)
    {
      // Outside of testing: using SAF to save the file
      if (!isInTestEnvironment) { filePathWithExtension = await fu.saveFileOnAndroid(fileName!, fileExtension, dataBytes); }
      
      // otherwise: using tmp files for testing
      else 
      { 
        var applicationFolderPath = await rtdu.getApplicationFolderPath();
        filePathWithExtension = path.join(applicationFolderPath!, "$fileName$fileExtension");
        await fu.saveFileUsingWriteAsBytes(filePathWithExtension: filePathWithExtension,dataBytes: dataBytes);        
      }          
    }
    else if (Platform.isIOS)
    {
      // Outside of testing: using the Swift code
      if (!isInTestEnvironment) { filePathWithExtension = await fu.saveFileOniOS(fileName!, fileExtension, dataBytes); }
      
      // otherwise: using tmp files for testing
      else 
      { 
        var applicationFolderPath = await rtdu.getApplicationFolderPath();
        filePathWithExtension = path.join(applicationFolderPath!, fileName!);
        await fu.saveFileUsingWriteAsBytes(filePathWithExtension: filePathWithExtension, dataBytes: dataBytes);        
      } 
    }
    else if (Platform.isLinux || Platform.isMacOS | Platform.isWindows)
    {
      filePathWithExtension = await FilePicker.saveFile
      (
        dialogTitle: 'Please enter a file name.',
        fileName: '.csv',
        bytes: dataBytes, // necessary, at least on Windows
        type: FileType.custom, // necessary, at least on macOS
        allowedExtensions: ['csv'],
      );
    }
    
    return filePathWithExtension;
  }

  // ─── CONSTRUCTORS and helper methods ─────────────────────────────────────────────────────

  /// Populates a [DTOCAForm] from preloaded JSON data.
  factory DTOCAForm.fromJson(Map<String, dynamic> json) {
    final dto = DTOCAForm();

    // ── INDIVIDUAL PERSPECTIVE ──────────────────────────────────────────────
    final individual = json['individual'] as Map<String, dynamic>;

    // Balance sub-section
    final balance = individual['balance'] as Map<String, dynamic>;
    dto.indivBalanceStudiesHousehold         = _checkboxFromJson(balance['studies']        as Map<String, dynamic>);
    dto.indivBalanceAccessingIncomeHousehold = _checkboxFromJson(balance['accessingIncome'] as Map<String, dynamic>);
    dto.indivBalanceEarningIncomeHousehold   = _checkboxFromJson(balance['earningIncome']   as Map<String, dynamic>);
    dto.indivBalanceHelpingOthersHousehold   = _checkboxFromJson(balance['helpingOthers']   as Map<String, dynamic>);

    // Workplace sub-section
    final workplace = individual['workplace'] as Map<String, dynamic>;
    dto.indivAtWorkMoreAppreciated      = _checkboxFromJson(workplace['moreAppreciated']      as Map<String, dynamic>);
    dto.indivAtWorkRemainingAppreciated = _checkboxFromJson(workplace['remainingAppreciated'] as Map<String, dynamic>);

    // Legacy sub-section
    final legacy = individual['legacy'] as Map<String, dynamic>;
    dto.indivBetterLegacies = _checkboxFromJson(legacy['betterLegacies'] as Map<String, dynamic>);

    // Plain text field
    dto.indivAnotherIssueStr = individual['anotherIssue'] as String? ?? '';

    // ── GROUP / TEAM PERSPECTIVE ────────────────────────────────────────────
    final groups = json['groups'] as Map<String, dynamic>;

    dto.groupProblemsToSolveStr   = groups['problemsText']        as String? ?? '';
    dto.groupSameProblemsToSolve  = _segmentedFromJson(groups['sameProblems']         as Map<String, dynamic>);
    dto.groupHarmonyHome          = _segmentedFromJson(groups['harmonyAtHome']         as Map<String, dynamic>);
    dto.groupAppreciabilityAtWork = _segmentedFromJson(groups['appreciabilityAtWork']  as Map<String, dynamic>);
    dto.groupEarningAbility       = _segmentedFromJson(groups['earningAbility']        as Map<String, dynamic>);

    return dto;
  }


  // ─── fromCSV CONSTRUCTOR and helper methods ───────────────────────────────────────────────────────

/// Populates a [DTOCAForm] from a CSV string.
///
/// The CSV format pairs the individual perspective (cols 0–1) with the
/// group/team perspective (cols 3–4) on every row.  The two perspectives
/// are extracted independently and mapped back to DTO fields.
factory DTOCAForm.fromCSV(String csvContent) {
  final dto = DTOCAForm();

  // Normalising line endings and discarding blank lines.
  final lines = csvContent
      .split('\n')
      .map((l) => l.endsWith('\r') ? l.substring(0, l.length - 1) : l)
      .where((l) => l.isNotEmpty)
      .toList();

  // Each CSV row packs the individual perspective in cols 0-1 and the
  // group/team perspective in cols 3-4.
  final List<(String, String)> indivRows = [];
  final List<(String, String)> groupRows = [];

  for (final line in lines) {
    final cols = _splitCsvLine(line);
    while (cols.length < 5) cols.add('');
    indivRows.add((cols[0].trim(), cols[1].trim()));
    groupRows.add((cols[3].trim(), cols[4].trim()));
  }

  _parseIndividualFromRows(dto, indivRows);
  _parseGroupFromRows(dto, groupRows);

  return dto;
}

/// Reads the JSON file at [assetPath] and returns its decoded
/// contents as a Map\<String, dynamic\>.
/// [assetPath] must be declared in the `assets` section of `pubspec.yaml`.
static Future<Map<String, dynamic>> jsonDataMapFromAsset(String assetPath) async {
  // Retrieves a string from the asset bundle.
  final rawData = await rootBundle.loadString(assetPath);
  Map<String, dynamic> decodedData = jsonDecode(rawData) as Map<String, dynamic>;
  if (preloadingDebug) pu.printd("DTO Pre-loading: DTOCAForm: jsonDataMapFromAsset: $decodedData");
  return decodedData;
}

// Parses a single CSV line, respecting double-quoted fields.
static List<String> _splitCsvLine(String line) {
  final result = <String>[];
  final sb = StringBuffer();
  bool inQuotes = false;

  for (final ch in line.split('')) {
    if (ch == '"') {
      inQuotes = !inQuotes;
      sb.write(ch);
    } else if (ch == ',' && !inQuotes) {
      result.add(sb.toString());
      sb.clear();
    } else {
      sb.write(ch);
    }
  }
  result.add(sb.toString());
  return result;
}

// Strips the surrounding straight double quotes.
static String _stripNoteQuotes(String s) {
  if (s.length >= 2 && s.startsWith('"') && s.endsWith('"')) {
    return s.substring(1, s.length - 1);
  }
  return s;
}


static void _parseIndividualFromRows(
    DTOCAForm dto, List<(String, String)> rows) {
  for (int i = 0; i < rows.length; i++) {
    final (marker, content) = rows[i];

    
    String _readNotes() {
      if (i + 1 < rows.length && rows[i + 1].$1 == 'Notes:') {
        i++;
        return _stripNoteQuotes(rows[i].$2);
      }
      return '';
    }

    if (content == qf.level3TitleBalanceIssueItem1) {
      dto.indivBalanceStudiesHousehold.checked = marker == 'X';
      if (marker == 'X') dto.indivBalanceStudiesHousehold.text = _readNotes();
    } else if (content == qf.level3TitleBalanceIssueItem2) {
      dto.indivBalanceAccessingIncomeHousehold.checked = marker == 'X';
      if (marker == 'X') dto.indivBalanceAccessingIncomeHousehold.text = _readNotes();
    } else if (content == qf.level3TitleBalanceIssueItem3) {
      dto.indivBalanceEarningIncomeHousehold.checked = marker == 'X';
      if (marker == 'X') dto.indivBalanceEarningIncomeHousehold.text = _readNotes();
    } else if (content == qf.level3TitleBalanceIssueItem4) {
      dto.indivBalanceHelpingOthersHousehold.checked = marker == 'X';
      if (marker == 'X') dto.indivBalanceHelpingOthersHousehold.text = _readNotes();
    } else if (content == qf.level3TitleWorkplaceIssueItem1) {
      dto.indivAtWorkMoreAppreciated.checked = marker == 'X';
      if (marker == 'X') dto.indivAtWorkMoreAppreciated.text = _readNotes();
    } else if (content == qf.level3TitleWorkplaceIssueItem2) {
      dto.indivAtWorkRemainingAppreciated.checked = marker == 'X';
      if (marker == 'X') dto.indivAtWorkRemainingAppreciated.text = _readNotes();
    } else if (content == qf.level3TitleLegacyIssueItem1) {
      dto.indivBetterLegacies.checked = marker == 'X';
      if (marker == 'X') dto.indivBetterLegacies.text = _readNotes();
    } else if (content == qf.level3TitleAnotherIssue) {
      if (marker == 'X') dto.indivAnotherIssueStr = _readNotes();
    }

  }
}

static void _parseGroupFromRows(DTOCAForm dto, List<(String, String)> rows) {
  for (int i = 0; i < rows.length; i++) {
    final (marker, content) = rows[i];

    String _readSelection() {
      if (i + 1 < rows.length) {
        final nextContent = rows[i + 1].$2.trim();
        if (rows[i + 1].$1 == '' &&
            nextContent.isNotEmpty &&
            !qf.level2Titles.contains(nextContent) &&
            !qf.level3TitlesGroup.contains(nextContent)) {
          i++;
          return nextContent;
        }
      }
      return '';
    }


    String _readNotes() {
      if (i + 1 < rows.length && rows[i + 1].$1 == 'Notes:') {
        i++;
        return _stripNoteQuotes(rows[i].$2);
      }
      return '';
    }

    if (content == qf.level3TitleGroupsProblematics) {
      if (marker == 'X') dto.groupProblemsToSolveStr = _readNotes();
    } else if (content == qf.level3TitleSameProblem) {
      if (marker == 'X') {
        final sel = _readSelection();
        dto.groupSameProblemsToSolve.selection =
            sel.isNotEmpty ? sel.split('/').map((s) => s.trim()).toSet() : {};
        dto.groupSameProblemsToSolve.text = _readNotes();
      }
    } else if (content == qf.level3TitleHarmonyAtHome) {
      if (marker == 'X') {
        final sel = _readSelection();
        dto.groupHarmonyHome.selection =
            sel.isNotEmpty ? sel.split('/').map((s) => s.trim()).toSet() : {};
        dto.groupHarmonyHome.text = _readNotes();
      }
    } else if (content == qf.level3TitleAppreciabilityAtWork) {
      if (marker == 'X') {
        final sel = _readSelection();
        dto.groupAppreciabilityAtWork.selection =
            sel.isNotEmpty ? sel.split('/').map((s) => s.trim()).toSet() : {};
        dto.groupAppreciabilityAtWork.text = _readNotes();
      }
    } else if (content == qf.level3TitleIncomeEarningAbility) {
      if (marker == 'X') {
        final sel = _readSelection();
        dto.groupEarningAbility.selection =
            sel.isNotEmpty ? sel.split('/').map((s) => s.trim()).toSet() : {};
        dto.groupEarningAbility.text = _readNotes();
      }
    }

  }
}
  // ── PRIVATE JSON HELPERS ──────────────────────────────────────────────────

  // Builds a [DTOCheckboxWithTextField] from a JSON map of the shape
  // `{ "checked": bool, "text": String }`.
  static DTOCheckboxWithTextField _checkboxFromJson(Map<String, dynamic> map) {
    final field = DTOCheckboxWithTextField();
    field.checked = map['checked'] as bool?   ?? false;
    field.text    = map['text']    as String? ?? '';
    return field;
  }

  // Builds a [DTOSegmentedButtonWithTextField] from a JSON map of the shape
  // `{ "selection": String, "text": String }`.
  //
  // The `selection` value is a comma-separated string (e.g. `"Yes,No"`).
  // Each token is trimmed before being added to the [Set].
  // An empty or absent `selection` string produces an empty [Set],
  // which matches the default state of a DTOSegmentedButtonWithTextField.
  static DTOSegmentedButtonWithTextField _segmentedFromJson(Map<String, dynamic> map) {
    final field = DTOSegmentedButtonWithTextField();
    final raw   = map['selection'] as String? ?? '';
    field.selection = raw.isNotEmpty
        ? raw.split(',').map((token) => token.trim()).toSet()
        : <String>{};
    field.text = map['text'] as String? ?? '';
    return field;
  }

  

  // ─── PRINTING/SAVING METHODS ───────────────────────────────────────

/// Prints all DTO field values to the console for debugging purposes.
void printToConsole() {
  pu.printd('─── DTOCAForm ──────────────────────────────────────────────');

  // ── Individual perspective ──────────────────────────────────────
  pu.printd('  ── Individual perspective ──');
  pu.printd('  indivBalanceStudiesHousehold        : text="${indivBalanceStudiesHousehold.text}", checked=${indivBalanceStudiesHousehold.checked}');
  pu.printd('  indivBalanceAccessingIncomeHousehold: text="${indivBalanceAccessingIncomeHousehold.text}", checked=${indivBalanceAccessingIncomeHousehold.checked}');
  pu.printd('  indivBalanceEarningIncomeHousehold  : text="${indivBalanceEarningIncomeHousehold.text}", checked=${indivBalanceEarningIncomeHousehold.checked}');
  pu.printd('  indivBalanceHelpingOthersHousehold  : text="${indivBalanceHelpingOthersHousehold.text}", checked=${indivBalanceHelpingOthersHousehold.checked}');
  pu.printd('  indivAtWorkMoreAppreciated          : text="${indivAtWorkMoreAppreciated.text}", checked=${indivAtWorkMoreAppreciated.checked}');
  pu.printd('  indivAtWorkRemainingAppreciated     : text="${indivAtWorkRemainingAppreciated.text}", checked=${indivAtWorkRemainingAppreciated.checked}');
  pu.printd('  indivBetterLegacies                 : text="${indivBetterLegacies.text}", checked=${indivBetterLegacies.checked}');
  pu.printd('  indivAnotherIssueStr                : text="$indivAnotherIssueStr"');

  // ── Group / team perspective ────────────────────────────────────
  pu.printd('  ── Group/team perspective ──');
  pu.printd('  groupProblemsToSolveStr   :  text="$groupProblemsToSolveStr"');
  pu.printd('  groupSameProblemsToSolve  :  text="${groupSameProblemsToSolve.text}", selection=${groupSameProblemsToSolve.selection}');
  pu.printd('  groupHarmonyHome          :  text="${groupHarmonyHome.text}", selection=${groupHarmonyHome.selection}');
  pu.printd('  groupAppreciabilityAtWork :  text="${groupAppreciabilityAtWork.text}", selection=${groupAppreciabilityAtWork.selection}');
  pu.printd('  groupEarningAbility       :  text="${groupEarningAbility.text}", selection=${groupEarningAbility.selection}');

  pu.printd('────────────────────────────────────────────────────────────');
}

}