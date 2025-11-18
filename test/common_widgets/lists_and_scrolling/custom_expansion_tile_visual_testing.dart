//Line for automated processing
// flutter run -t .\test\common_widgets\lists_and_scrolling\custom_expansion_tile_visual_testing.dart -d linux
// flutter run -t .\test\common_widgets\lists_and_scrolling\custom_expansion_tile_visual_testing.dart -d macos
// flutter run -t .\test\common_widgets\lists_and_scrolling\custom_expansion_tile_visual_testing.dart -d windows
//Line for automated processing

import 'package:flutter/material.dart';

import 'package:journeyers/app_themes.dart';
import 'package:journeyers/common_widgets/lists_and_scrolling/custom_expansion_tile.dart';

void main() {  
  runApp(const MyTestingApp());
}

class MyTestingApp extends StatelessWidget {
  const MyTestingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: appTheme, 
      home: Scaffold
      (
          appBar: AppBar(
          title: const Text('MyTestingApp'),
        ),
        body: Center(child: CustomExpansionTile()),
      ),      
    );
  }
}