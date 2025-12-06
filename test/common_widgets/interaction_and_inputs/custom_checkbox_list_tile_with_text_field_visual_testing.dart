//Line for automated processing
// flutter run -t ./test/common_widgets/interaction_and_inputs/custom_checkbox_list_tile_with_text_field_visual_testing.dart -d chrome
// flutter run -t ./test/common_widgets/interaction_and_inputs/custom_checkbox_list_tile_with_text_field_visual_testing.dart -d linux
// flutter run -t ./test/common_widgets/interaction_and_inputs/custom_checkbox_list_tile_with_text_field_visual_testing.dart -d macos
// flutter run -t ./test/common_widgets/interaction_and_inputs/custom_checkbox_list_tile_with_text_field_visual_testing.dart -d windows
//Line for automated processing

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:gap/gap.dart';
import 'package:journeyers/app_themes.dart';
import 'package:journeyers/common_widgets/display_and_content/custom_text.dart';
import 'package:journeyers/common_widgets/interaction_and_inputs/custom_checkbox_list_tile_with_text_field.dart';

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
  bool? _isCheckboxChecked;
  String? _textFieldContent;

  Map <String,dynamic> enteredData = {"question1":{"isChecked":false,"comments":"undefined"}};

  _setCheckboxState(bool value)
  {
    setState(() => _isCheckboxChecked = value);
  }

  _setTextFieldContent(String value)
  {
    setState(() => _textFieldContent = value);
  }

  transferDataToJsonFile() async 
  {
    enteredData["question1"]["isChecked"] = _isCheckboxChecked;
    enteredData["question1"]["comments"] = _textFieldContent;
    String jsonString = jsonEncode(enteredData);
    final bytes = Uint8List.fromList(utf8.encode(jsonString));

    await FilePicker.platform.saveFile(
    dialogTitle: 'Save your data',
    fileName: "data.json",
    bytes: bytes, // necessary, at least on Windows
    type: FileType.custom,
    allowedExtensions: ['json'],
  );

  }

  @override
  Widget build(BuildContext context) 
  {
    FocusNode appBarTitleFocusNode = FocusNode();   
    TextStyle feedbackTextStyle = TextStyle(fontSize: 20, fontWeight: FontWeight.normal);

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
      body: Column
      (
        crossAxisAlignment: CrossAxisAlignment.start,
        children: 
        [            
          CustomCheckBoxWithTextField(text: "Checkbox text", onCheckboxChanged: _setCheckboxState, onTextFieldChanged: _setTextFieldContent),
          Gap(8),
          Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: CustomText(text:"Is the checkbox checked? ${_isCheckboxChecked ?? false}", textStyle: feedbackTextStyle),
          ),
           Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: CustomText(text:"You typed: ${_textFieldContent ?? 'No value entered in the text field'}", textStyle: feedbackTextStyle),
          ),
          Gap(8),
          ElevatedButton
          (
            child: CustomText(text: "Save your data",textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.normal) ),
            onPressed: transferDataToJsonFile,
          )
        ]
      ),
    );
  }
}
