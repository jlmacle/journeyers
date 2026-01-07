// Line for automated processing
// flutter run -t ./test/custom_widgets/interaction_and_inputs/custom_checkbox_list_tile_with_text_field_visual_testing.dart -d chrome
// flutter run -t ./test/custom_widgets/interaction_and_inputs/custom_checkbox_list_tile_with_text_field_visual_testing.dart -d linux
// flutter run -t ./test/custom_widgets/interaction_and_inputs/custom_checkbox_list_tile_with_text_field_visual_testing.dart -d macos
// flutter run -t ./test/custom_widgets/interaction_and_inputs/custom_checkbox_list_tile_with_text_field_visual_testing.dart -d windows
// Line for automated processing

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';

import 'package:file_picker/file_picker.dart';
import 'package:gap/gap.dart';

import 'package:journeyers/app_themes.dart';
import 'package:journeyers/custom_widgets/display_and_content/custom_focusable_text.dart';
import 'package:journeyers/custom_widgets/interaction_and_inputs/custom_checkbox_list_tile_with_text_field.dart';

void main() 
{
  // WidgetsFlutterBinding.ensureInitialized(); // was not necessary on Windows, was necessary for macos
  runApp(const MyTestingApp());
  // debugPaintSizeEnabled = true;
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
  bool _isCheckboxChecked = false;
  String? _textFieldContent;

  Map<String, dynamic> enteredData = {"question1": {"isChecked": false, "comments": ""}};

  void parentWidgetTextFieldValueCallBackFunction(String value) 
  {
    setState(() {_textFieldContent = value;});
  }

  void parentWidgetCheckboxValueCallBackFunction(bool? value) 
  {
    setState(() {_isCheckboxChecked = value!;});
  }

  transferDataToJsonFile() async 
  {
    enteredData["question1"]["isChecked"] = _isCheckboxChecked;
    enteredData["question1"]["comments"] = _textFieldContent;
    String jsonString = jsonEncode(enteredData);
    final bytes = Uint8List.fromList(utf8.encode(jsonString));

    await FilePicker.platform.saveFile
    (
      dialogTitle: 'Data saving',
      type: FileType.custom,
      fileName: "data.json",
      bytes: bytes, // necessary, at least on Windows
      allowedExtensions: ['json'],
    );
  }

  @override
  Widget build(BuildContext context) 
  {
    FocusNode appBarTitleFocusNode = FocusNode();

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
      Column
      (
        children: 
        [
          CustomCheckBoxWithTextField
          (
            checkboxText: "Checkbox text",
            textFieldHintText: textFieldHintText,
            parentWidgetTextFieldValueCallBackFunction: parentWidgetTextFieldValueCallBackFunction,
            parentWidgetCheckboxValueCallBackFunction: parentWidgetCheckboxValueCallBackFunction,
          ),
          Gap(8),
          Padding
          (
            padding: const EdgeInsets.only(left: 20.0),
            child: CustomFocusableText
            (
              text: "Is the checkbox checked? $_isCheckboxChecked.",
              textStyle: feedbackMessageStyle,
            ),
          ),
          Padding
          (
            padding: const EdgeInsets.only(left: 20.0),
            child: 
            CustomFocusableText
            (
              text: 'You typed: ${_textFieldContent ?? "No text typed yet."}',
              textStyle: feedbackMessageStyle,
            ),
          ),
          Gap(8),
          ElevatedButton
          (
            onPressed: transferDataToJsonFile,
            child: CustomFocusableText
            (
              text: "Click to save the data (json for this demo)",
              textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.normal),
            ),
          ),
        ],
      ),
    );
  }
}
