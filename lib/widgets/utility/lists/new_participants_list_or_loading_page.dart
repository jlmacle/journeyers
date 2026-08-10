import "package:flutter/material.dart";

import "package:journeyers/app_themes.dart";
import "package:journeyers/l10n/app_localizations.dart";
import "package:journeyers/widgets/utility/lists/tmp_participants_widgets/new_participants_list/new_participants_list.dart";
import "package:journeyers/widgets/utility/lists/tmp_participants_widgets/participants_dashboard/participants_dashboard.dart";

/// {@category Utils - Project-specific}
/// {@category Lists}
/// ParticipantsGroupDeclaration offers two choices:
///   • Loading a list of previous groups of participants
///   • Adding a new group of participants
class NewParticipantsListOrLoadingPage extends StatelessWidget 
{
  /// A callback function called when the participants list is loaded.
  final ValueChanged<List<String>> onParticipantsLoadedCallbackFunction;

  const NewParticipantsListOrLoadingPage
  ({
    super.key,
    required this.onParticipantsLoadedCallbackFunction   
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar
              (
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                actions: 
                [
                  IconButton
                  (
                    icon: const Icon(Icons.close),
                    tooltip: AppLocalizations.of(context)?.text_lists_new_list_close_tooltip ?? "Issue with the l10n for the 'click to go to the previous page' tooltip.",
                    color: black,
                    onPressed: () => Navigator.of(context).pop()
                  )
                ],
              ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── title ──────────────────────────────────────────────────
                Text(
                  AppLocalizations.of(context)?.text_lists_new_list_or_loading_list_page_title ?? "Issue with the default title for the new list or loading list page.",
                  textAlign: TextAlign.center,
                  style: appTheme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)?.text_lists_new_list_or_loading_list_page_subtitle ?? "Issue with the default subtitle for the new list or loading list page.",
                  textAlign: TextAlign.center,
                  style: appTheme.textTheme.bodyMedium?.copyWith(
                    color: appTheme.colorScheme.onSurface.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 48),

                // ── Option 1. Loading a saved list of participants groups ─────────────────────────────────────────
                FilledButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => ParticipantsListsDashboard
                                      (
                                        dashboardContext: "", 
                                        onAllSessionFilesDeletedContextPageCallbackFunction:  () {  }, 
                                        onRetrievedSessionDataBeforeEditionCallbackFunction: 
                                        ({
                                          required String dashboardContext,
                                          required bool isSessionDataBeingEdited, 
                                          required String titleWhenEdition, 
                                          required Set<String> keywordsWhenEdition,
                                          required Object dtoWhenEdition, 
                                          required String fileNameWithoutExtensionWhenEdition,
                                          required String filePathWhenEdition
                                        }) {}, 
                                        onParticipantsLoadedCallbackFunction: onParticipantsLoadedCallbackFunction,
                                        dashboardFilteringByKeywordsKey: null,
                                    ),
                    ),
                  ),
                  icon: const Icon(Icons.folder_open_outlined),
                  label: Text
                    (
                      AppLocalizations.of(context)?.text_lists_new_list_or_loading_list_group_loading_option ?? "Issue with the loading option text for the new list or loading list page.",
                      textAlign: TextAlign.center
                    ),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Option 2. Addition of a participants group ─────────────────────────────────────────
                FilledButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => NewParticipantsList
                                        (
                                          themeData: Theme.of(context),
                                          onParticipantsListLoadedCallbackFunction: onParticipantsLoadedCallbackFunction,
                                        ),
                    ),
                  ),
                  icon: const Icon(Icons.add_circle_outline),
                  label: Text
                  (
                    AppLocalizations.of(context)?.text_lists_new_list_or_loading_list_new_group_option ?? "Issue with the new group option text for the new list or loading list page.", 
                    textAlign: TextAlign.center
                  ),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
