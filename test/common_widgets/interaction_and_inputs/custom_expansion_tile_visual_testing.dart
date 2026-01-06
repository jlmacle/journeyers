// Line for automated processing
// flutter run -t ./test/common_widgets/interaction_and_inputs/custom_expansion_tile_visual_testing.dart -d chrome
// flutter run -t ./test/common_widgets/interaction_and_inputs/custom_expansion_tile_visual_testing.dart -d linux
// flutter run -t ./test/common_widgets/interaction_and_inputs/custom_expansion_tile_visual_testing.dart -d macos
// flutter run -t ./test/common_widgets/interaction_and_inputs/custom_expansion_tile_visual_testing.dart -d windows
// Line for automated processing

import 'package:flutter/material.dart';

import 'package:journeyers/app_themes.dart';
import 'package:journeyers/core/utils/printing_and_logging/print_utils.dart';
import 'package:journeyers/custom_widgets/interaction_and_inputs/custom_expansion_tile.dart';

// Utility class
final PrintUtils pu = PrintUtils();

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
            )
          ),
        ),
        body: 
        Center
        (
          child: 
          CustomExpansionTile
          (
            parentWidgetOnEditPressedCallBackFunction: (){pu.printd('onEditPressed');},
            parentWidgetOnDeletePressedCallBackFunction: (){pu.printd('onDeletePressed');},
            parentWidgetOnSharePressedCallBackFunction: (){pu.printd('onSharePressed');}
          )
        ),
      ),      
    );
  }
}