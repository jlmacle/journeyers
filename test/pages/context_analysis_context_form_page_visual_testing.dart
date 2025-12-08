//Line for automated processing
// flutter run -t ./test/pages/context_analysis_context_form_page_visual_testing.dart -d chrome
// flutter run -t ./test/pages/context_analysis_context_form_page_visual_testing.dart -d linux
// flutter run -t ./test/pages/context_analysis_context_form_page_visual_testing.dart -d macos
// flutter run -t ./test/pages/context_analysis_context_form_page_visual_testing.dart -d windows
//Line for automated processing


import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
import 'package:journeyers/app_themes.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_context_form_page.dart';

void main() 
{  
  // WidgetsFlutterBinding.ensureInitialized(); // was not necessary on Windows, was necessary for macos
  runApp(const MyTestingApp());
  // debugPaintSizeEnabled = true;
}


class MyTestingApp extends StatefulWidget 
{
  const MyTestingApp({super.key});
  @override
  State<MyTestingApp> createState() => _MyTestingAppState();
}


class _MyTestingAppState extends State<MyTestingApp> 
{
  @override
  Widget build(BuildContext context) 
  {
    return MaterialApp
    (
      theme: appTheme, 
      home: HomePage()
      );
  }
}
//---------------------------------------------------

class HomePage extends StatefulWidget 
{

  const HomePage
  ({
    super.key,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
{
 
 FocusNode appBarTitleFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) 
  {
    return Scaffold
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
      body: Padding
      (
        padding: const EdgeInsets.all(20.0),
        child: Center
        (
          child: ContextAnalysisContextFormPage()
        ),
      ),
    );
  }
}
