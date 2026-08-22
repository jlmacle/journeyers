import "package:flutter/material.dart";

import "package:journeyers/app_themes.dart";
import "package:journeyers/debug_constants.dart";
import "package:journeyers/l10n/app_localizations.dart";
import "package:journeyers/l10n/localized_gps_strings.dart";
import "package:journeyers/utils/generic/dev/utility_classes_import.dart";
import "package:journeyers/utils/generic/sheets_and_overlays/sheets_and_overlays_utils.dart";

/// {@category Group problem-solving}
/// A widget used to declare keywords, or to retrieve keywords from previous context analyses.
class GPSKeywordsDeclaration extends StatefulWidget 
{
  /// The keywords value at edition time.
  final Set<String> keywordsWhenEdition;

  /// The keywords associated to the session data.
  final Set<String> currentKeywords;

  /// A callback function called to update the keywords describing the session.
  final ValueChanged<Set<String>> onKeywordsUpdatedCallbackFunction;  

  const GPSKeywordsDeclaration
  ({
    super.key,
    this.keywordsWhenEdition = const {},
    required this.currentKeywords,
    required this.onKeywordsUpdatedCallbackFunction
  });


  @override
  State<GPSKeywordsDeclaration> createState() => _GPSKeywordsDeclarationState();
}

class _GPSKeywordsDeclarationState extends State<GPSKeywordsDeclaration> 
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
      
      widget.onKeywordsUpdatedCallbackFunction(_keywords!);
    }
  }

  @override
  void initState() {
    super.initState();
                
    if (widgetSequenceDebug) pu.printdLine();
    if (widgetSequenceDebug) pu.printd("GPSKeywordsDeclaration");

    if (widget.keywordsWhenEdition.isNotEmpty) 
      { 
        _keywords = widget.keywordsWhenEdition; 
        if (editDebug) pu.printd("Editing: GPSKeywordsDeclaration: initState: widget.keywordsWhenEdition.isNotEmpty: _keywords: $_keywords");
      }
    else
    { 
      _keywords = Set.from(widget.currentKeywords); 
    }
  }

  @override
  void didUpdateWidget(GPSKeywordsDeclaration oldWidget) {
    if (widgetSequenceDebug) pu.printdLine();
    if (widgetSequenceDebug) pu.printd("GPSKeywordsDeclaration: didUpdateWidget");

    super.didUpdateWidget(oldWidget);
    
    // Checks if the pointer or the content of the list has changed
    if (widget.currentKeywords != oldWidget.currentKeywords) {
      setState(() {
        // Creates a fresh copy from the new parent data
        _keywords = Set<String>.from(widget.currentKeywords);
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
    // Getting the localized strings
    LocalizedGPSStrings lgps = .new(context);

    return GestureDetector(
      onTap: () => showAddToSetOverlay
                    (
                      context: context, 
                      appBarBackgroundColor: navyBlue,
                      appBarForegroundColor: appBarWhite,
                      overlayTitle: lgps.gpsKeywordsOverlayAppbarTitle, 
                      overlayTitleStyle: problemSolvingKeywordsOverlayTitleStyle, 
                      overlayCloseIconButtonToolTip: AppLocalizations.of(context)?.l10n_keywords_overlay_close_button_tooltip ?? "Issue with the l10n for the keywords overlay close button tooltip",                 
                      overlayCloseIconButtonColor: appBarWhite,
                      textEditingControllerKey: const Key("gpsKeywordsField"), 
                      textEditingController: _keywordsTec, 
                      textFieldStyle: analysisTextFieldStyle, 
                      textFieldHintText: AppLocalizations.of(context)?.l10n_keywords_entry_text_field_hint ?? "Issue with the l10n for the keywords entry text field hint.",                 
                      textFieldHintStyle: analysisTextFieldHintStyle, 
                      onSubmittedCallbackFunction: (value, setLocalState) => _keywordAdd(value, setLocalState), 
                      setToUpdate: _keywords!, 
                      inputChipDeleteIconColor: appBarWhite,
                      onDeletedCallbackFunction: (tag, localSetState) 
                                                  {
                                                    setState( () {_keywords!.remove(tag);});
                                                    localSetState(() {});
                                                    widget.onKeywordsUpdatedCallbackFunction(_keywords!);
                                                  }                   
                    ),
      child: Container(        
        padding: const EdgeInsets.symmetric(vertical: 5),
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