import "dart:convert";
import "dart:io";

import "package:flutter/services.dart";

import "package:path/path.dart" as path;

import "package:journeyers/debug_constants.dart";
import "package:journeyers/pages/context_analysis/context_analysis_form_widgets/context_analysis_form_const_strings_and_ints.dart";
import "package:journeyers/pages/context_analysis/context_analysis_form_widgets/context_analysis_form_questions.dart";
import "package:journeyers/utils/generic/dev/externalized_test_strings.dart";
import "package:journeyers/utils/generic/dev/utility_classes_import.dart";

/// {@category Utils - Project-specific}
/// A project-specific utility class related to CSV.
class CSVUtils 
{
  // ─── UTILS: beginning ───────────────────────────────────────
  // The questions used in the form
  final CAFormQuestions _q =
      CAFormQuestions();
  // ─── UTILS: end ───────────────────────────────────────

  /// A label used in front of the content of answered questions.
  String notes = "Notes:";

  /// Straight double quotes used to encapsulate the content of answered questions.
  String quotesForCSV = '"';

  // ─── MAPPING QUESTIONS TO INPUT WIDGETS TO PROCESS DATA ACCORDING TO INPUT WIDGETS ───────────────────────────────────────
  /// A mapping of question labels with the type of input items (text field, checkbox with text field, segmented button with text field) used to answer.
  Map<String, String> mappingLabelsToInputItems = {};

  // ─── SETS OF THE LEVEL 2, LEVEL 3 TITLES, AND RELATED SETS ───────────────────────────────────────
  /// A set of the existing titles level 2.
  Set<String> titlesLevel2 = {};

  // Sets of the existing titles level 3.
  /// A set of the titles level 3 related to an individual perspective.
  Set<String> titlesLevel3ForTheIndividualPerspective = {};

  /// A set of the titles level 3 related to a group/team perspective.
  Set<String> titlesLevel3ForTheGroupPerspective = {};

  /// A set of the existing titles level 3 with sub items.
  Set<String> titlesLevel3WithSubItems = {};

  // Sets of the children of the existing titles level 3 with sub items
  /// A set of the children of the title level 3 related to balance issues.
  Set<String> titleLevel3BalanceIssueChildren = {};

  /// A set of the children of the title level 3 related to workplace issues.
  Set<String> titleLevel3WorkplaceIssueChildren = {};

  /// A set of the children of the title level 3 related to a legacy issue.
  Set<String> titleLevel3LegacyIssueChildren = {};

  /// A set of the text fields only items
  Set<String> textFieldOnlyItems = {};

  // ─── THE DATA STRUCTURE TO RETURN ───────────────────────────────────────
  /// The pre-CSV data structure (before adding extra lines, removing or renaming keywords, ...)
  List<Object> preCSVData = [];

  // TODO: to clean
  CSVUtils() {
    // A mapping of question labels with the type of input items (text field, checkbox with text field, segmented button with text field) used to answer.
    mappingLabelsToInputItems = {
      //** Individual perspective **/
      // balance issue
      _q.level3TitleBalanceIssueItem1: checkbox,
      _q.level3TitleBalanceIssueItem2: checkbox,
      _q.level3TitleBalanceIssueItem3: checkbox,
      _q.level3TitleBalanceIssueItem4: checkbox,
      // workplace issue
      _q.level3TitleWorkplaceIssueItem1: checkbox,
      _q.level3TitleWorkplaceIssueItem2: checkbox,
      // legacy issue
      _q.level3TitleLegacyIssueItem1: checkbox,
      // another type
      _q.level3TitleAnotherIssue: textField,

      //** Group/team perspective **/
      // group problematics
      _q.level3TitleGroupsProblematics: textField,
      // same problem?
      _q.level3TitleSameProblem: segmentedButton,
      // harmony at home
      _q.level3TitleHarmonyAtHome: segmentedButton,
      // appreciability at work
      _q.level3TitleAppreciabilityAtWork: segmentedButton,
      // earning ability
      _q.level3TitleIncomeEarningAbility: segmentedButton,
    };

    // A set of the existing titles level 2.
    titlesLevel2 = {_q.level2TitleIndividual, _q.level2TitleGroup};

    // A set of the titles level 3 related to an individual perspective.
    titlesLevel3ForTheIndividualPerspective = {
      _q.level3TitleBalanceIssue,
      _q.level3TitleWorkplaceIssue,
      _q.level3TitleLegacyIssue,
      _q.level3TitleAnotherIssue,
    };

    // A set of the titles level 3 related to a group/team perspective.
    titlesLevel3ForTheGroupPerspective = {
      _q.level3TitleGroupsProblematics,
      _q.level3TitleSameProblem,
      _q.level3TitleHarmonyAtHome,
      _q.level3TitleAppreciabilityAtWork,
      _q.level3TitleIncomeEarningAbility,
    };

    /// A set of the existing titles level 3 with sub items.
    titlesLevel3WithSubItems = {
      _q.level3TitleBalanceIssue,
      _q.level3TitleWorkplaceIssue,
      _q.level3TitleLegacyIssue,
    };

    // Sets of the children of the existing titles level 3 with sub items
    /// A set of the children of the title level 3 related to balance issues.
    titleLevel3BalanceIssueChildren = {
      _q.level3TitleBalanceIssueItem1,
      _q.level3TitleBalanceIssueItem2,
      _q.level3TitleBalanceIssueItem3,
      _q.level3TitleBalanceIssueItem4,
    };

    /// A set of the children of the title level 3 related to workplace issues.
    titleLevel3WorkplaceIssueChildren = {
      _q.level3TitleWorkplaceIssueItem1,
      _q.level3TitleWorkplaceIssueItem2,
    };

    /// A set of the children of the title level 3 related to a legacy issue.
    titleLevel3LegacyIssueChildren = {_q.level3TitleLegacyIssueItem1};

    // A set of the text fields only items
    textFieldOnlyItems = {
      _q.level3TitleAnotherIssue,
      _q.level3TitleGroupsProblematics,
    };
  }

  // ─── METHODS RETRIEVING THE CSV DATA FOR EDITION OR VIEWING : beginning ───────────────────────────────────────
  
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

    return data;
  }
  
  /// Method used to retrieve data from the CSV file and to return a list of csvDataIndividualPerspective and csvDataGroupPerspective structures
  Future<Map<String,List<Object>>> csvFileToPreviewPerspectiveData(String pathToCSVFile) async
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
      if (previewBuildingDebug) pu.printd("Preview Building: csvFileToPreviewPerspectiveData on Android");
      final String content = await fu.readTextContentOnAndroid(fileName: fileName);
      csvLines = LineSplitter.split(content).toList();
    }
    else if (Platform.isIOS)
    {
      String fileName = path.basename(pathToCSVFile);
      if (previewBuildingDebug) pu.printd("Preview Building: csvFileToPreviewPerspectiveData on iOS");
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
  // ─── METHODS RETRIEVING THE CSV DATA FOR EDITION OR VIEWING : end ───────────────────────────────────────

}
