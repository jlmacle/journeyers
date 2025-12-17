//Line for automated processing
// flutter run -t ./test/common_widgets/interaction_and_inputs/custom_snackbar_start_message_helper_visual_testing.dart -d chrome
// flutter run -t ./test/common_widgets/interaction_and_inputs/custom_snackbar_start_message_helper_visual_testing.dart -d linux
// flutter run -t ./test/common_widgets/interaction_and_inputs/custom_snackbar_start_message_helper_visual_testing.dart -d macos
// flutter run -t ./test/common_widgets/interaction_and_inputs/custom_snackbar_start_message_helper_visual_testing.dart -d windows
//Line for automated processing


import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:journeyers/app_themes.dart';
import 'package:journeyers/common_widgets/interaction_and_inputs/custom_snackbar_start_message_helper.dart';
import 'package:journeyers/core/utils/settings_and_preferences/user_preferences_utils.dart';

// Kept for illustration purposes
void main() 
{  
  WidgetsFlutterBinding.ensureInitialized(); // was not necessary on Windows, was necessary for macos
  runApp(const MyTestingApp());
}

class MyTestingApp extends StatelessWidget 
{
  const MyTestingApp({super.key});

  @override
  Widget build(BuildContext context) 
  {
    return MaterialApp
    (
      theme: appTheme,
      home: ScaffoldMessenger
      (
        child: MyTestingWidget()
      )
    );
  }
}


class MyTestingWidget extends StatefulWidget 
{
  const MyTestingWidget({super.key});  

  @override
  State<MyTestingWidget> createState() => _MyTestingWidgetState();
}


class _MyTestingWidgetState extends State<MyTestingWidget> 
{
  // String eol = Platform.lineTerminator; // Throws an error if used with the web app
  void _showStartMessage() async 
  {
    if (!(await isStartSnackbarMessageAcknowledged())) 
    { 
      showCustomSnackbarStartMessage
      (
        buildContext: context,
        message: 'This is your first context analysis.\n'
                  'The dashboard will be displayed after data from the context analysis has been saved.',
        messageColor: Colors.white,
        duration: Duration(hours: 24),
        actiontext: 'Acknowledged',
      );
    }   
  }

  @override
  Widget build(BuildContext context) 
  { 
    FocusNode appBarTitleFocusNode = FocusNode();
    FocusNode introductoryMessageFocusNode = FocusNode();

    return Theme
    (
      data: appTheme,
      child: Scaffold
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
        body: Center
        (
          child: Column
          (
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>
            [
              Semantics
              ( 
                focusable: true,            
                child: Focus
                (
                  focusNode: introductoryMessageFocusNode,
                  child: Text
                  (
                    'Press the button to show the start message only once, if not resetting',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon
              (
                onPressed: _showStartMessage, 
                label: const Text('Show start message'),
              ),
               const SizedBox(height: 20),
              ElevatedButton.icon
              (
                onPressed: () async 
                {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('startSnackbarMessageAcknowledged', false);
                  _showStartMessage();
                }, 
                label: const Text('Reset to be able to show, and to show, the snackbar again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}