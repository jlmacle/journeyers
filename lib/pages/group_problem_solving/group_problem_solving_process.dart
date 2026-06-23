import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:journeyers/app_themes.dart';
import 'package:journeyers/debug_constants.dart';
import 'package:journeyers/pages/group_problem_solving/group_problem_solving_process_widgets/1_group_problem_solving_problem_to_solve_declaration.dart';
import 'package:journeyers/pages/group_problem_solving/group_problem_solving_process_widgets/2_group_problem_solving_group_moods.dart';
import 'package:journeyers/pages/group_problem_solving/group_problem_solving_process_widgets/3_group_problem_solving_checklist.dart';
import 'package:journeyers/pages/group_problem_solving/group_problem_solving_process_widgets/4_group_problem_solving_keywords_declaration.dart';
import 'package:journeyers/pages/group_problem_solving/group_problem_solving_process_widgets/5_group_problem_solving_ideas_list.dart';
import 'package:journeyers/pages/group_problem_solving/group_problem_solving_process_widgets/6_group_problem_solving_new_idea.dart';
import 'package:journeyers/pages/group_problem_solving/group_problem_solving_process_widgets/_group_problem_solving_externalized_variables.dart';
import 'package:journeyers/utils/generic/dashboard/dashboard_utils.dart';
import 'package:journeyers/utils/generic/dev/utility_classes_import.dart';
import 'package:journeyers/utils/generic/text_fields/text_field_utils.dart';
import 'package:journeyers/widgets/utility/lists/new_text_list_or_loading_page.dart';
import 'package:journeyers/widgets/utility/process_widgets/session_file_name_desktop_platforms.dart';
import 'package:journeyers/widgets/utility/process_widgets/session_file_name_mobile_platforms.dart';

// TODO: to clean
/// {@category Group problem-solving}
/// The process for a group problem-solving.
class GPSProcess extends StatefulWidget 
{
  /// A callback function called after the end of the process, and used to pass from new session process to dashboard.
  final VoidCallback parentCallbackFunctionToRefreshTheGPSPage;

  const GPSProcess
  ({
    super.key,
    required this.parentCallbackFunctionToRefreshTheGPSPage
  });

  @override
  State<GPSProcess> createState() => GPSProcessState();
}

class GPSProcessState extends State<GPSProcess> 
{
  // ─── PREFERENCES related data and methods ───────────────────────────────────────
  bool _isApplicationFolderPathLoading = true;

  // method used to get the set preferences
  void _getApplicationFolderPathPref() async
  { 
    var prefs = await SharedPreferences.getInstance();
    await prefs.reload(); // necessary to have access to the newly set preference
        
    // Application folder path called from the Kotlin code    
    setState(() 
    {
      _isApplicationFolderPathLoading = false; 
    });
  }

  // ─── TITLE related data ───────────────────────────────────────

  // TITLE for the group problem-solving process
  // TextEditingController for entering a new title
  final TextEditingController _problemTitleController = .new();

  // ─── STAKEHOLDER IDENTIFIERS related data ───────────────────────────────────────
  final GlobalKey<GPSGroupMoodsState> _groupMoods1Key = GlobalKey(debugLabel: "group-moods-1");
  final GlobalKey<GPSGroupMoodsState> _groupMoods2Key = GlobalKey(debugLabel: "group-moods-2");

  // Mode for modifying a stakeholder identifier
  bool _isModificationMode = false;

  // Mode for editing a stakeholder identifier
  bool _isEditMode = false;

  // Mode for deleting a stakeholder identifier
  bool _isDeleteMode = false;

  // The list of stakeholders identifiers for the first column
  List<String> _identifiersCol1 = [];

  // The list of stakeholders identifiers for the second column
  List<String> _identifiersCol2 = [];

  // The list of stakeholders identifiers' colors for the first column
  final List<Color> _identifiersColors1 = [];

  // The list of stakeholders identifiers' colors for the second column
  final List<Color> _identifiersColors2 = [];  

  // ─── KEYWORDS related data ───────────────────────────────────────
  // List to store the keywords entered by the user
  Set<String> _currentKeywords = {}; 
  List<Map<String, dynamic>> _caMetadata = [];
  
  // ─── SOLUTIONS related data ───────────────────────────────────────
  // List to store the ideas entered by the user
  final List<String> _ideas = [];
  
  // ─── FILE SAVING related data ───────────────────────────────────────
  String _fileName = "";
  final String _fileExtension = TextFieldUtils.extentionTXT;

  // Method used to update the file name value
  void _processFileNameUpdate(String value)
  {
    _fileName = value;
  }
  
  // Method used to save data and metadata
  Future<void> _saveDataAndMetadata() async 
  {
    if (_ideas.isEmpty) 
    {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No ideas to save!")),
      );
      return;
    }

    String sessionTitle = _problemTitleController.text.trim().isNotEmpty 
        ? _problemTitleController.text.trim()
        : "Problem Solving Session";

    // Format ideas for the text file
    var now = DateTime.now();
    //.add_jm() to add this hour:minutes format: 5:08 PM
    var formatter = DateFormat('MMMM dd, yyyy').add_jm();
    var formattedDate = formatter.format(now);
    String fileContent = "Group Problem Solving Ideas\n";
    fileContent += "$sessionTitle\n";
    fileContent += "Date: $formattedDate\n";
    fileContent += "----------------------------\n";
    for (var i = 0; i < _ideas.length; i++) {
      fileContent += "${i + 1}. ${_ideas[i]}\n";
    }
    
    Uint8List dataBytes = Uint8List.fromList(utf8.encode(fileContent));
    String? filePath;

    try {
      // Platform-specific file saving
      if (Platform.isAndroid) 
      {
        // Outside of testing: using SAF to save the file
        if (!runningTests) {
          filePath = await fu.saveFileOnAndroid(_fileName, _fileExtension, dataBytes);
          // Updating the file names list: saveFileOnAndroid
          await du.getStoredFileNamesOnMobile();
          if (sessionDataDebug) pu.printd("Session Data: currentListOfStoredFileNames (after retrieval): ${du.currentListOfStoredFileNames}");
     
        }
        else {
          // otherwise: using tmp files for testing
          var applicationFolderPath = await rtdu.getApplicationFolderPath();
          filePath = path.join(applicationFolderPath!, "$_fileName$_fileExtension");
          await fu.saveFileUsingWriteAsBytes(filePathWithExtension: filePath, dataBytes: dataBytes);
        }

        if (sessionDataDebug) pu.printd("Session Data: currentListOfStoredFileNames (after retrieval): ${du.currentListOfStoredFileNames}");
      } 
      else if (Platform.isIOS) 
      {
        // Outside of testing
        if (!runningTests) {
          filePath = await fu.saveFileOniOS(_fileName, _fileExtension, dataBytes);
          // Updating the file names list: saveFileOniOS
          await du.getStoredFileNamesOnMobile();
          if (sessionDataDebug) pu.printd("Session Data: currentListOfStoredFileNames (after retrieval): ${du.currentListOfStoredFileNames}");
        }
        else {
          // otherwise: using tmp files for testing
          var applicationFolderPath = await rtdu.getApplicationFolderPath();
          filePath = path.join(applicationFolderPath!, "$_fileName$_fileExtension");
          await fu.saveFileUsingWriteAsBytes(filePathWithExtension: filePath, dataBytes: dataBytes);
        }
      } 
      else 
      {
        // Desktop implementation using FilePicker
        filePath = await FilePicker.platform.saveFile(
          dialogTitle: 'Please enter a file name.',
          fileName: '$_fileName$_fileExtension', 
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
          typeOfDashboardContext: DashboardUtils.gpsContext,
          title: sessionTitle, 
          keywords: _currentKeywords.toList(), 
          formattedDate: formattedDate,
          pathToFile: filePath,
        );

        await rtdu.saveWasSessionDataSaved(wasDataSaved: true, context: DashboardUtils.gpsContext);

        widget.parentCallbackFunctionToRefreshTheGPSPage();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Session saved successfully!")),
        );
      }
    } catch (e) {
      pu.printd("Save Error: $e");
    }
  }

// Method used to load the context analyses metadata
Future<void> _loadCAMetadata() async {
  final data = await du.retrieveAllDashboardMetadata(
    typeOfDashboardContext: DashboardUtils.caContext
  );
  setState(() {
    _caMetadata = List<Map<String, dynamic>>.from(data);
  });
}

void _handleSessionSelection(Map<String, dynamic> session) {
  setState(() {
    _problemTitleController.text = "${session['title']}";
    
    if (session['keywords'] != null) {
      // Creates a NEW list instance instead of .clear() and .addAll()
      // This changes the reference, triggering didUpdateWidget correctly
      _currentKeywords = Set<String>.from(session['keywords']);
    } else {
      _currentKeywords = {};
    }
  });
}

  // Method used to add an idea to the list of ideas
  void _addIdeaToList(String value)
  {
    _ideas.add(value);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
     _loadCAMetadata();
    _getApplicationFolderPathPref();
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
        GPSProblemToSolveDeclaration(
          sessionTitleTfec: _problemTitleController,
          previousSessions: _caMetadata,
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
                      text: addEmoji, color: Colors.white, 
                      // onPressed: (){groupMoods1Key.currentState?.addToIdentifiers();},
                      onPressed: 
                        () => Navigator.of(context).push
                        (
                          MaterialPageRoute<void>(
                            builder: (_) => NewTextListOrLoadingPage
                            (
                              onParticipantsLoadedCallbackFunction:
                              (participants)
                              {
                                // Re-setting previous data
                                _identifiersCol1.clear();
                                _identifiersColors1.clear();
                                _identifiersCol2.clear();
                                _identifiersColors2.clear();

                                setState(() {
                                  for (var index = 0; index < participants.length; index++)
                                  {
                                    if (index%2 == 0) 
                                    {
                                      _identifiersCol1.add(participants[index]);
                                      _identifiersColors1.add(greenShade900);
                                    
                                    }
                                    else 
                                    {
                                      _identifiersCol2.add(participants[index]);
                                      _identifiersColors2.add(greenShade900);
                                    }
                                  }
                                });
                                
                              } ,
                            ) 
                            ),
                        ),

                      screenWidthInInches: screenWidthInInches
                    ),
                    if (_isModificationMode)
                      _buildHeaderButton
                      (
                        text:  _isDeleteMode ? "Edit" : singleDeletionLabel,
                        color: _isDeleteMode ? const Color(0xFFE65100) : const Color(0xFFB71C1C), 
                        onPressed: () =>  setState(() { _isDeleteMode = !_isDeleteMode; _isEditMode = !_isEditMode;}),
                        screenWidthInInches: screenWidthInInches
                      ),
                    // GPSGroupMoods widget (column 1)
                    Expanded
                    (
                      child:GPSGroupMoods
                      (
                        key: _groupMoods1Key,
                        groupMoodsKey1: _groupMoods1Key, groupMoodsKey2: _groupMoods2Key,
                        columnNumber:1, identifiersCol1: _identifiersCol1, identifiersCol2: _identifiersCol2,
                        identifiersColors1: _identifiersColors1, identifiersColors2: _identifiersColors2,
                        isEditMode: _isEditMode, isDeleteMode: _isDeleteMode,
                        gpsProcessCallbackFunctionToRefreshThePage: () async {setState(() {});},
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
                        child: GPSChecklist(),
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
                        child: GPSKeywordsDeclaration
                        (
                          currentKeywords: _currentKeywords,
                          onKeywordsUpdatedCallbackFunction: (newKeywords) 
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
                    // Ideas List component
                    SliverToBoxAdapter(
                      child: GPSIdeasList(ideas: _ideas),
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
                      text: _isModificationMode ? "Done" : editEmoji, 
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
                        text: bulkDeletionLabel, color:  const Color(0xFFB71C1C),
                        onPressed: () {_groupMoods1Key.currentState?.identifiersClearAll();},
                        screenWidthInInches: screenWidthInInches
                      ),
                    // GPSGroupMoods widget (column 2)
                    Expanded
                    (
                      child: GPSGroupMoods
                      (
                        key: _groupMoods2Key,
                        groupMoodsKey1: _groupMoods1Key,groupMoodsKey2: _groupMoods2Key,
                        columnNumber: 2, identifiersCol1: _identifiersCol1, identifiersCol2: _identifiersCol2,
                        identifiersColors1: _identifiersColors1, identifiersColors2: _identifiersColors2,
                        isEditMode: _isEditMode, isDeleteMode: _isDeleteMode,
                        gpsProcessCallbackFunctionToRefreshThePage: () async {setState(() {});},
                      )
                    )
                  ],
                ),
              ),
            ],
          ),
        ),

        // 3. BOTTOM: Full Width Idea Input Field
        const Divider(height: 1),
        GPSNewIdea(newIdeaOnAddedCallbackFunction: _addIdeaToList),
        
        //********** Data saving ************//
        Center
        (
          child:         
            // Button to start the data saving process                     
            _isApplicationFolderPathLoading
            ? const Center(child: CircularProgressIndicator())
            : (Platform.isAndroid || Platform.isIOS) // Unified logic for mobile
                // Defining file name and saving file for mobile platforms 
                ? SessionFileNameMobilePlatforms
                (
                  fileExtension: _fileExtension, 
                  editedFileName: "",
                  onFileNameSubmittedProcessCallbackFunction: (value) => _processFileNameUpdate (value), 
                  parentCallbackFunctionToSaveDataAndMetadata: _saveDataAndMetadata,
                )
                // Saving file for desktop platforms
                : SessionFileNameDesktopPlatforms(parentCallbackFunctionToSaveDataAndMetadata: _saveDataAndMetadata)
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

