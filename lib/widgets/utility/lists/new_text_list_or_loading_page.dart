import 'package:flutter/material.dart';

import 'package:journeyers/app_themes.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_process_widgets/dto_ca_form.dart';
import 'package:journeyers/widgets/utility/lists/list_dashboard.dart';
import 'package:journeyers/widgets/utility/lists/new_text_list_externalized_strings.dart';
import 'package:journeyers/widgets/utility/lists/new_text_list_or_loading_page_externalized_strings.dart';
import 'package:journeyers/widgets/utility/lists/new_text_list.dart';


/// ParticipantsGroupDeclaration offers two choices:
///   • Loading a list of previous groups of participants
///   • Adding a new group of participants
class NewTextListOrLoadingPage extends StatelessWidget 
{
  /// A callback function called when the participants list is loaded.
  final ValueChanged<List<String>> onParticipantsLoadedCallbackFunction;

  const NewTextListOrLoadingPage
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
                  participantsListsTitle,
                  textAlign: TextAlign.center,
                  style: appTheme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  participantsListsSubTitle,
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
                      builder: (_) => ListDashboard
                                      (
                                        dashboardContext: '', 
                                        onAllSessionFilesDeletedContextPageCallbackFunction:  () {  }, 
                                        onEditSessionDataCallbackFunction: 
                                        ({
                                          required String dashboardContext,
                                          required bool isSessionDataBeingEdited, 
                                          required String titleWhenEdition, 
                                          required Set<String> keywordsWhenEdition,
                                          required Object dtoForEdition, 
                                          required String fileNameWithoutExtensionWhenEdition
                                        }) {}, 
                                        onParticipantsLoadedCallbackFunction: onParticipantsLoadedCallbackFunction,
                                        dashboardFilteringByKeywordsKey: null,
                                    ),
                      //  builder: (_) => TextListsDisplay
                      //                 (
                      //               ),
                    ),
                  ),
                  icon: const Icon(Icons.folder_open_outlined),
                  label: const Text(loadingAListOptionLabel, textAlign: TextAlign.center),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Option 2. Addition of a participants group ─────────────────────────────────────────
                FilledButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => NewTextList
                                        (
                                          labelHintText: listLabelHintText,
                                          placeholderList: listPlaceholder,
                                          placeholderInvitationToEnterText: invitationToEnterTextPlaceholder,
                                          themeData: Theme.of(context),
                                          onParticipantsLoadedCallbackFunction: onParticipantsLoadedCallbackFunction,
                                        ),
                    ),
                  ),
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text(newParticipantsGroupOptionLabel, textAlign: TextAlign.center),
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
