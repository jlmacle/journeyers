import 'package:flutter/material.dart';

typedef ItemSelectedCallback = void Function(String selectedValue);

class CustomLanguageSwitcher extends StatefulWidget {
  final ItemSelectedCallback onLanguageChanged;
  final MainAxisAlignment languageSwitcherMainAxisAlignemnt;

  const CustomLanguageSwitcher
  ({
    super.key,
    required this.onLanguageChanged, 
    this.languageSwitcherMainAxisAlignemnt = MainAxisAlignment.end,
  });

  @override
  State<CustomLanguageSwitcher> createState() => _CustomLanguageSwitcherState();
}

class _CustomLanguageSwitcherState extends State<CustomLanguageSwitcher> {
  // TODO: to get the values from analyzing the i10n folder
  final List<String> _dropdownItems = ['en', 'fr'];
  late String _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = _dropdownItems.first;    
  }


  @override
  Widget build(BuildContext context) {    
    return Row
    (
      mainAxisAlignment: widget.languageSwitcherMainAxisAlignemnt,
      children: 
      [
        const Icon(Icons.language),
        DropdownButton<String> 
        (       
          value: _selectedValue,
          items: const <String>['en', 'fr'].map((String value) 
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