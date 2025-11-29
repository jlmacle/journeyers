import 'package:flutter/material.dart';
import 'package:journeyers/l10n/app_localizations.dart';

typedef ItemSelectedCallback = void Function(String selectedValue);

/// A customizable dropdown menu to select a language

class CustomLanguageSwitcher extends StatefulWidget 
{
  /// The function to call when selecting a language value
  final ItemSelectedCallback onLanguageChanged;
  /// The horizontal localisation of the dropdown menu
  final MainAxisAlignment languageSwitcherMainAxisAlignemnt;

  const CustomLanguageSwitcher
  ({
    super.key,
    required this.onLanguageChanged, 
    // By default, the language menu is on the right side of the screen 
    this.languageSwitcherMainAxisAlignemnt = MainAxisAlignment.end,
  });

  @override
  State<CustomLanguageSwitcher> createState() => _CustomLanguageSwitcherState();
}

class _CustomLanguageSwitcherState extends State<CustomLanguageSwitcher> 
{

  final List<String> _dropdownItems = [];
  late String _selectedValue;

  @override
  void initState() 
  {

    List<Locale> localesList = AppLocalizations.supportedLocales.toList();
    for (var locale in  localesList)
    {
       _dropdownItems.add(locale.toString());
    }
    _selectedValue = _dropdownItems.first;  
    super.initState();
    }


  @override
  Widget build(BuildContext context) 
  {    
    return Row
    (
      mainAxisAlignment: widget.languageSwitcherMainAxisAlignemnt,
      children: 
      [
        const Icon(Icons.language),
        DropdownButton<String> 
        (       
          value: _selectedValue,
          items: _dropdownItems.map((String value) 
          {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value.toUpperCase()), 
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {              
              widget.onLanguageChanged(newValue); 
            }
          }
        )      
      ]
    );
  }
}