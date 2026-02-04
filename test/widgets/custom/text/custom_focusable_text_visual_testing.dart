// Line for automated processing
// flutter run -t ./test/widgets/custom/text/custom_focusable_text_visual_testing.dart -d chrome
// flutter run -t ./test/widgets/custom/text/custom_focusable_text_visual_testing.dart -d linux
// flutter run -t ./test/widgets/custom/text/custom_focusable_text_visual_testing.dart -d macos
// flutter run -t ./test/widgets/custom/text/custom_focusable_text_visual_testing.dart -d windows
// Line for automated processing


import 'package:flutter/material.dart';

import 'package:journeyers/app_themes.dart';
import 'package:journeyers/widgets/custom/text/custom_focusable_text.dart';

void main() 
{
  WidgetsFlutterBinding.ensureInitialized(); // was not necessary on Windows, was necessary for macOS
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
  FocusNode appBarTitleFocusNode = FocusNode();

  @override void dispose() 
  {
    appBarTitleFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) 
  {
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
