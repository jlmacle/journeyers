import 'dart:io';

import 'package:flutter/material.dart';
import 'package:journeyers/core/utils/files_and_json/file_utils.dart';
import 'package:path/path.dart' as path;

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

  final List<String> _dropdownItems = [];
  late String _selectedValue;

  @override
  void initState() 
  {
    // Building programmatically _dropdownItems = ['en', 'fr',...];
    FileUtils fileUtils = FileUtils();
    String languagesDirPath = path.join("lib", "l10n"); 
    List<File> fileList= fileUtils.getFilesInDirectory(directoryPath: languagesDirPath, fileExtension: ".arb", searchIsRecursive: true);
    for(var file in fileList)
    {
      String fileName = path.basename(file.path);
      String languageCode = fileName.replaceAll("app_", "");
      languageCode = languageCode.replaceAll(".arb", "");
      _dropdownItems.add(languageCode);
    }

    _selectedValue = _dropdownItems.first;  

    super.initState();
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