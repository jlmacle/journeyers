// Line for automated processing
// flutter run -t ./test/custom_widgets/display_and_content/custom_heading_visual_testing.dart -d chrome
// flutter run -t ./test/custom_widgets/display_and_content/custom_heading_visual_testing.dart -d linux
// flutter run -t ./test/custom_widgets/display_and_content/custom_heading_visual_testing.dart -d macos
// flutter run -t ./test/custom_widgets/display_and_content/custom_heading_visual_testing.dart -d windows
// Line for automated processing

import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart'; // https://api.flutter.dev/flutter/rendering/

import 'package:gap/gap.dart';

import 'package:journeyers/app_themes.dart';
import 'package:journeyers/custom_widgets/display_and_content/custom_heading.dart';

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
    FocusNode headingLevel1FocusNode = FocusNode();
    FocusNode headingLevel2FocusNode = FocusNode();
    FocusNode headingLevel3FocusNode = FocusNode();
    FocusNode headingLevel4FocusNode = FocusNode();
    FocusNode headingLevel5FocusNode = FocusNode();
    FocusNode headingLevel6FocusNode = FocusNode();

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
          Column
          (
            mainAxisAlignment: MainAxisAlignment.center,
            children: 
            [
              // Without MergeSemantics, "group" is added to the reading of the headings, at least by Narrator
              MergeSemantics
              (
                child: 
                Semantics
                (
                  focusable: true,
                  headingLevel: 1,
                  child: 
                  Focus
                  (
                    focusNode: headingLevel1FocusNode,
                    child: 
                    CustomHeading
                    (
                      headingText: "A heading level 1",
                      headingLevel: 1,
                    ),
                  ),
                ),
              ),
              Gap(10),
              MergeSemantics
              (
                child: 
                Semantics
                (
                  focusable: true,
                  headingLevel: 2,
                  child: 
                  Focus
                  (
                    focusNode: headingLevel2FocusNode,
                    child: 
                    CustomHeading
                    (
                      headingText: "A heading level 2",
                      headingLevel: 2,
                    ),
                  ),
                ),
              ),
              Gap(10),
              MergeSemantics
              (
                child: 
                Semantics
                (
                  focusable: true,
                  headingLevel: 3,
                  child: 
                  Focus
                  (
                    focusNode: headingLevel3FocusNode,
                    child: 
                    CustomHeading
                    (
                      headingText: "A heading level 3",
                      headingLevel: 3,
                    ),
                  ),
                ),
              ),
              Gap(10),
              MergeSemantics
              (
                child: 
                Semantics
                (
                  focusable: true,
                  headingLevel: 4,
                  child: 
                  Focus
                  (
                    focusNode: headingLevel4FocusNode,
                    child: 
                    CustomHeading
                    (
                      headingText: "A heading level 4",
                      headingLevel: 4,
                    ),
                  ),
                ),
              ),
              Gap(10),
              MergeSemantics
              (
                child: 
                Semantics
                (
                  focusable: true,
                  headingLevel: 5,
                  child: 
                  Focus
                  (
                    focusNode: headingLevel5FocusNode,
                    child: 
                    CustomHeading
                    (
                      headingText: "A heading level 5",
                      headingLevel: 5,
                    ),
                  ),
                ),
              ),
              Gap(10),
              MergeSemantics
              (
                child: 
                Semantics
                (
                  focusable: true,
                  headingLevel: 6,
                  child: 
                  Focus
                  (
                    focusNode: headingLevel6FocusNode,
                    child: 
                    CustomHeading
                    (
                      headingText: "A heading level 6",
                      headingLevel: 6,
                    ),
                  ),
                ),
              ),
              Gap(10),
            ],
          ),
        ),
      ),
    );
  }
}
