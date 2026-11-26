import "package:material_ui/material_ui.dart";

import "package:journeyers/app_themes.dart";
import "package:journeyers/l10n/localized_ca_other_strings.dart";

class CALinkToExternalNotes extends StatefulWidget {

  /// Value for the link to the external notes at edition time.
  final String? linkToExternalNotesWhenEdition;
  /// A callback function called after editing the external link is complete.
  final ValueChanged<String> onLinkToExternalNotesUpdatedProcessCallbackFunction;

  const CALinkToExternalNotes
  ({
    super.key,
    this.linkToExternalNotesWhenEdition,
    required this.onLinkToExternalNotesUpdatedProcessCallbackFunction
  });

  @override
  State<CALinkToExternalNotes> createState() => _CALinkToExternalNotesState();
}

class _CALinkToExternalNotesState extends State<CALinkToExternalNotes> 
{
  final TextEditingController _controller = .new();

  @override
  void initState() {
    super.initState();    
    _controller.text = widget.linkToExternalNotesWhenEdition ?? "";
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Accessing the localized data
    LocalizedCAOtherStrings los = .new(context);
    
    return 
    Column
    (
      children: 
      [
        Text(los.caProcessExternalLinkTitle, style: appTheme.textTheme.headlineMedium),
        TextField
        (
          key: const Key("ca-process-linkToExternalNotes"),
          controller: _controller,
          keyboardType: TextInputType.url,
          minLines: 2,
          maxLines: 2,
          style: analysisTextFieldStyle,
          textAlign: .center,
          decoration: InputDecoration
                      (
                        hintText: los.caProcessExternalLinkTextFieldHint,
                        hintStyle: analysisTextFieldStyle
                      ),  
          onChanged: widget.onLinkToExternalNotesUpdatedProcessCallbackFunction
                    
        )
      ]
    );
  
  }
}