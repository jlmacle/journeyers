import 'package:flutter/material.dart';
import 'package:journeyers/app_themes.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_form_widgets/context_analysis_preview_widget.dart';
import 'package:journeyers/pages/group_problem_solving/group_problem_solving_widgets/group_problem_solving_preview_widget.dart';
import 'package:journeyers/utils/generic/dashboard/dashboard_utils.dart';
import 'package:journeyers/utils/generic/dev/type_defs.dart';

/// {@category Utility widgets}
/// {@category Dashboard}
/// A widget handling a session data.
class SessionsListItem extends StatefulWidget 
{
  /// The session metadata.
  final Map<String, dynamic> sessionMetadata;

  /// The index within the list.
  final int index;

  /// Bool to indicate if the checkbox is checked.
  final bool isChecked;

  /// The context of the dashboard.
  final String dashboardContext;

  /// A callback function called when the checkbox is checked.
  final ValueChanged<bool?> onCheckboxChanged;

  /// A callback function called when the title is being edited.
  final VoidCallback onEditTitle;

  /// A callback function called when the keywords are being edited.
  final FunctionSetStringAndString onEditKeywords;

  /// A callback function called when the delete icon is interacted with.
  final VoidCallback onDelete;

  const SessionsListItem({
    super.key,
    required this.sessionMetadata,
    required this.index,
    required this.isChecked,
    required this.dashboardContext,
    required this.onCheckboxChanged,
    required this.onEditTitle,
    required this.onEditKeywords,
    required this.onDelete,
  });

  @override
  State<SessionsListItem> createState() => _SessionsListItemState();
}

class _SessionsListItemState extends State<SessionsListItem> 
{
  TextEditingController kwsEditController = .new();
  
  @override void dispose() 
  {
    kwsEditController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) 
  {
    // Gets the title
    final String sessionTitle = widget.sessionMetadata[DashboardUtils.keyTitle];
    // Modifies the title according to context (ca or gps)
    final String displayTitle = (widget.dashboardContext == DashboardUtils.gpsContext)
        ? "$sessionTitle (gps)"
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
                  key: ValueKey('checkbox-${widget.index}'),
                  value: widget.isChecked,
                  onChanged: widget.onCheckboxChanged,
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
                            onTap: widget.onEditTitle,
                            child: Text(
                              displayTitle,
                              key: ValueKey('session-title-${widget.index}'),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                          // The session date
                          Text(
                            "(${widget.sessionMetadata[DashboardUtils.keyDate]})",
                            key: ValueKey('session-date-${widget.index}'),
                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // For the edition of the keywords
                      GestureDetector(
                        onTap: () => _showKeywordsEditSheet(
                          context: context,
                          dashboardContext: widget.dashboardContext,                          
                          currentKeywords: widget.sessionMetadata[DashboardUtils.keyKeywords],
                          filePath: widget.sessionMetadata[DashboardUtils.keyFilePath],
                          onEditKeywords: widget.onEditKeywords,
                          kwsEditController: kwsEditController,
                          onKeywordsUpdated: widget.onEditKeywords
                          ),
                        child: Text(
                          "Keywords: ${sortedKeywords.join(', ')}",
                          key: ValueKey('session-keywords-${widget.index}'),
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
                      onPressed: () => _showPreviewOverlay(context, widget.dashboardContext, widget.sessionMetadata),
                      tooltip: "Preview",
                    ),
                    // To edit the session file data
                    IconButton(
                      icon: const Icon(Icons.edit_document),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Edit not yet implemented.')),
                        );
                      },
                      tooltip: "Edit Document",
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
                        onEditKeywords: widget.onEditKeywords,
                        kwsEditController: kwsEditController,
                        onKeywordsUpdated: widget.onEditKeywords 
                      ),
                      tooltip: "Edit Keywords",
                    ),
                  ],
                ),
                // To delete session metadata and file
                IconButton(
                  key: ValueKey('session-delete-${widget.index}'),
                  icon: const Icon(Icons.delete_rounded),
                  onPressed: widget.onDelete,
                  tooltip: "Delete",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


// Method used to display an overlay with a session data preview. 
void _showPreviewOverlay(BuildContext context, String dashboardContext, Map<String,dynamic> sessionMetadata) 
{
  String title = sessionMetadata[DashboardUtils.keyTitle];
  
  showGeneralDialog
  (
    context: context,
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, anim1, anim2) 
    {
      return Scaffold
      (
        appBar:AppBar
        (
          centerTitle: true, 
          title: 
          Text
          (
            textAlign: TextAlign.center, maxLines:20, overflow: TextOverflow.visible, 
            softWrap:true, title, style: previewTitleStyle
          ),
          // Left side: Edit Button
          leadingWidth: 100,
          leading: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                color: appBarWhite,
                onPressed: () {ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Edit not yet implemented.')));},
                tooltip: "Edit session",
              ),
              IconButton(
                icon: const Icon(Icons.share),
                color: appBarWhite,
                onPressed: () {ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Share not yet implemented.')));},
                tooltip: "Share session",
              ),
            ],
          ),
          
          // Right side: Close Button
          actions: [
            IconButton(
              icon: const Icon(Icons.close),
              color: appBarWhite,
              onPressed: () => Navigator.of(context).pop(),
              tooltip: "Close preview",
            ),
          ],
        ),
        body: SafeArea(
          // SingleChildScrollView ensures the content is scrollable 
          // regardless of the widget's internal structure
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: 
              (sessionMetadata[DashboardUtils.keyFilePath] != null)
              ?
                (dashboardContext == DashboardUtils.caContext)
                ? CAPreviewWidget(pathToStoredData: sessionMetadata[DashboardUtils.keyFilePath])
                : GPSPreviewWidget(pathToStoredData: sessionMetadata[DashboardUtils.keyFilePath])
              :
                const Text('Null file path'),
            ),
          ),
        )
      );
    }
  );
}

void _showKeywordsEditSheet
({
  required BuildContext context, required String dashboardContext, 
  required List<dynamic> currentKeywords, required String? filePath, 
  required FunctionSetStringAndString onEditKeywords,
  required TextEditingController kwsEditController,
  required FunctionSetStringAndString onKeywordsUpdated
}) {
  // Converting list to a comma-separated string for editing
  kwsEditController.text = currentKeywords.join(', '); 
  
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
            controller: kwsEditController,
            autofocus: true,
            decoration: const InputDecoration
            (
              labelText: 'Keywords Edition (please separate with commas)', 
              labelStyle: TextStyle(color: Colors.black),
              hintText: 'Please enter your keywords.',
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () async {
              // Splitting string into list, trimming whitespaces, and removing empty entries
              final Set<String> updatedKeywords = kwsEditController.text
                  .split(',')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toSet();

              // Calling the parent callback for state 
              await onKeywordsUpdated(filePath: filePath, updatedKeywords: updatedKeywords);

              if (!context.mounted) return;
              Navigator.of(context).pop();
            },
            child: const Text("Save", style: TextStyle(color: Colors.black)),
          ),
          const SizedBox(height: 20),
        ],
      ),
    ),
  );

}

