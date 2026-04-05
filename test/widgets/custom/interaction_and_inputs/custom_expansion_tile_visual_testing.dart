// Line for automated processing
// flutter run -t ./test/widgets/custom/interaction_and_inputs/custom_expansion_tile_visual_testing.dart -d chrome
// flutter run -t ./test/widgets/custom/interaction_and_inputs/custom_expansion_tile_visual_testing.dart -d linux
// flutter run -t ./test/widgets/custom/interaction_and_inputs/custom_expansion_tile_visual_testing.dart -d macos
// flutter run -t ./test/widgets/custom/interaction_and_inputs/custom_expansion_tile_visual_testing.dart -d windows
// Line for automated processing


import 'package:flutter/material.dart';

import 'package:journeyers/app_themes.dart';
import 'package:journeyers/core/utils/dev/util_files.dart';
import 'package:journeyers/widgets/custom/interaction_and_inputs/custom_expansion_tile.dart';


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
  FocusNode appBarTitleFocusNode = .new();

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
          CustomExpansionTile
          (
            editPressedCallBackFunction: () {pu.printd('onEditPressed');},
            deletePressedCallBackFunction: () {pu.printd('onDeletePressed');},
          ),
        ),
      ),
    );
  }
}
