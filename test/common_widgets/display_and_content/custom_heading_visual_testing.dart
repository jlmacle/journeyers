//Line for automated processing
// flutter run -t ./test/common_widgets/display_and_content/custom_heading_visual_testing.dart -d chrome
// flutter run -t ./test/common_widgets/display_and_content/custom_heading_visual_testing.dart -d linux
// flutter run -t ./test/common_widgets/display_and_content/custom_heading_visual_testing.dart -d macos
// flutter run -t ./test/common_widgets/display_and_content/custom_heading_visual_testing.dart -d windows
//Line for automated processing


import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
// import 'package:flutter/rendering.dart'; // https://api.flutter.dev/flutter/rendering/

import 'package:journeyers/app_themes.dart';
import 'package:journeyers/common_widgets/display_and_content/custom_heading.dart';

void main() 
{  
  WidgetsFlutterBinding.ensureInitialized(); // was not necessary on Windows, was necessary for macOS
  // debugPaintSizeEnabled = true;
  runApp(const MyTestingApp());
}

class MyTestingApp extends StatelessWidget 
{
  const MyTestingApp({super.key});

  @override
  Widget build(BuildContext context) 
  {
    FocusNode appBarTitleFocusNode = FocusNode();

    return MaterialApp
    (
      theme: appTheme, 
      home: Scaffold
      (
        appBar: AppBar
        (
          title: Semantics
          (            
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
            children: 
            [
              CustomHeading(headingTitle: "Heading 1", headingLevel:1),
              Gap(10),
              CustomHeading(headingTitle: "Heading 2", headingLevel:2),
              Gap(10),
              CustomHeading(headingTitle: "Heading 3", headingLevel:3),
              Gap(10),
              CustomHeading(headingTitle: "Heading 4", headingLevel:4),
              Gap(10),
              CustomHeading(headingTitle: "Heading 5", headingLevel:5),
              Gap(10),
              CustomHeading(headingTitle: "Heading 6", headingLevel:6),
              Gap(10),
            ]              
          ),
        ),     
      ),
    );
  }
}