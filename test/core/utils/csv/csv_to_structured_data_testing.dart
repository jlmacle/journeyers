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
import 'package:journeyers/core/utils/csv/csv_utils.dart';

CSVUtils cu = CSVUtils();

void main() 
{
  WidgetsFlutterBinding.ensureInitialized(); // was not necessary on Windows, was necessary for macOS
  // debugPaintSizeEnabled = true;
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
  FocusNode appBarTitleFocusNode = FocusNode();
  late String dataAsString = "";

  @override
  void initState() {
    csvFileToPreviewPerspectiveDataAsString();
    super.initState();
  }

  @override void dispose() 
  {
    appBarTitleFocusNode.dispose();
    super.dispose();
  }

  String csvFileToPreviewPerspectiveDataAsString()
  {
    List<List<dynamic>> perspectiveData =  cu.csvFileToPreviewPerspectiveData("C:/Users/Portfolio-papa/Documents/analysis_fields.csv");

    List<dynamic> individualPerspective = perspectiveData[0];
    List<dynamic> groupPerspective = perspectiveData[1];

    dataAsString = individualPerspective.join() + groupPerspective.join();

    return dataAsString;
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
          child: Wrap(children: [Text(dataAsString)])
          
        ),
      ),
    );
  }
}
