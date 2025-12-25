import 'package:journeyers/core/utils/l10n/l10n_utils.dart';

import 'package:flutter/material.dart';
import 'package:journeyers/core/utils/printing_and_logging/print_utils.dart';

/// {@category Custom widgets}
/// A customizable dropdown menu to select a language.
class CustomLanguageSwitch extends StatefulWidget 
{
  /// The callback function called when a language value is selected.
  final ValueChanged<String> parentWidgetLanguageValueCallBackFunction;
  /// The horizontal location of the dropdown menu.
  final MainAxisAlignment languageSwitchMainAxisAlignment;

  const CustomLanguageSwitch
  ({
    super.key,
    required this.parentWidgetLanguageValueCallBackFunction, 
    // By default, the language menu is on the right side of the screen 
    this.languageSwitchMainAxisAlignment = MainAxisAlignment.end,
  });

  @override
  State<CustomLanguageSwitch> createState() => _CustomLanguageSwitchState();
}

class _CustomLanguageSwitchState extends State<CustomLanguageSwitch> 
{
  // Utility class
  PrintUtils pu = PrintUtils();

  List<String> _dropdownItems = [];
  late String _selectedValue;

  void getLanguages(context)
  {
    pu.printd("Language switcher: Localizations.localeOf(context): ${Localizations.localeOf(context)}");      
    _dropdownItems =  L10nLanguages.getLanguages(context);   
    _selectedValue = _dropdownItems.first;  
  }


  @override
  Widget build(BuildContext context) 
  {  
    getLanguages(context);

    return Row
    (
      mainAxisAlignment: widget.languageSwitchMainAxisAlignment,
      children: 
      [
        const Icon(Icons.language),
        Semantics
        (
          child: DropdownButton<String> 
          (            
            value: _selectedValue,
            items: _dropdownItems.map((String value) 
            {
              return DropdownMenuItem<String>
              (
                value: value,
                child: Text(value), 
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {              
                widget.parentWidgetLanguageValueCallBackFunction(newValue); 
              }
            }
          )
        )              
      ]
    );
  }
}