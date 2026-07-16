import "dart:convert";
import "dart:io";
import "dart:typed_data";

import "package:flutter/material.dart";

import "package:file_picker/file_picker.dart";
import "package:intl/intl.dart";
import "package:path/path.dart" as path;

import "package:share_plus/share_plus.dart";

import "package:journeyers/app_themes.dart";
import "package:journeyers/debug_constants.dart";
import "package:journeyers/pages/context_analysis/context_analysis_preview_widget.dart";
import "package:journeyers/pages/group_problem_solving/group_problem_solving_preview_widget.dart";
import "package:journeyers/utils/generic/dashboard/dashboard_utils.dart";
import "package:journeyers/utils/generic/dev/type_defs.dart";
import "package:journeyers/utils/generic/dev/test_utils.dart";
import "package:journeyers/utils/generic/dev/utility_classes_import.dart";
import "package:journeyers/widgets/utility/dashboard/dashboard_widgets/dashboard_const_strings.dart";
import "package:journeyers/widgets/utility/dashboard/dashboard_helper_functions.dart";

// Used to store a temporary file path used for session data sharing.
String tmpFilePath = "";

/// {@category Utility widgets}
/// {@category Dashboard}
/// A widget handling a session data.
class SessionsListItem extends StatefulWidget 
{
  /// The context of the dashboard (context analyses or group problem-solving sessions).
  final String dashboardContext;

  /// The session metadata.
  final Map<String, dynamic> sessionMetadata;

  /// The index within the list.
  final int sessionDataIndex;

  /// Boolean to indicate if the checkbox is checked.
  final bool isChecked;

  /// A callback function called when the checkbox is checked/unchecked.
  final ValueChanged<bool?> onCheckboxChangedCallbackFunction;

  /// A callback function called when the title is updated.
  final VoidCallback onEditTitleCallbackFunction;

  // A callback function called when editing the session data.
  final VoidCallback onEditPressedCallbackFunction;

  /// A callback function called when session data is retrieved before edition.
  final OnRetrievedSessionDataBeforeEditionCallbackFunctionType onRetrievedSessionDataBeforeEditionCallbackFunction;

  /// A callback function called when the keywords are updated.
  final FunctionSetStringAndString onKeywordsUpdatedCallbackFunction;

  /// A callback function called when the delete icon is interacted with.
  final VoidCallback onDeleteCallbackFunction;

  const SessionsListItem({
    super.key,
    required this.sessionMetadata,
    required this.sessionDataIndex,
    required this.isChecked,
    required this.dashboardContext,
    required this.onCheckboxChangedCallbackFunction,
    required this.onEditTitleCallbackFunction,
    required this.onEditPressedCallbackFunction,
    required this.onRetrievedSessionDataBeforeEditionCallbackFunction,
    required this.onKeywordsUpdatedCallbackFunction,
    required this.onDeleteCallbackFunction,
  });

  @override
  State<SessionsListItem> createState() => _SessionsListItemState();
}

class _SessionsListItemState extends State<SessionsListItem> 
{
  final TextEditingController _kwsEditTfec = .new();

  // Data related to deleting ideas from the overlay
  // List of ideas present before deletion
  List<String> _ideasList = [];
  List<String> _ideasListBeforeEditionCopy = [];

  bool _previewEditMode = false;
 

  // To clean
  // Method used to update the keywords
  void _onKeywordsUpdated(String? filePath) async
  {
    // Splitting string into list, trimming whitespaces, and removing empty entries
    final Set<String> updatedKeywords = _kwsEditTfec.text
        .split(",")
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toSet();

    if (sessionDataDebug) pu.printd("Session Data: ElevatedButton: onPressed: updatedKeywords: $updatedKeywords");
    // Calling the parent callback function for state update
    await widget.onKeywordsUpdatedCallbackFunction(filePath: filePath, updatedKeywords: updatedKeywords);

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  // Method used to update the temporary file path used for session data sharing
  void _updateTmpFilePath(String tmpFilePathFromPreview)
  {    
    tmpFilePath = tmpFilePathFromPreview;

    if (sessionDataDebug) pu.printd("Session Data: SessionsListItem: updateTmpFilePath: tmpFilePath: $tmpFilePathFromPreview");
  }

  // Method used to save data and metadata
  Future<void> _saveUpdatedDataAndMetadata
({
  required String title, required List<String> keywords, required List<String> updatedIdeas,  
  required String fileNameWithoutExtension, required String fileExtension,
  required String originalFilePath,
}) async 
{
  if (updatedIdeas.isEmpty) 
  {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("No ideas to save!")),
    );
    return;
  }

  var now = DateTime.now();
  var formatter = DateFormat("MMMM dd, yyyy").add_jm();
  var formattedDate = formatter.format(now);
  String fileContent = "Group Problem Solving Ideas\n";
  fileContent += "$title\n";
  fileContent += "Date: $formattedDate\n";
  fileContent += "----------------------------\n";
  for (var i = 0; i < updatedIdeas.length; i++) {
    fileContent += "${i + 1}. ${updatedIdeas[i]}\n";
  }
  
  Uint8List dataBytes = Uint8List.fromList(utf8.encode(fileContent));
  String? filePath;

  try {
    String? folderPath = await rtdu.getApplicationFolderPath();
    filePath = "$folderPath/${fileNameWithoutExtension}.${fileExtension}";

    if (Platform.isAndroid) 
    {
      if (!isInTestEnvironment) {
        await fu.deleteFile(filePath);
        await du.deleteSpecificSessionMetadata(typeOfDashboardContext: widget.dashboardContext, filePathRelatedToDataToDelete: originalFilePath);
        filePath = await fu.saveFileOnAndroid(fileNameWithoutExtension, fileExtension, dataBytes);
        await du.getStoredFileNamesOnMobile();
        if (sessionDataDebug) pu.printd("Session Data: currentListOfStoredFileNames (after retrieval): ${du.currentListOfStoredFileNames}");
      }
      else {
        var applicationFolderPath = await rtdu.getApplicationFolderPath();
        filePath = path.join(applicationFolderPath!, "${fileNameWithoutExtension}.${fileExtension}");
        await fu.deleteFile(filePath);
        await du.deleteSpecificSessionMetadata(typeOfDashboardContext: widget.dashboardContext, filePathRelatedToDataToDelete: originalFilePath);
        await fu.saveFileUsingWriteAsBytes(filePathWithExtension: filePath, dataBytes: dataBytes);
      }

      if (sessionDataDebug) pu.printd("Session Data: currentListOfStoredFileNames (after retrieval): ${du.currentListOfStoredFileNames}");
    } 
    else if (Platform.isIOS) 
    {
      if (!isInTestEnvironment) {
        await fu.deleteFile(filePath);
        await du.deleteSpecificSessionMetadata(typeOfDashboardContext: widget.dashboardContext, filePathRelatedToDataToDelete: originalFilePath);
        filePath = await fu.saveFileOniOS(fileNameWithoutExtension, fileExtension, dataBytes);
        await du.getStoredFileNamesOnMobile();
        if (sessionDataDebug) pu.printd("Session Data: currentListOfStoredFileNames (after retrieval): ${du.currentListOfStoredFileNames}");
      }
      else {
        var applicationFolderPath = await rtdu.getApplicationFolderPath();
        filePath = path.join(applicationFolderPath!, "${fileNameWithoutExtension}.${fileExtension}");
        await fu.deleteFile(filePath);
        await du.deleteSpecificSessionMetadata(typeOfDashboardContext: widget.dashboardContext, filePathRelatedToDataToDelete: originalFilePath);
        await fu.saveFileUsingWriteAsBytes(filePathWithExtension: filePath, dataBytes: dataBytes);
      }
    } 
    else 
    {
      await du.deleteSpecificSessionMetadata(typeOfDashboardContext: widget.dashboardContext, filePathRelatedToDataToDelete: originalFilePath);
      filePath = await FilePicker.saveFile(
        dialogTitle: "Please enter a file name.",
        fileName: "${fileNameWithoutExtension}.${fileExtension}", 
        bytes: dataBytes,
        type: FileType.custom,
        allowedExtensions: ["txt"],
      );       
    }

    if (filePath != null) 
    {
      var now = DateTime.now();
      var formatter = DateFormat("MMMM dd, yyyy").add_jm();
      var formattedDate = formatter.format(now);   
      await du.saveDashboardMetadata
      (
        typeOfDashboardContext: DashboardUtils.gpsContext,
        title: title, 
        keywords: keywords, 
        formattedDate: formattedDate,
        filePath: filePath,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Session saved successfully!")),
      );
    }
  } catch (e) {
    pu.printd("Save Error: $e");
  }
}

  @override void dispose() 
  {
    _kwsEditTfec.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant SessionsListItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widgetSequenceDebug) pu.printdLine();
    if (widgetSequenceDebug) pu.printd("SessionsListItem: didUpdateWidget");
  }

  @override
  void initState() {
    super.initState();
                                                    
    if (widgetSequenceDebug) pu.printdLine();
    if (widgetSequenceDebug) pu.printd("SessionsListItem");
  }
  
  @override
  Widget build(BuildContext context) 
  {
    // Gets the title
    final String sessionTitle = widget.sessionMetadata[DashboardUtils.keyTitle];
    // Modifies the title according to context (ca or gps)
    final String displayTitle = (widget.dashboardContext == DashboardUtils.gpsContext)
        ? "$sessionTitle$gpsTitleSuffix"
        : sessionTitle;

    // Sorting keywords for display
    final Set<String> sortedKeywords = 
    Set<String>.from(widget.sessionMetadata[DashboardUtils.keyKeywords])
    ..toList().sort((a, b) 
    {
        int comparison = a.toLowerCase().compareTo(b.toLowerCase());
        return comparison == 0 ? b.compareTo(a) : comparison;
    });

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Checkbox used for bulk deletion
                Checkbox(
                  key: Key("checkbox-${widget.sessionDataIndex}"),
                  value: widget.isChecked,
                  onChanged: widget.onCheckboxChangedCallbackFunction,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        children: [
                          // For the edition of the title
                          GestureDetector(
                            onTap: widget.onEditTitleCallbackFunction,
                            child: Text(
                              displayTitle,
                              key: Key("session-title-${widget.sessionDataIndex}"),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                          // The session date
                          Text(
                            "(${widget.sessionMetadata[DashboardUtils.keyDate]})",
                            key: Key("session-date-${widget.sessionDataIndex}"),
                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // For the edition of the keywords
                      GestureDetector(
                        onTap: () => _showKeywordsEditSheet
                        (
                          context: context,
                          dashboardContext: widget.dashboardContext,                          
                          currentKeywords: widget.sessionMetadata[DashboardUtils.keyKeywords],
                          filePath: widget.sessionMetadata[DashboardUtils.keyFilePath],
                          kwsEditController: _kwsEditTfec,
                          onKeywordsUpdatedCallbackFunction: widget.onKeywordsUpdatedCallbackFunction,
                          onKeywordsUpdated: _onKeywordsUpdated
                          ),
                        child: Text(
                          "Keywords: ${sortedKeywords.join(", ")}",
                          key: Key("session-keywords-${widget.sessionDataIndex}"),
                          style: TextStyle(color: Colors.grey[700], fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Wrap(
                  spacing: 4,
                  children: [
                    // To preview the session data
                    IconButton(
                      icon: const Icon(Icons.find_in_page_rounded),
                      onPressed: () => _showPreviewOverlay(context, widget.dashboardContext, widget.sessionMetadata, _updateTmpFilePath),
                      tooltip: previewTooltipLabel,
                    ),
                    // To edit the session file data                    
                    IconButton(
                      icon: const Icon(Icons.edit_document),
                      onPressed: widget.onEditPressedCallbackFunction,                      
                      tooltip: editFromDashboardItemTooltipLabel,
                    ),
                    // To edit the keywords
                    IconButton(
                      icon: const Icon(Icons.style_rounded),
                      onPressed:  () => _showKeywordsEditSheet
                      (
                        context: context,
                        dashboardContext: widget.dashboardContext,
                        currentKeywords: widget.sessionMetadata[DashboardUtils.keyKeywords],
                        filePath: widget.sessionMetadata[DashboardUtils.keyFilePath],
                        kwsEditController: _kwsEditTfec,
                        onKeywordsUpdatedCallbackFunction: widget.onKeywordsUpdatedCallbackFunction,
                        onKeywordsUpdated: _onKeywordsUpdated
                      ),
                      tooltip: keywordsTooltipLabel,
                    ),
                  ],
                ),
                // To delete session metadata and file
                IconButton(
                  key: Key("session-delete-${widget.sessionDataIndex}"),
                  icon: const Icon(Icons.delete_rounded),
                  onPressed: widget.onDeleteCallbackFunction,
                  tooltip: deleteTooltipLabel,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

// Method used to display an overlay with a session data preview. 
void _showPreviewOverlay(BuildContext context, String dashboardContext, Map<String,dynamic> sessionMetadata, ValueChanged<String> updateTmpFilePath) async
{
  String title = sessionMetadata[DashboardUtils.keyTitle];
  await showGeneralDialog
  (
    context: context,
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, anim1, anim2) 
    {
      // Moving StatefulBuilder to wrap the Scaffold so setLocalState is available everywhere inside
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setLocalState) 
        { 
          return Scaffold
          (
            appBar: AppBar
            (
              centerTitle: true, 
              title: 
              Text
              (
                textAlign: TextAlign.center, maxLines: 20, overflow: TextOverflow.visible, 
                softWrap: true, title, style: previewTitleStyle
              ),
              // Left side: Edit and Share Buttons
              leadingWidth: 100,
              leading: Row(
                children: [
                  IconButton
                  (
                    tooltip: editFromDashboardItemTooltipLabel,
                    icon: const Icon(Icons.edit),
                    color: appBarWhite,
                    onPressed: () async
                    {    

                      _previewEditMode = true;

                      if (widget.dashboardContext == DashboardUtils.caContext) 
                      {                
                        // Starts the session data editing
                        retrieveCASessionData
                        (
                          dashboardContext: DashboardUtils.caContext,
                          filePathWhenEdition: sessionMetadata[DashboardUtils.keyFilePath], 
                          onRetrievedCASessionDataBeforeEditionCallbackFunction: widget.onRetrievedSessionDataBeforeEditionCallbackFunction
                        );
                        // Closes the modal preview overlay
                        Navigator.of(context).pop();
                      }
                      else if (widget.dashboardContext == DashboardUtils.gpsContext) 
                      {
                        retrieveGPSSessionData
                        (
                          dashboardContext: dashboardContext, 
                          filePathWhenEdition: sessionMetadata[DashboardUtils.keyFilePath], 
                          onRetrievedGPSSessionDataBeforeEditionCallbackFunction: widget.onRetrievedSessionDataBeforeEditionCallbackFunction
                        );

                        // Closes the modal preview overlay
                        Navigator.of(context).pop();
                      }
                      else 
                      {
                        throw Exception("Unexpected context: ${widget.dashboardContext}");
                      }
                    },
                    
                  ),
                  IconButton(
                    icon: const Icon(Icons.share),
                    color: appBarWhite,
                    onPressed: () 
                    { _shareSession(context, sessionMetadata, tmpFilePath); },
                    tooltip: "Share session",
                  ),
                ],
              ),
              
              // Right side: Close Button
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  color: appBarWhite,
                  onPressed: () async
                  {
                    if (editDebug) pu.printd("Editing: SessionsListItem: _showPreviewOverlay: _ideasList: $_ideasList");
                    if (editDebug) pu.printd("Editing: SessionsListItem: _showPreviewOverlay: _ideasListBeforeEditionCopy: $_ideasListBeforeEditionCopy");
                    if (editDebug) pu.printd("Editing: SessionsListItem: _showPreviewOverlay: previewEditMode: $_previewEditMode");
                    
                    if (_previewEditMode  && !cu.areListsOfEqualSortedContent(_ideasList, _ideasListBeforeEditionCopy) )
                    {
                        if (editDebug) pu.printd("Editing: SessionsListItem: _showPreviewOverlay: List edited: saving data and metadata");

                        String filePath = sessionMetadata[DashboardUtils.keyFilePath];
                        String fileName = path.basename(filePath);
                        String fileNameWithoutExtension = fileName.split(".").first;
                        var keywords = sessionMetadata[DashboardUtils.keyKeywords].cast<String>();

                        if (editDebug) pu.printd("Editing: SessionsListItem: _showPreviewOverlay: fileNameWithoutExtension: $fileNameWithoutExtension");
                        if (editDebug) pu.printd("Editing: SessionsListItem: _showPreviewOverlay: sessionMetadata[DashboardUtils.keyKeywords]: ${sessionMetadata[DashboardUtils.keyKeywords]}");
                        
                        await _saveUpdatedDataAndMetadata
                        (title: title, keywords: keywords, updatedIdeas: _ideasList,
                        fileNameWithoutExtension: fileNameWithoutExtension, fileExtension: "txt",
                        originalFilePath: filePath);

                        _ideasListBeforeEditionCopy = List.from(_ideasList);
                        _previewEditMode = false;
                    }

                    if (!context.mounted) return;
                    Navigator.of(context).pop();
                  },
                  tooltip: "Close preview",
                ),
              ],
            ),
            body: SafeArea
            (
              child: SingleChildScrollView(
                key: Key("context-analysis-preview-scrollview"),
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: 
                  (sessionMetadata[DashboardUtils.keyFilePath] != null)
                  ?
                    (dashboardContext == DashboardUtils.caContext)
                    ? CAPreview(
                        pathToStoredData: sessionMetadata[DashboardUtils.keyFilePath], 
                        caPreviewCallbackFunctionToUpdateTmpFilePath: updateTmpFilePath,
                      )
                    : GPSPreview(
                        gpsPreviewPathToStoredData: sessionMetadata[DashboardUtils.keyFilePath], 
                        gpsPreviewIdeasStored: _ideasList,                        
                        gpsPreviewCallbackFunctionToUpdateTmpFilePath: updateTmpFilePath,
                      )
                  :
                    const Text("Null file path"),
                ),
              ),
            )
          );
        }
      );
    }
  );
}
 
}

// TODO: code to move
// Triggers the platform"s native share sheet for a session.
// Shares both the raw session file (CSV / TXT) and some metadata.
Future<void> _shareSession(
  BuildContext context,
  Map<String, dynamic> sessionMetadata,
  String tmpFilePath
) async
{
  final String title     = sessionMetadata[DashboardUtils.keyTitle]    ?? "";
  final String date      = sessionMetadata[DashboardUtils.keyDate]     ?? "";
  final List<dynamic> keywords = sessionMetadata[DashboardUtils.keyKeywords] ?? [];

  final String shareText =
      "Session: $title\n"
      "Date: $date\n"
      "Keywords: ${keywords.join(", ")}";

  final ShareParams params = ShareParams(
          subject: title,
          text: shareText,
          files: [XFile(tmpFilePath)],
        );

  await SharePlus.instance.share(params);
}

// todo: to move/clean
void _showKeywordsEditSheet
({
  required BuildContext context, required String dashboardContext, 
  required List<dynamic> currentKeywords, required String? filePath, 
  required TextEditingController kwsEditController,
  required FunctionSetStringAndString onKeywordsUpdatedCallbackFunction,
  required ValueChanged<String?> onKeywordsUpdated

}) {
  // Converting list to a comma-separated string for editing
  kwsEditController.text = currentKeywords.join(", "); 
  
  showModalBottomSheet
  (
    context: context,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    isScrollControlled: true,
    builder: (context) => Padding
    (
      padding: EdgeInsets.only
      (
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20, right: 20, top: 20,
      ),
      child: Column
      (
        mainAxisSize: MainAxisSize.min,
        children: 
        [
          TextField
          (
            key: const Key("kwsDashboardEditField"),
            controller: kwsEditController,
            autofocus: true,
            decoration: const InputDecoration
            (
              labelText: keywordsTextFieldLabel, 
              labelStyle: TextStyle(color: Colors.black),
              hintText: "Please enter your keywords.",
            ),
            onSubmitted: (_) async => onKeywordsUpdated(filePath)
          ),       
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () async =>  onKeywordsUpdated(filePath),
            child: const Text("Save", style: TextStyle(color: Colors.black)),
          ),
          const SizedBox(height: 20),
        ],
      ),
    ),
  );

}

