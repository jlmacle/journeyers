// Line for automated processing
// flutter run -t ./test/pages/context_analyses_preview_visual_testing.dart -d chrome
// flutter run -t ./test/pages/context_analyses_preview_visual_testing.dart -d linux
// flutter run -t ./test/pages/context_analyses_preview_visual_testing.dart -d macos
// flutter run -t ./test/pages/context_analyses_preview_visual_testing.dart -d windows
// Line for automated processing

import 'package:flutter/material.dart';

import 'package:journeyers/app_themes.dart';
import 'package:journeyers/widgets/utility/context_analysis_preview_widget.dart';

void main() 
{
  runApp(const MyTestingApp());
}

class MyTestingApp extends StatefulWidget {
  const MyTestingApp({super.key});
  @override
  State<MyTestingApp> createState() => _MyTestingAppState();
}

class _MyTestingAppState extends State<MyTestingApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(theme: appTheme, home: HomePage());
  }
}
//---------------------------------------------------

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FocusNode appBarTitleFocusNode = FocusNode();

  @override
  void dispose() {
    appBarTitleFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Semantics(
          focusable: true,
          child: Focus(
            focusNode: appBarTitleFocusNode,
            child: const Text('MyTestingApp'),
          ),
        ),
      ),
      body: SingleChildScrollView
      (
        child: ContextAnalysisPreviewWidget(pathToCsvData: r"test\pages\csv_files\context_analysis.csv")
      ),
    );
  }
}
