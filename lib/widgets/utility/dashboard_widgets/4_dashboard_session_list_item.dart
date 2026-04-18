import 'package:flutter/material.dart';

import 'package:journeyers/utils/generic/dashboard/dashboard_utils.dart';

/// {@category Utility widgets}
/// {@category Dashboard}
/// A widget handling a session data.
class SessionsListItem extends StatelessWidget {
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
  final VoidCallback onEditKeywords;

  /// A callback function called when the preview is requested.
  final VoidCallback onPreview;

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
    required this.onPreview,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) 
  {
    // Gets the title
    final String sessionTitle = sessionMetadata[DashboardUtils.keyTitle];
    // Modifies the title according to context (ca or gps)
    final String displayTitle = (dashboardContext == DashboardUtils.gpsContext)
        ? "$sessionTitle (gps)"
        : sessionTitle;

    // Sorting keywords for display
    final Set<String> sortedKeywords = 
    Set<String>.from(sessionMetadata[DashboardUtils.keyKeywords])
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
                  key: ValueKey('checkbox-$index'),
                  value: isChecked,
                  onChanged: onCheckboxChanged,
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
                            onTap: onEditTitle,
                            child: Text(
                              displayTitle,
                              key: ValueKey('session-title-$index'),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                          // The session date
                          Text(
                            "(${sessionMetadata[DashboardUtils.keyDate]})",
                            key: ValueKey('session-date-$index'),
                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // For the edition of the keywords
                      GestureDetector(
                        onTap: onEditKeywords,
                        child: Text(
                          "Keywords: ${sortedKeywords.join(', ')}",
                          key: ValueKey('session-keywords-$index'),
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
                      onPressed: onPreview,
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
                      onPressed: onEditKeywords,
                      tooltip: "Edit Keywords",
                    ),
                  ],
                ),
                // To delete session metadata and file
                IconButton(
                  key: ValueKey('session-delete-$index'),
                  icon: const Icon(Icons.delete_rounded),
                  onPressed: onDelete,
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