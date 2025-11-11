// flutter run -t .\test\common_widgets\lists_and_scrolling\custom_expansion_tile_visual_testing.dart
import 'package:flutter/material.dart';

import 'package:journeyers/common_widgets/lists_and_scrolling/custom_expansion_tile.dart';

void main() {  
  runApp(const MyWidget());
}

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp
    (
      home: Scaffold(
        body: Center(child: CustomExpansionTile()),
      ),      
    );
  }
}