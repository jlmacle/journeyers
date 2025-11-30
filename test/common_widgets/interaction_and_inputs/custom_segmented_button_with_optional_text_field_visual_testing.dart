//Line for automated processing
// flutter run -t test/common_widgets/interaction_and_inputs/custom_segmented_button_with_optional_text_field_visual_testing.dart -d linux
// flutter run -t test/common_widgets/interaction_and_inputs/custom_segmented_button_with_optional_text_field_visual_testing.dart -d macos
// flutter run -t test/common_widgets/interaction_and_inputs/custom_segmented_button_with_optional_text_field_visual_testing.dart -d windows
//Line for automated processing

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import 'package:journeyers/common_widgets/interaction_and_inputs/custom_segmented_button_with_optional_text_field.dart';
import 'package:journeyers/app_themes.dart';

void main() 
{  
  // WidgetsFlutterBinding.ensureInitialized(); // was not necessary on Windows, was necessary for macos
  runApp(const MyTestingApp());
}


class MyTestingApp extends StatefulWidget 
{

  const MyTestingApp({super.key});
  @override
  State<MyTestingApp> createState() => _MyTestingAppState();
}


class _MyTestingAppState extends State<MyTestingApp> 
{
  @override
  Widget build(BuildContext context) 
  {
    return MaterialApp
    (
      theme: appTheme, 
      home: HomePage()
      );
  }
}
//---------------------------------------------------

class HomePage extends StatefulWidget 
{

  const HomePage
  ({
    super.key,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
{
  Set<String> _selectedValues = {"No value(s) selected yet"};

  _updateSelectedValues(Set<String> newValues)
  {
    setState(() 
    {
      _selectedValues = newValues;     
    });
  }

  @override
  Widget build(BuildContext context) 
  {
    FocusNode appBarTitleFocusNode = FocusNode();

    return Scaffold
    (
       appBar: AppBar
      (
        title: Semantics
        (
          focused: true,
          focusable: true, 
          child: Focus
          (
            focusNode: appBarTitleFocusNode,
            child: const Text('MyTestingApp'),
          )
        ),
      ),
      body: Padding
      (
        padding: const EdgeInsets.all(20.0),
        child: Center
        (
          child: Column
          (
            children: 
            [         
              Text('Only clicking on "I don\'t know" should reveal a text field.', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),   
              Gap(16),                    
              Text('You selected: ${ (_selectedValues.toString()).replaceAll('{',"").replaceAll('}',"")}'),
              Gap(16),
              CustomSegmentedButtonWithOptionalTextField(textOption1: "Yes", textOption2: "No", textOption3: "I don't know",textOptionsfontSize: 20, onSelectionChanged: _updateSelectedValues,),
            ]
          ),
        ),
      ),
    );
  }
}
