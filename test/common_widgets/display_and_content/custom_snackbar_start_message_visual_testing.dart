// flutter run -t .\test\common_widgets\display_and_content\custom_snackbar_start_message_visual_testing
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:journeyers/app_themes.dart';
import 'package:journeyers/common_widgets/display_and_content/custom_snackbar_start_message_helper.dart';
import 'package:journeyers/features/settings/user_preferences_helper.dart';

// Kept for educational purposes
void main() {  
  runApp(const MyTestingApp());
}

class MyTestingApp extends StatelessWidget {
  const MyTestingApp({super.key});

  @override
  Widget build(BuildContext context) {
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


class MyTestingWidget extends StatefulWidget {
  const MyTestingWidget({super.key});  

  @override
  State<MyTestingWidget> createState() => _MyTestingWidgetState();
}


class _MyTestingWidgetState extends State<MyTestingWidget> 
{

  void _showStartMessage() async {
    if (!(await isStartMessageAcknowledged())) 
    { 
      showCustomSnackbarStartMessage
      (
        buildContext: context,
        message: 'This is your first context analysis.\nThe dashboard will be displayed after data from the context analysis has been saved.',
        messageColor: Colors.white,
        duration: Duration(hours: 24),
        actiontext: 'Acknowledged',
      );
    }
   
  }

  @override
  Widget build(BuildContext context) {    
    return Theme(
      data: appTheme,
      child: Scaffold(      
        appBar: AppBar(
          title: const Text('MyTestingApp'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Press the button to show the start message only once, if not resetting',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _showStartMessage, 
                label: const Text('Show start message'),
              ),
               const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () async 
                {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('startSnackbarMessageAcknowledged', false);
                }, 
                label: const Text('Reset user preference'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}