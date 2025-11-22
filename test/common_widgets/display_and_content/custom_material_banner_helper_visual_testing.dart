//Line for automated processing
// flutter run -t ./test/common_widgets/display_and_content/custom_material_banner_helper_visual_testing.dart -d linux
// flutter run -t ./test/common_widgets/display_and_content/custom_material_banner_helper_visual_testing.dart -d macos
// flutter run -t ./test/common_widgets/display_and_content/custom_material_banner_helper_visual_testing.dart -d windows
//Line for automated processing

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:journeyers/app_themes.dart';
import 'package:journeyers/common_widgets/display_and_content/custom_material_banner_helper.dart';
import 'package:journeyers/core/utils/settings_and_preferences/user_preferences_utils.dart';

void main() {  
  WidgetsFlutterBinding.ensureInitialized();// was not necessary on Windows, was necessary for macos
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

  void _showBanner() async {
    if (!(await isMaterialBannerDismissed())) 
    { 
      showCustomMaterialBanner
      (
        buildContext: context,
        message: 'Externalized Material Banner.',
        messageColor: Colors.white,
        iconData: Icons.info, 
        iconColor: Colors.white,
        actionText: 'Dismiss',
        actionTextColor: Colors.white,
        actionTextFontweight: FontWeight.bold
      );
    }
   
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
                'Press the button to show the banner only once, if not resetting',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _showBanner, 
                label: const Text('Show banner'),
              ),
               const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () async 
                {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('bannerDismissed', false);
                }, 
                label: const Text('Reset to be able to show the banner again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}