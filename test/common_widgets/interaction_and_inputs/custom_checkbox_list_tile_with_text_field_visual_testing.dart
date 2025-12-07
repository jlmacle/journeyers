//Line for automated processing
// flutter run -t ./test/common_widgets/interaction_and_inputs/custom_checkbox_list_tile_with_text_field_visual_testing.dart -d chrome
// flutter run -t ./test/common_widgets/interaction_and_inputs/custom_checkbox_list_tile_with_text_field_visual_testing.dart -d linux
// flutter run -t ./test/common_widgets/interaction_and_inputs/custom_checkbox_list_tile_with_text_field_visual_testing.dart -d macos
// flutter run -t ./test/common_widgets/interaction_and_inputs/custom_checkbox_list_tile_with_text_field_visual_testing.dart -d windows
//Line for automated processing

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
// import 'package:flutter/rendering.dart';
import 'package:gap/gap.dart';
import 'package:journeyers/app_themes.dart';
import 'package:journeyers/common_widgets/display_and_content/custom_text.dart';
import 'package:journeyers/common_widgets/interaction_and_inputs/custom_checkbox_list_tile_with_text_field.dart';

final GlobalKey<CustomCheckBoxWithTextFieldState> customCheckboxWithTextFieldKey = GlobalKey();

void main() 
{  
  // WidgetsFlutterBinding.ensureInitialized(); // was not necessary on Windows, was necessary for macos
  runApp(const MyTestingApp());
  // debugPaintSizeEnabled = true;
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

    await FilePicker.platform.saveFile
    (
      dialogTitle: 'Data saving',
      fileName: "data.json",
      bytes: bytes, // necessary, at least on Windows
      // type: FileType.custom,
      allowedExtensions: ['json'],
    );
  }

  importDataFromJsonFile() async
  {
    FilePickerResult? result = await FilePicker.platform.pickFiles
    (
        type: FileType.custom,
        allowedExtensions: ['json'],
    );
    String jsonString ="";

    if (kIsWeb) 
    {
        // For the web, path is null, file bytes are used directly
        final fileBytes = result!.files.single.bytes;
        if (fileBytes != null) 
        {
          jsonString = utf8.decode(fileBytes);
        }
    } 
    else 
    {
        // For desktop/mobile, path is used
        final filePath = result!.files.single.path;
        if (filePath != null) 
        {
          final file = File(filePath);
          jsonString = await file.readAsString();
        }
    }

    setState
    (
      () 
      {
        Map<String, dynamic> dataMap = jsonDecode(jsonString);
        // updating the parent's internal
        _isCheckboxChecked = dataMap["question1"]["isChecked"];
        _textFieldContent = dataMap["question1"]["comments"];
        // updating the widget's internal
        customCheckboxWithTextFieldKey.currentState?.updateCheckBoxStateFunction(_isCheckboxChecked!);
        customCheckboxWithTextFieldKey.currentState?.updateTextFieldStateFunction(_textFieldContent!);
      }
    );

    
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
      body: Column
      (
        children: 
        [            
          CustomCheckBoxWithTextField(text: "Checkbox text", onCheckboxChanged: _setCheckboxState, 
          textFieldPlaceholder: testTextFieldPlaceholder, onTextFieldChanged: _setTextFieldContent, 
          key: customCheckboxWithTextFieldKey),
          Gap(8),
          Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: CustomText(text:"Is the checkbox checked? ${_isCheckboxChecked ?? false}", textStyle: feedbackMessageStyle),
          ),
           Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: CustomText(text:"You typed: ${_textFieldContent ?? ""}", textStyle: feedbackMessageStyle),
          ),
          Gap(8),
          ElevatedButton
          (
            onPressed: transferDataToJsonFile,
            child: CustomText(text: "Click to save the data",textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.normal)),            
          ),
          Gap(8),
          ElevatedButton
          (
            onPressed: importDataFromJsonFile,
            child: CustomText(text: "Load previous data",textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.normal)),            
          )
        ]
      ),
    );
  }
}
