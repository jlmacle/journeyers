//Line for automated processing
// flutter run -t ./test/common_widgets/interaction_and_inputs/custom_padded_text_field_visual_testing.dart -d chrome
// flutter run -t ./test/common_widgets/interaction_and_inputs/custom_padded_text_field_visual_testing.dart -d linux
// flutter run -t ./test/common_widgets/interaction_and_inputs/custom_padded_text_field_visual_testing.dart -d macos
// flutter run -t ./test/common_widgets/interaction_and_inputs/custom_padded_text_field_visual_testing.dart -d windows
//Line for automated processing

import 'package:flutter/material.dart';
import 'package:journeyers/app_themes.dart';
import 'package:journeyers/common_widgets/interaction_and_inputs/custom_padded_text_field.dart';

typedef OnTextFieldChangedCallback = void Function(String);

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
  String pleaseDescribeTextHousehold = 'Please describe the past outcomes for the household, '
                                      'if some seem to have been out of their comfort zone for too long, '
                                      'and the more desirable outcomes for the household.'; 

  TextEditingController textFieldEditingController = TextEditingController();
  void onChangedCallback(String value)
  {
    setState(() {});
  }


  @override
  Widget build(BuildContext context) 
  {
    FocusNode appBarTitleFocusNode = FocusNode();
    FocusNode feedbackMsgFocusNode = FocusNode();

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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CustomPaddedTextField
          (
            topPadding: 20,
            textFieldInputDecoration: InputDecoration(hintText: pleaseDescribeTextHousehold), 
            textFieldEditingController: textFieldEditingController, 
            textFieldOnChangedCallbackFunction: onChangedCallback
          
          ),
          Focus
          (
            focusNode: feedbackMsgFocusNode,
            child: Text("You typed: ${textFieldEditingController.text}", style: feedbackMessageStyle)
            )          
        ],
      )
    );
  }
}
