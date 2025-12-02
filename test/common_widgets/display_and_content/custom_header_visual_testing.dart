//Line for automated processing
// flutter run -t ./test/common_widgets/display_and_content/custom_header_visual_testing.dart -d chrome
// flutter run -t ./test/common_widgets/display_and_content/custom_header_visual_testing.dart -d linux
// flutter run -t ./test/common_widgets/display_and_content/custom_header_visual_testing.dart -d macos
// flutter run -t ./test/common_widgets/display_and_content/custom_header_visual_testing.dart -d windows
//Line for automated processing


import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
// import 'package:flutter/rendering.dart'; // https://api.flutter.dev/flutter/rendering/

import 'package:journeyers/app_themes.dart';
import 'package:journeyers/common_widgets/display_and_content/custom_header.dart';

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
              CustomHeader(headerTitle: "Header 1", headerLevel:1),
              Gap(10),
              CustomHeader(headerTitle: "Header 2", headerLevel:2),
              Gap(10),
              CustomHeader(headerTitle: "Header 3", headerLevel:3),
              Gap(10),
              CustomHeader(headerTitle: "Header 4", headerLevel:4),
              Gap(10),
              CustomHeader(headerTitle: "Header 5", headerLevel:5),
              Gap(10),
              CustomHeader(headerTitle: "Header 6", headerLevel:6),
              Gap(10),
            ]              
          ),
        ),     
      ),
    );
  }
}