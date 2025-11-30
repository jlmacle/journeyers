//Line for automated processing
// flutter run -t test/common_widgets/interaction_and_inputs/custom_cascading_checkboxes_visual_testing.dart -d linux
// flutter run -t test/common_widgets/interaction_and_inputs/custom_cascading_checkboxes_visual_testing.dart -d macos
// flutter run -t test/common_widgets/interaction_and_inputs/custom_cascading_checkboxes_visual_testing.dart -d windows
//Line for automated processing


import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:journeyers/common_widgets/interaction_and_inputs/custom_cascading_checkboxes.dart';
import 'package:journeyers/app_themes.dart';
import 'package:journeyers/l10n/app_localizations.dart';

void main() 
{  
  // WidgetsFlutterBinding.ensureInitialized(); // was not necessary on Windows, was necessary for macos
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

  @override
  Widget build(BuildContext context) 
  {
    FocusNode appBarTitleFocusNode = FocusNode();

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
          child: Column
          (
            children: 
            [
                CascadingCheckboxes(),
            ]
          ),
        ),
      ),
    );
  }
}
