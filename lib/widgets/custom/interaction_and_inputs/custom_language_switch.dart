import 'package:flutter/material.dart';

import 'package:journeyers/app_themes.dart';
import 'package:journeyers/debug_constants.dart';
import 'package:journeyers/utils/generic/dev/utility_classes_import.dart';
import 'package:journeyers/utils/generic/l10n/l10n_utils.dart';

/// {@category Custom widgets}
/// A customizable dropdown menu to select a language.
class CustomLanguageSwitch extends StatefulWidget 
{
  /// The callback function called when a language value is selected.
  final ValueChanged<String> onLanguageSelectedCallBackFunction;

  /// The horizontal location of the dropdown menu.
  final MainAxisAlignment languageSwitchMainAxisAlignment;

  const CustomLanguageSwitch
  ({
    super.key,
    required this.onLanguageSelectedCallBackFunction,
    // By default, the language menu is on the right side of the screen
    this.languageSwitchMainAxisAlignment = MainAxisAlignment.end,
  });

  @override
  State<CustomLanguageSwitch> createState() => _CustomLanguageSwitchState();

  /// Method used to get the language options in the current locale.
  List<String> getLanguages(BuildContext context) 
  {
    List<String> dropdownItems = [];
    if (preferencesDebug) pu.printd("Preferences: Language switcher: Localizations.localeOf(context): ${Localizations.localeOf(context)}");
    dropdownItems = L10nUtils.getLanguages(buildContext: context);
    return dropdownItems;
  }
}

class _CustomLanguageSwitchState extends State<CustomLanguageSwitch> 
{
  List<String> _dropdownItems = [];
  String? _selectedValue;

  // Getting the language options in the current locale.
  void getLanguages(BuildContext context) 
  {
    _dropdownItems = widget.getLanguages(context);
    _selectedValue = _dropdownItems.first;
  }

  @override
  Widget build(BuildContext context) 
  {
    getLanguages(context);

    return 
    Row
    (
      mainAxisAlignment: widget.languageSwitchMainAxisAlignment,
      children: 
      [        
        Semantics
        (
          child: 
          DropdownMenu<String>
          (
            leadingIcon: const Icon(Icons.language),
            inputDecorationTheme: appTheme.inputDecorationTheme.copyWith
            (
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none
            ),
            initialSelection: _selectedValue,
            dropdownMenuEntries: _dropdownItems.map((String value) 
            {
              return DropdownMenuEntry<String>(value: value, label: value);
            }).toList(),
            onSelected: (String? newValue) 
            {
              if (newValue != null) widget.onLanguageSelectedCallBackFunction(newValue);
            },
          ),
        ),
      ],
    );
  }
}
