//Line for automated processing
// flutter run -t ./test/common_widgets/display_and_content/custom_bordered_text_visual_testing.dart -d chrome
// flutter run -t ./test/common_widgets/display_and_content/custom_bordered_text_visual_testing.dart -d linux
// flutter run -t ./test/common_widgets/display_and_content/custom_bordered_text_visual_testing.dart -d macos
// flutter run -t ./test/common_widgets/display_and_content/custom_bordered_text_visual_testing.dart -d windows
//Line for automated processing


import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart'; // https://api.flutter.dev/flutter/rendering/

import 'package:journeyers/app_themes.dart';
import 'package:journeyers/common_widgets/display_and_content/custom_bordered_text.dart';
import 'package:journeyers/common_widgets/display_and_content/custom_text.dart';

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
          child:  
          CustomBorderedText(
            customText: CustomText(text: "Custom bordered text",textStyle: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold), 
                                  textAlign: TextAlign.center),
            edgeInsetsGeometry: EdgeInsets.all(20), border: Border.all(), borderRadius: BorderRadius.circular(10))
        )
      )
    );
   }
}