// flutter run -t .\test\common_widgets\display_and_content\custom_banner_visual_testing.dart
import 'package:flutter/material.dart';

import 'package:journeyers/app_themes.dart';
import 'package:journeyers/common_widgets/display_and_content/custom_material_banner_helper.dart';

void main() {  
  runApp(const MyTestingApp());
}

class MyTestingApp extends StatelessWidget {
  const MyTestingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp
    (
      theme: appTheme,
      home: ScaffoldMessenger
      (
        child: MyTestingWidget()
      )
    );
  }
}


class MyTestingWidget extends StatefulWidget {
  const MyTestingWidget({super.key});  

  @override
  State<MyTestingWidget> createState() => _MyTestingWidgetState();
}


class _MyTestingWidgetState extends State<MyTestingWidget> 
{

  void _showBanner() {
    showCustomMaterialBanner(
      buildContext: context,
      message: 'Externalized Material Banner.',
      messageColor: Colors.white,
      iconData: Icons.info, 
      iconColor: Colors.white,
      actiontext: 'Dismiss',
      actionTextColor: Colors.white,
      actionTextFontweight: FontWeight.bold
    );
  }

  @override
  Widget build(BuildContext context) {    
    return Theme(
      data: appTheme,
      child: Scaffold(      
        appBar: AppBar(
          title: const Text('MyTestingApp'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Press the button to show the persistent banner.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _showBanner, 
                label: const Text('Show banner'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}