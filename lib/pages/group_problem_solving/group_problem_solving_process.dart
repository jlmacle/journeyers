import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:journeyers/app_themes.dart';
import 'package:journeyers/debug_constants.dart';
import 'package:journeyers/utils/generic/dashboard/dashboard_utils.dart';
import 'package:journeyers/utils/generic/dev/utility_classes_export.dart';
import 'package:journeyers/pages/group_problem_solving/group_problem_solving_widgets/group_problem_solving_checklist.dart';
import 'package:journeyers/pages/group_problem_solving/group_problem_solving_widgets/group_problem_solving_group_moods.dart';
import 'package:journeyers/pages/group_problem_solving/group_problem_solving_widgets/group_problem_solving_keywords.dart';
import 'package:journeyers/pages/group_problem_solving/group_problem_solving_widgets/group_problem_solving_new_solution.dart';
import 'package:journeyers/pages/group_problem_solving/group_problem_solving_widgets/group_problem_solving_problem_to_solve.dart';
import 'package:journeyers/pages/group_problem_solving/group_problem_solving_widgets/group_problem_solving_solutions_list.dart';
import 'package:journeyers/widgets/utility/session_file_name_desktop_platforms.dart';
import 'package:journeyers/widgets/utility/session_file_name_mobile_platforms.dart';


/// {@category Group problem-solving}
/// The process for a group problem-solving.
class GroupProblemSolvingProcess extends StatefulWidget 
{
  /// A callback function called after all session files have been deleted, and used to pass from dashboard to context analysis form.
  final VoidCallback parentCallbackFunctionToRefreshTheGroupProblemSolvingPage;

  const GroupProblemSolvingProcess
  ({
    super.key,
    required this.parentCallbackFunctionToRefreshTheGroupProblemSolvingPage
  });

  @override
  State<GroupProblemSolvingProcess> createState() => GroupProblemSolvingProcessState();
}

class GroupProblemSolvingProcessState extends State<GroupProblemSolvingProcess> 
{
  //**************** PREFERENCES related data and methods ****************/
  bool _isApplicationFolderPathLoading = true;

  // method used to get the set preferences
  void getApplicationFolderPathPref() async
  { 
    var prefs = await SharedPreferences.getInstance();
    await prefs.reload(); // necessary to have access to the newly set preference
    String? folderPathData = await upu.getApplicationFolderPath();
    if (Platform.isAndroid || Platform.isIOS)  
      {if (sessionDataDebug) pu.printd("Session Data: folderPathData: $folderPathData");}
    // Application folder path called from the Kotlin code    
    setState(() 
    {
      _isApplicationFolderPathLoading = false; 
    });
  }

  //**************** TITLE related data ****************//

  // TITLE for the group problem-solving process
  // TextEditingController for entering a new title
  final TextEditingController _problemTitleController = .new();

  //**************** STAKEHOLDER IDENTIFIERS related data ****************//
  GlobalKey<GroupProblemSolvingGroupMoodsState> groupMoods1Key = GlobalKey(debugLabel: "group-moods-1");
  GlobalKey<GroupProblemSolvingGroupMoodsState> groupMoods2Key = GlobalKey(debugLabel: "group-moods-2");

  // Mode for modifying a stakeholder identifier
  bool _isModificationMode = false;

  // Mode for editing a stakeholder identifier
  bool _isEditMode = false;

  // Mode for deleting a stakeholder identifier
  bool _isDeleteMode = false;

  // The list of stakeholders identifiers for the first column
  final List<String> _identifiersCol1 = [];

  // The list of stakeholders identifiers for the second column
  final List<String> _identifiersCol2 = [];

  // The list of stakeholders identifiers' colors for the first column
  final List<Color> _identifiersColors1 = [];

  // The list of stakeholders identifiers' colors for the second column
  final List<Color> _identifiersColors2 = [];  

  //**************** KEYWORDS related data ****************//
  // List to store the keywords entered by the user
  List<String> _currentKeywords = []; 
  List<Map<String, dynamic>> _history = [];
  
  //**************** SOLUTIONS related data ****************//
  // List to store the solutions entered by the user
  final List<String> _solutions = [];
  
  //**************** FILE SAVING related data ****************//
  String fileName = "";
  String fileExtension = ".txt";

  // Method used to update the file name value
  void processFileNameUpdate(String value)
  {
    fileName = value;
  }
  
  // Method used to save data and metadata
  Future<void> saveDataAndMetadata() async 
  {
    if (_solutions.isEmpty) 
    {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No solutions to save!")),
      );
      return;
    }

    String sessionTitle = _problemTitleController.text.trim().isNotEmpty 
        ? _problemTitleController.text.trim()
        : "Problem Solving Session";

    // Format solutions for the text file
    var now = DateTime.now();
    //.add_jm() to add this hour:minutes format: 5:08 PM
    var formatter = DateFormat('MMMM dd, yyyy').add_jm();
    var formattedDate = formatter.format(now);
    String fileContent = "Group Problem Solving Solutions\n";
    fileContent += "$sessionTitle\n";
    fileContent += "Date: $formattedDate\n";
    fileContent += "----------------------------\n";
    for (var i = 0; i < _solutions.length; i++) {
      fileContent += "${i + 1}. ${_solutions[i]}\n";
    }
    
    Uint8List dataBytes = Uint8List.fromList(utf8.encode(fileContent));
    String? filePath;

    try {
      // Platform-specific file saving
      if (Platform.isAndroid) {
        filePath = await fu.saveFileOnAndroid(fileName, fileExtension, dataBytes);
      } else if (Platform.isIOS) {
        filePath = await fu.saveFileOniOS(fileName, fileExtension, dataBytes);
      } else {
        // Desktop implementation using FilePicker
        filePath = await FilePicker.platform.saveFile(
          dialogTitle: 'Please enter a file name',
          fileName: '$fileName$fileExtension', 
          bytes: dataBytes,
          type: FileType.custom,
          allowedExtensions: ['txt'],
        );
      }

      // Save Metadata to Dashboard if file was saved successfully
      if (filePath != null) 
      {
        // Date
        var now = DateTime.now();
        //.add_jm() to add this hour:minutes format: 5:08 PM
        var formatter = DateFormat('MMMM dd, yyyy').add_jm();
        var formattedDate = formatter.format(now);   
        await du.saveDashboardMetadata
        (
          typeOfContextData: DashboardUtils.groupProblemSolvingsContext,
          title: sessionTitle, 
          keywords: _currentKeywords, 
          formattedDate: formattedDate,
          pathToFile: filePath,
        );

        await upu.saveWasSessionDataSaved(value: true, context: DashboardUtils.groupProblemSolvingsContext);

        widget.parentCallbackFunctionToRefreshTheGroupProblemSolvingPage();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Session saved successfully!")),
        );
      }
    } catch (e) {
      pu.printd("Save Error: $e");
    }
  }

// Method used to load the context analyses metadata
Future<void> _loadHistory() async {
  final data = await du.retrieveAllDashboardMetadata(
    typeOfContextData: DashboardUtils.contextAnalysesContext
  );
  setState(() {
    _history = List<Map<String, dynamic>>.from(data);
  });
}

void _handleSessionSelection(Map<String, dynamic> session) {
  setState(() {
    _problemTitleController.text = "${session['title']}";
    
    if (session['keywords'] != null) {
      // Creates a NEW list instance instead of .clear() and .addAll()
      // This changes the reference, triggering didUpdateWidget correctly
      _currentKeywords = List<String>.from(session['keywords']);
    } else {
      _currentKeywords = [];
    }
  });
}

  // Method used to add a solution to the list of solutions
  void addSolutionToList(String value)
  {
    _solutions.add(value);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
     _loadHistory();
    getApplicationFolderPathPref();
  }

  @override
  void dispose() 
  {
    _problemTitleController.dispose();
    super.dispose();
  }
  
    
 @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);
    final double screenWidthInInches = size.width / 160;

    return Column(   
      children: [
        // 1. TOP: The problem to be solved (Full Width)
        GroupProblemSolvingProblemToSolve(
          problemTitleController: _problemTitleController,
          previousSessions: _history,
          onSessionSelected: _handleSessionSelection,
        ),
        const Divider(),

        // 2. CENTER: The row with identifiers and scrollable content
        Expanded(
          child:
          Row(
            children: 
            [
              // LEFT COLUMN: Add/'Clear One'/'Edit' buttons, group mood widget
              Expanded(
                child: Column
                (
                  children: 
                  [
                    _buildHeaderButton
                    (
                      text: "➕", color: Colors.white, 
                      onPressed: (){groupMoods1Key.currentState?.addToIdentifiers();},
                      screenWidthInInches: screenWidthInInches
                    ),
                    if (_isModificationMode)
                      _buildHeaderButton
                      (
                        text:  _isDeleteMode ? "Clear\nOne" : "Edit",
                        color: _isDeleteMode ? const Color(0xFFB71C1C) : const Color(0xFFE65100), 
                        onPressed: () =>  setState(() { _isDeleteMode = !_isDeleteMode; _isEditMode = !_isEditMode;}),
                        screenWidthInInches: screenWidthInInches
                      ),
                    // ..._whichIdentifiersListToBuild(column: 1),
                    Expanded
                    (
                      child:GroupProblemSolvingGroupMoods
                      (
                        key: groupMoods1Key,
                        groupMoods1Key: groupMoods1Key, groupMoods2Key: groupMoods2Key,
                        columnNumber:1, identifiersCol1: _identifiersCol1, identifiersCol2: _identifiersCol2,
                        identifiersColors1: _identifiersColors1, identifiersColors2: _identifiersColors2,
                        isEditMode: _isEditMode, isDeleteMode: _isDeleteMode
                      )
                    )
                  ],
                ),
              ),
              
              // CENTER CONTENT
              Expanded
              (
                flex: 2,
                child: 
                CustomScrollView
                (
                  key: const Key('group-problem-solving-process-scrollview'),
                  slivers: 
                  [
                    const SliverToBoxAdapter
                    (
                      child: Padding
                      (
                        padding: EdgeInsets.only(top: 10, bottom: 10),
                        child: GroupProblemSolvingChecklist(),
                      )                        
                    ), 
                    // TODO: to store and retrieve previous stakeholder teams
                    const SliverToBoxAdapter
                    (
                      child: Divider()                       
                    ),  
                    SliverToBoxAdapter
                    (
                      child: Padding
                      (
                        padding: const EdgeInsets.only(top: 10, bottom: 10),
                        child: GroupProblemSolvingKeywords
                        (
                          currentKeywords: _currentKeywords,
                          keywordsUpdatedCallbackFunction: (newKeywords) 
                          {
                            setState(() {
                              _currentKeywords.clear();
                              _currentKeywords.addAll(newKeywords);
                            });
                          }
                        ),
                      )                        
                    ),  
                    const SliverToBoxAdapter
                    (
                      child: Divider()                       
                    ), 
                    // Solutions List component
                    SliverToBoxAdapter(
                      child: GroupProblemSolvingSolutionsList(solutions: _solutions),
                    ),
                  ]
                )
              ),

              // RIGHT COLUMN
              Expanded(
                child: Column(
                  children: [
                    _buildHeaderButton
                    (
                      text: _isModificationMode ? "Done" : "✏️", 
                      color: _isModificationMode ? orangeShade900 : Colors.white, 
                      onPressed:_isModificationMode 
                        ? () => setState(() {                      
                            _isEditMode = false;
                            _isDeleteMode = false;
                            _isModificationMode = !_isModificationMode;                      
                          })
                        : () => setState(() {_isEditMode = true; _isModificationMode = !_isModificationMode;}),
                        screenWidthInInches: screenWidthInInches
                    ),
                    if (_isModificationMode)
                      _buildHeaderButton
                      (
                        text: "Clear\nAll", color:  const Color(0xFFB71C1C),
                        onPressed: () {groupMoods1Key.currentState?.clearAllIdentifiers();},
                        screenWidthInInches: screenWidthInInches
                      ),
                    // ..._whichIdentifiersListToBuild(column: 2),
                    Expanded
                    (
                      child: GroupProblemSolvingGroupMoods
                      (
                        key: groupMoods2Key,
                        groupMoods1Key: groupMoods1Key,groupMoods2Key: groupMoods2Key,
                        columnNumber: 2, identifiersCol1: _identifiersCol1, identifiersCol2: _identifiersCol2,
                        identifiersColors1: _identifiersColors1, identifiersColors2: _identifiersColors2,
                        isEditMode: _isEditMode, isDeleteMode: _isDeleteMode
                      )
                    )
                  ],
                ),
              ),
            ],
          ),
        ),

        // 3. BOTTOM: Full Width Solution Input Field
        const Divider(height: 1),
        GroupProblemSolvingNewSolution(solutionAddedCallbackFunction: addSolutionToList),
        
        //********** Data saving ************//
        Center
        (
          child: 
          Column
          (
            children: 
            [
              // Button to start the data saving process                     
              _isApplicationFolderPathLoading
              ? const Center(child: CircularProgressIndicator())
              : (Platform.isAndroid || Platform.isIOS) // Unified logic for mobile
                  // Defining file name and saving file for mobile platforms 
                  ? SessionFileNameMobilePlatforms(fileExtension: fileExtension,  fileNameSubmittedCallbackFunction: processFileNameUpdate, parentCallbackFunctionToSaveDataAndMetadata: saveDataAndMetadata)
                  // Saving file for desktop platforms
                  : SessionFileNameDesktopPlatforms(parentCallbackFunctionToSaveDataAndMetadata: saveDataAndMetadata)
            ],
          ),
        ),
      ]
    );
  }

  // Method used to build the header buttons
  Widget _buildHeaderButton
  ({required String text, required Color color, 
  required VoidCallback onPressed, required double screenWidthInInches}) 
  {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: appBarWhite, padding: (screenWidthInInches <2.7) ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: 20, vertical: 10)),
        onPressed: onPressed,
        child: Center(child: Text(text, style: const TextStyle(fontSize: 12), textAlign: TextAlign.center)),
      ),
    );
  }

}

