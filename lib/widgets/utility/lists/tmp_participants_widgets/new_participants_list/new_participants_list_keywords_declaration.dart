import "package:flutter/material.dart";

import "package:journeyers/app_themes.dart";
import "package:journeyers/debug_constants.dart";
import "package:journeyers/l10n/app_localizations.dart";
import "package:journeyers/pages/group_problem_solving/group_problem_solving_process_widgets/_group_problem_solving_externalized_variables.dart";
import "package:journeyers/utils/generic/dev/utility_classes_import.dart";
import "package:journeyers/utils/generic/sheets_and_overlays/sheets_and_overlays_utils.dart";

/// {@category Utils - Project-specific}
/// {@category Lists}
/// A widget used to declare keywords in a new participants list.
class NewParticipantsListKeywordsDeclaration extends StatefulWidget 
{
  /// The keywords associated to the session data.
  final Set<String> keywordsCurrent;

  /// A callback function called to update the keywords describing the session.
  final ValueChanged<Set<String>> keywordsOnUpdateCallbackFunction;  

  const NewParticipantsListKeywordsDeclaration
  ({
    super.key,
    required this.keywordsCurrent,
    required this.keywordsOnUpdateCallbackFunction
  });


  @override
  State<NewParticipantsListKeywordsDeclaration> createState() => _NewParticipantsListKeywordsDeclarationState();
}

class _NewParticipantsListKeywordsDeclarationState extends State<NewParticipantsListKeywordsDeclaration> 
{
  // Initializes with the passed keywords instead of an empty list
  Set<String>? _keywords;
  final TextEditingController _keywordsTec = .new();
    
  // Method used to add keywords to the _keywords list
  void _keywordAdd(String value, [StateSetter? localSetState]) 
  {
    var trimmedValue = value.trim();
    if (trimmedValue.isNotEmpty && !_keywords!.contains(trimmedValue)) {
      // Updates the underlying data
      setState(() {
        _keywords!.add(trimmedValue);
        _keywordsTec.clear();
      });
      
      // Redraws the Dialog/Overlay
      if (localSetState != null) {
        localSetState(() {});
      }
      
      widget.keywordsOnUpdateCallbackFunction(_keywords!);
    }
  }

  @override
  void initState() {
    super.initState();
            
    if (widgetSequenceDebug) pu.printdLine();
    if (widgetSequenceDebug) pu.printd("NewParticipantsKeywordsDeclaration");

    _keywords = Set.from(widget.keywordsCurrent); // Syncs at start
  }

  @override
  void didUpdateWidget(NewParticipantsListKeywordsDeclaration oldWidget) {
    if (widgetSequenceDebug) pu.printdLine();
    if (widgetSequenceDebug) pu.printd("NewParticipantsKeywordsDeclaration: didUpdateWidget");

    super.didUpdateWidget(oldWidget);
    // Checks if the pointer or the content of the list has changed
    if (widget.keywordsCurrent != oldWidget.keywordsCurrent) {
      setState(() {
        // Creates a fresh copy from the new parent data
        _keywords = Set<String>.from(widget.keywordsCurrent);
      });
    }
  }

  @override
  void dispose()
  {
    _keywordsTec.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showAddToSetOverlay
                    (
                      context: context, 
                      appBarBackgroundColor: white,
                      appBarForegroundColor: black,
                      overlayTitle: AppLocalizations.of(context)?.text_lists_new_list_keywords_title ?? "Issue with the title of the new list page keywords overlay.",
                      overlayTitleStyle: newParticipantsListKeywordsOverlayTitleStyle, 
                      overlayCloseIconButtonToolTip: AppLocalizations.of(context)?.l10n_keywords_overlay_close_button_tooltip ?? "Issue with the l10n for the keywords overlay close button tooltip",                  
                      inputChipDeleteIconColor: appBarWhite,
                      textEditingControllerKey: const Key("kwsFieldNewList"), 
                      textEditingController: _keywordsTec, 
                      textFieldStyle: analysisTextFieldStyle, 
                      textFieldHintText: AppLocalizations.of(context)?.l10n_keywords_entry_text_field_hint ?? "Issue with the l10n for the keywords entry text field hint.", 
                      textFieldHintStyle: analysisTextFieldHintStyle, 
                      onSubmittedCallbackFunction: (value, setLocalState) => _keywordAdd(value, setLocalState), 
                      setToUpdate: _keywords!, 
                      onDeletedCallbackFunction: 
                        (tag, setLocalState) 
                        {
                          setState( () {_keywords!.remove(tag);});
                          setLocalState(() {});
                          widget.keywordsOnUpdateCallbackFunction(_keywords!);
                        }, 
                    ),
      child: Container(        
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.only(right: 15),
              child: Icon(Icons.style_rounded),
            ),
            Center(
              child: Text
              (
                AppLocalizations.of(context)?.l10n_keywords ?? "Issue with the l10n for 'Keywords'", 
                style: gpsKeywordsTitleStyle
              ),
            )
          ],
        ),
      ),
    );
  }

}