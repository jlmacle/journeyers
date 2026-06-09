import 'package:flutter/material.dart';

import 'package:journeyers/app_themes.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_process_widgets/dto_ca_form.dart';
import 'models/text_lists_storage_externalized_strings.dart';
import 'new_text_list.dart';
import 'text_lists_display2.dart';
// import 'text_lists_display.dart';


/// ParticipantsGroupDeclaration offers two choices:
///   • Loading a list of previous groups of participants
///   • Adding a new group of participants
class NewTextListOrLoadingPage extends StatelessWidget {
  const NewTextListOrLoadingPage({super.key});

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
                  'Participants list',
                  textAlign: TextAlign.center,
                  style: appTheme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'What would you like to do?',
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
                      builder: (_) => TextListsDisplay
                                      (
                                        dashboardContext: '', 
                                        onAllSessionFilesDeletedContextPageCallbackFunction:  () {  }, 
                                        onEditSessionDataCallbackFunction: ({required bool sessionDataEdition, required DTOCAForm dtoForEdition, required String editedFileNameWithoutExtension, required String editedTitle}) {}, 
                                        dashboardFilteringByKeywordsKey: null,
                                    ),
                      //  builder: (_) => TextListsDisplay
                      //                 (
                      //               ),
                    ),
                  ),
                  icon: const Icon(Icons.folder_open_outlined),
                  label: const Text('To load the list\nof previous groups?', textAlign: TextAlign.center),
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
                                          listLabelHintText: listLabelHintText,
                                          listPlaceholder: listPlaceholder,
                                          invitationToEnterTextPlaceholder: invitationToEnterTextPlaceholder,
                                          themeData: Theme.of(context),
                                        ),
                    ),
                  ),
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('To add a new group?', textAlign: TextAlign.center),
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
