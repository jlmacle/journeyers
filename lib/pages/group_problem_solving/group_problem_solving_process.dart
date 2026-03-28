import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'package:journeyers/app_themes.dart';
import 'package:journeyers/core/utils/dashboard/dashboard_utils.dart';
import 'package:journeyers/core/utils/dev/placeholder_functions.dart';
import 'package:journeyers/core/utils/files/files_utils.dart';
import 'package:journeyers/core/utils/printing_and_logging/debug_constants.dart';
import 'package:journeyers/core/utils/printing_and_logging/print_utils.dart';
import 'package:journeyers/core/utils/settings_and_preferences/user_preferences_utils.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_form_page.dart';
import 'package:journeyers/widgets/utility/file_name_desktop_platforms.dart';
import 'package:journeyers/widgets/utility/file_name_mobile_platforms.dart';
import 'package:journeyers/pages/group_problem_solving/group_problem_solving_widgets/checklist.dart';
import 'package:journeyers/pages/group_problem_solving/group_problem_solving_widgets/keywords.dart';
import 'package:journeyers/pages/group_problem_solving/group_problem_solving_widgets/problem_to_solve.dart';
import 'package:journeyers/pages/group_problem_solving/group_problem_solving_widgets/solutions_list.dart';
import 'package:shared_preferences/shared_preferences.dart';

//**************** UTILITY CLASSES ****************//
DashboardUtils du = DashboardUtils();
FileUtils fu = FileUtils();
PrintUtils pu = PrintUtils();
UserPreferencesUtils upu = UserPreferencesUtils(); 

/// {@category Pages}
/// {@category Group Problem Solving}
/// The root page for the group problem-solvings.
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
  FocusNode groupProblemSolvingDashboardFocusNode = FocusNode();
  final TextEditingController _solutionController = TextEditingController();
  
  // List to store the solutions entered by the user
  final List<String> _solutions = [];

  // List to store the keywords entered by the user
  final List<String> _currentKeywords = []; // Add this at the top with other variables

  // TextEditingController for the title
  final TextEditingController _problemTitleController = TextEditingController();

  // List of stakeholders identifiers
  final List<String> _identifiersCol1 = [];
  final List<String> _identifiersCol2 = [];

  // List of stakeholders identifiers' colors
  final List<Color> _identifiersColors1 = [];
  final List<Color> _identifiersColors2 = [];

  // Mode for modifying a stakeholder identifier
  bool _isModificationMode = false;
  // Mode for editing a stakeholder identifier
  bool _isEditMode = false;
  // Mode for deleting a stakeholder identifier
  bool _isDeleteMode = false;
  // Bool used to suggest editing at start of adding identifiers
  bool _hasBeenEdited = false;
  // Bool used to store if a swipe left of right has happened
  bool? wasARightSwipe;
  // Callback function used to update the wasARightSwipe field
  final ValueChanged<bool> onSwipe = placeHolderFunctionBool;

  String fileExtension = ".txt";

  void addToIdentifiers()
  {
    // There should be as much identifiers in the first column,
    // as in the second.

    // Adding to col 1
    int totalIndexes = _identifiersCol1.length+_identifiersCol2.length;
    if (_identifiersCol1.length <= _identifiersCol2.length) 
    {
      _identifiersCol1.add("$totalIndexes");
      // All identifiers are green by default
      _identifiersColors1.add(greenShade900);
    }
    else 
    {
      _identifiersCol2.add("$totalIndexes");
      // All identifiers are green by default
      _identifiersColors2.add(greenShade900);
    }    
  }

  // Function used to add a stakeholder identifier
  void _addIdentifier() => setState(() => addToIdentifiers());
  
  // Function used to remove a stakeholder identifier
  void _removeIdentifier({int? index, int? column}) 
      => setState(() 
                  {
                    if (column==1) {_identifiersCol1.removeAt(index!);}
                    else {_identifiersCol2.removeAt(index!);}
                  });

  // Function used to delete all stakeholder identifiers
  void _clearAllIdentifiers() => setState(() {_identifiersCol1.clear(); _identifiersCol2.clear();});

  // Function used to edit a stakeholder identifier
  void _editIdentifier({int? index, int? column}) {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text("Edit Value"),
          content: TextField(controller: controller, keyboardType: TextInputType.name),
          actions: [
            TextButton(
              onPressed: () {
                if (!_hasBeenEdited) _hasBeenEdited = true;
                setState(() 
                          { 
                            if (column==1) {_identifiersCol1[index!] = controller.text;}
                            else {_identifiersCol2[index!] = controller.text;}
                          });
                Navigator.pop(context);
              },
              child: const Text("Save"),
            )
          ],
        );
      },
    );
  }

  // Method used to update if a swipe happened
  void swipeStateUpdate(bool isSwipeRight)
  {
    setState(() {wasARightSwipe = isSwipeRight;});  
  }

  // Function used to change a stakeholder identifier's color
  void _changeIdentifierColor({required int index, required int column, required Color currentColor}) 
  { 
    final colors = [greenShade900, orange, red];
    int colorIndex = colors.indexOf(currentColor);
    Color? newColor;

    // Finding the right color
    if (wasARightSwipe!)
    {
      // Going up in indexes
        // if index out of range
      if ((colorIndex + 1) == 3) {newColor = greenShade900;}
      else {newColor = colors[colorIndex + 1];}      
    }
    else
      // Left swipe
    {
      // if index out of range
      if (colorIndex == 0) {newColor = red;}
      else {newColor = colors[colorIndex - 1];}
    }

    // Updating the lists of colors
   if (column == 1){_identifiersColors1[index] = newColor;}
   else {_identifiersColors2[index] = newColor;}

    // Updating state data
    setState(() {});
  }

  // Method to handle adding a solution to the list
  void _submitSolution() {
    if (_solutionController.text.trim().isNotEmpty) {
      setState(() {
        // Adding new solutions to the top of the list
        _solutions.insert(0, _solutionController.text.trim());
        _solutionController.clear();
      });
    }
  }

  //**************** PREFERENCES related data and methods ****************/
  bool _isApplicationFolderPathLoading = true;
  String _applicationFolderPath = "";  

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
      _applicationFolderPath = folderPathData ?? "";
    });
  }


  // FILE NAME
  String fileName = "";
  void analysisFileNameUpdate(String textEditingControllerValue)
  {
    fileName = textEditingControllerValue;
  }

  Future<void> saveDataAndMetadata() async {
  if (_solutions.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("No solutions to save!")),
    );
    return;
  }

  String sessionTitle = _problemTitleController.text.trim().isNotEmpty 
      ? _problemTitleController.text.trim() 
      : "Problem Solving Session";

  // Format solutions for the text file
  String fileContent = "Group Problem Solving Solutions\n";
  fileContent += "Date: ${DateTime.now()}\n";
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
    if (filePath != null) {
      await du.saveDashboardMetaData(
        typeOfContextData: DashboardUtils.groupProblemSolvingsContext,
        title: sessionTitle, 
        keywords: _currentKeywords, 
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
  @override
  void initState() {
    super.initState();
    getApplicationFolderPathPref();
  }

  @override
  void dispose() 
  {
    groupProblemSolvingDashboardFocusNode.dispose();
    _solutionController.dispose();
    _problemTitleController.dispose();
    super.dispose();
  }
    
 @override
  Widget build(BuildContext context) {
    return Column(   
      children: [
        // 1. TOP: The problem to be solved (Full Width)
        ProblemToSolve(problemTitleController: _problemTitleController),
        const Divider(),

        // 2. CENTER: The row with identifiers and scrollable content
        Expanded(
          child:
          Row(
            children: 
            [
              // LEFT COLUMN
              Expanded(
                child: ListView
                (
                  children: 
                  [
                    _buildHeaderButton("➕", Colors.white, _addIdentifier),
                    if (_isModificationMode)
                      _buildHeaderButton(_isDeleteMode ? "Edit" : "Clear One",_isDeleteMode ? const Color(0xFFB71C1C) : const Color(0xFFE65100), () =>  setState(() { _isDeleteMode = !_isDeleteMode; _isEditMode = !_isEditMode;})),
                    ..._whichIdentifiersListToBuild(column: 1),
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
                  slivers: 
                  [
                    const SliverToBoxAdapter
                    (
                      child: Padding
                      (
                        padding: EdgeInsets.only(top: 10, bottom: 10),
                        child: Checklist(),
                      )                        
                    ), 
                    const SliverToBoxAdapter
                    (
                      child: Divider()                       
                    ),  
                    SliverToBoxAdapter
                    (
                      child: Padding
                      (
                        padding: const EdgeInsets.only(top: 10, bottom: 10),
                        child: Keywords
                        (
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
                      child: SolutionsList(solutions: _solutions),
                    ),
                  ]
                )
              ),

              // RIGHT COLUMN
              Expanded(
                child: ListView(
                  children: [
                    _buildHeaderButton(
                      _isModificationMode ? "Done" : "✏️", 
                      _isModificationMode ? orangeShade900 : Colors.white, 
                      _isModificationMode 
                        ? () => setState(() {                      
                            _isEditMode = false;
                            _isDeleteMode = false;
                            _isModificationMode = !_isModificationMode;                      
                          })
                        : () => setState(() {_isEditMode = true; _isModificationMode = !_isModificationMode;})
                    ),
                    if (_isModificationMode)
                      _buildHeaderButton("Clear All", const Color(0xFFB71C1C), _clearAllIdentifiers),
                    ..._whichIdentifiersListToBuild(column: 2),
                  ],
                ),
              ),
            ],
          ),
        ),

        // 3. BOTTOM: Full Width Solution Input Field
        const Divider(height: 1),
        Container(
          color: Theme.of(context).cardColor,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _solutionController,
                  decoration: const InputDecoration(
                    hintText: "Please type a solution.",
                    // border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onSubmitted: (_) => _submitSolution(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.send, color: navyBlue),
                onPressed: _submitSolution,
              ),
            ],
          ),
        ),
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
                  ? FileNameMobilePlatforms(fileExtension: fileExtension,  fileNameSubmittedCallbackFunction: analysisFileNameUpdate, parentCallbackFunctionToSaveDataAndMetadata: saveDataAndMetadata)
                  // Saving file for desktop platforms
                  : FileNameDesktopPlatforms(contextAnalysisFormPageKey: widget.key as GlobalKey<ContextAnalysisFormPageState>)
            ],
          ),
        ),
      ]
    );
  }

  // Method used to build the header buttons
  Widget _buildHeaderButton(String text, Color color, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: appBarWhite),
        onPressed: onPressed,
        child: Text(text),
      ),
    );
  }

  List<Widget> buildIdentifiersList
  ({
    required int column, required List<String> identifiers, 
    required List<Color> identifiersColors})
  {
    return identifiers.asMap().entries
        .map((entry) => _IdentifierWidget(
              value: entry.value,
              color: (column==1) ? _identifiersColors1[entry.key] : _identifiersColors2[entry.key],
              isEditMode: _isEditMode,
              isDeleteMode: _isDeleteMode,
              editionHappened: _hasBeenEdited,
              onDelete: () => _removeIdentifier(index: entry.key, column: column),
              onEdit: () => _editIdentifier(index: entry.key, column: column),
              onSwipe: (bool value)
              {
                swipeStateUpdate(value);
                _changeIdentifierColor(index: entry.key, column: column, currentColor: (column==1) ? _identifiersColors1[entry.key] : _identifiersColors2[entry.key]);
              },
            ))
        .toList();
  }

  List<Widget> _whichIdentifiersListToBuild({required int column}) 
  {
    if (column==1)
    {return buildIdentifiersList(column: column, identifiers: _identifiersCol1, identifiersColors: _identifiersColors1);}
    else 
    {return buildIdentifiersList(column: column, identifiers: _identifiersCol2, identifiersColors: _identifiersColors2);}
  }
}

// Class for the stakeholders' identifiers
class _IdentifierWidget extends StatelessWidget 
{
  final String value;
  final Color color;
  final bool isEditMode;
  final bool isDeleteMode;
  final bool editionHappened;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final ValueChanged<bool> onSwipe;

  const _IdentifierWidget
  ({
    required this.value, 
    required this.color,
    required this.isEditMode, 
    required this.isDeleteMode,
    required this.editionHappened,
    required this.onDelete, 
    required this.onEdit,
    required this.onSwipe,
  });

  @override
  Widget build(BuildContext context) {
    return 
    GestureDetector(
    onHorizontalDragEnd: (details) {
      if (details.primaryVelocity! > 0) {
        onSwipe(true);
      } else if (details.primaryVelocity! < 0) {
        onSwipe(false);
      }
    },
    child:    
      Stack(
        alignment: Alignment.center,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 70, height: 70,
            decoration: 
            BoxDecoration
            (
              color: Colors.white, shape: BoxShape.circle, 
              border: Border.all(width: 5, color: color), 
            ),
            child: Center(child: Text(editionHappened ? value : '✏️$value', style: const TextStyle(color: black))),
          ),
          if (isDeleteMode) ...[
            Positioned(
              right: 0, top: 0,
              child: IconButton(icon: const Icon(Icons.delete_rounded, size: 35, color:  Color(0xFFB71C1C)), onPressed: onDelete),
            ),
          ],
          if (isEditMode) ...[
            Positioned(
              left: 20, top: 15,
              child: IconButton(icon: const Icon(Icons.edit, size: 35, color: Colors.transparent), onPressed: onEdit),
            ),
          ]
        ],
      )
    );
  }
}