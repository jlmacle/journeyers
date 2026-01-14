// Line for automated processing
// flutter run -t ./test/custom_widgets/interaction_and_inputs/custom_segmented_button_with_text_field_visual_testing.dart -d chrome
// flutter run -t ./test/custom_widgets/interaction_and_inputs/custom_segmented_button_with_text_field_visual_testing.dart -d linux
// flutter run -t ./test/custom_widgets/interaction_and_inputs/custom_segmented_button_with_text_field_visual_testing.dart -d macos
// flutter run -t ./test/custom_widgets/interaction_and_inputs/custom_segmented_button_with_text_field_visual_testing.dart -d windows
// Line for automated processing

import 'package:flutter/material.dart';

import 'package:gap/gap.dart';

import 'package:journeyers/app_themes.dart';
import 'package:journeyers/custom_widgets/interaction_and_inputs/custom_segmented_button_with_text_field.dart';

void main() 
{
  // WidgetsFlutterBinding.ensureInitialized(); // was not necessary on Windows, was necessary for macos
  runApp(const MyTestingApp());
}

class MyTestingApp extends StatelessWidget 
{
  const MyTestingApp({super.key});

  @override
  Widget build(BuildContext context) 
  {
    return MaterialApp(theme: appTheme, home: HomePage());
  }
}
//---------------------------------------------------

class HomePage extends StatefulWidget 
{
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> 
{
  FocusNode appBarTitleFocusNode = FocusNode();
  FocusNode introductoryMessageFocusNode = FocusNode();
  FocusNode informationalMessageFocusNode = FocusNode();

  Set<String> _selectedValues = {"No value selected yet"};
  String? _textContent;

  void parentWidgetTextFieldValueCallBackFunction(String value) 
  {
    setState(() {_textContent = value;});
  }

  void parentWidgetSegmentedButtonValueCallBackFunction(Set<String>? values) 
  {
    setState(() {_selectedValues = values!;}); // Only one value by configuration
  }

  @override
  void dispose() 
  {
    appBarTitleFocusNode.dispose();
    introductoryMessageFocusNode.dispose();
    informationalMessageFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) 
  {
    return 
    Scaffold
    (
      appBar: 
      AppBar
      (
        title: 
        Semantics
        (
          focusable: true,
          child: 
          Focus
          (
            focusNode: appBarTitleFocusNode,
            child: const Text('MyTestingApp'),
          ),
        ),
      ),
      body: 
      Padding
      (
        padding: const EdgeInsets.all(20.0),
        child: 
        Column
        (
          crossAxisAlignment: CrossAxisAlignment.start,
          children: 
          [
            Center
            (
              child: 
              Semantics
              (
                focusable: true,
                child: 
                Focus
                (
                  focusNode: introductoryMessageFocusNode,
                  child: Text('Clicking on any option should reveal a text field.', style: feedbackMessageStyle),
                ),
              ),
            ),
            Gap(16),
            CustomSegmentedButtonWithTextField
            (
              textOption1: "Yes",
              textOption2: "No",
              textOption3: "I don't know",
              textOptionsfontSize: 20,
              textFieldHintText: textFieldHintText,
              parentWidgetTextFieldValueCallBackFunction: parentWidgetTextFieldValueCallBackFunction,
              parentWidgetSegmentedButtonValueCallBackFunction: parentWidgetSegmentedButtonValueCallBackFunction,
            ),
            Gap(16),
            Center
            (
              child: 
              Semantics
              (
                focusable: true,
                child: 
                Focus
                (
                  focusNode: informationalMessageFocusNode,
                  child: 
                  Column
                  (
                    children: 
                    [
                      Text('You selected: ${(_selectedValues.toString()).replaceAll('{', "").replaceAll('}', "")}.', style: feedbackMessageStyle),
                      Gap(10),
                      Text('You typed: ${_textContent ?? "No text typed yet."}', style: feedbackMessageStyle),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
