// Line for automated processing
// flutter run -t ./test/custom_widgets/display_and_content/custom_focusable_text_visual_testing.dart -d chrome
// flutter run -t ./test/custom_widgets/display_and_content/custom_focusable_text_visual_testing.dart -d linux
// flutter run -t ./test/custom_widgets/display_and_content/custom_focusable_text_visual_testing.dart -d macos
// flutter run -t ./test/custom_widgets/display_and_content/custom_focusable_text_visual_testing.dart -d windows
// Line for automated processing

import 'package:flutter/material.dart';

import 'package:journeyers/app_themes.dart';
import 'package:journeyers/custom_widgets/display_and_content/custom_focusable_text.dart';

void main() 
{
  WidgetsFlutterBinding.ensureInitialized(); // was not necessary on Windows, was necessary for macOS
  runApp(const MyTestingApp());
}

class MyTestingApp extends StatelessWidget 
{
  const MyTestingApp({super.key});

  @override
  Widget build(BuildContext context) 
  {
    FocusNode appBarTitleFocusNode = FocusNode();

    return 
    MaterialApp
    (
      theme: appTheme,
      home: 
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
        Center
        (
          child: 
          CustomFocusableText
          (
            text: 'You should be able to reach this text with the tab key',
          ),
        ),
      ),
    );
  }
}
