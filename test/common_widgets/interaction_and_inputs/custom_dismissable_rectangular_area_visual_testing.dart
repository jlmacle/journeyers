//Line for automated processing
// flutter run -t ./test/common_widgets/interaction_and_inputs/custom_dismissable_rectangular_area_visual_testing.dart -d chrome
// flutter run -t ./test/common_widgets/interaction_and_inputs/custom_dismissable_rectangular_area_visual_testing.dart -d linux
// flutter run -t ./test/common_widgets/interaction_and_inputs/custom_dismissable_rectangular_area_visual_testing.dart -d macos
// flutter run -t ./test/common_widgets/interaction_and_inputs/custom_dismissable_rectangular_area_visual_testing.dart -d windows
//Line for automated processing


import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart'; // for debugPaintSizeEnabled
import 'package:gap/gap.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:journeyers/app_themes.dart';
import 'package:journeyers/common_widgets/interaction_and_inputs/custom_dismissable_rectangular_area.dart';
import 'package:journeyers/core/utils/settings_and_preferences/user_preferences_utils.dart';


void main() async 
{  
  // debugPaintSizeEnabled = true;
  WidgetsFlutterBinding.ensureInitialized(); // was not necessary on Windows, was necessary for macos 
  runApp(MyTestingApp());
}

class MyTestingApp extends StatelessWidget 
{
  const MyTestingApp
  ({
    super.key
  });

  @override
  Widget build(BuildContext context) 
  {
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


class MyTestingWidget extends StatefulWidget 
{
  const MyTestingWidget
  ({
    super.key
  });  

  @override
  State<MyTestingWidget> createState() => _MyTestingWidgetState();
}


class _MyTestingWidgetState extends State<MyTestingWidget> 
{  
  bool _isPreferenceLoaded = false;
  late bool _startMessageAcknowledged;
  late bool _visibilityStatus; 

  void preferenceLoading() async
  {
    var userPreferences = await SharedPreferences.getInstance();    
    setState(() 
    {
      _startMessageAcknowledged = userPreferences.getBool('startMessageAcknowledged') ?? false;
      _visibilityStatus = !(_startMessageAcknowledged); 
      _isPreferenceLoaded = true;
    });    
  }

   @override
  void initState() 
  {
    super.initState();
    preferenceLoading();
  }
 
  void _hideMessageArea()
  {
    setState(() 
    {
      _visibilityStatus = false;
    });
    saveStartMessageAcknowledgement();
  }
  
  @override
  Widget build(BuildContext context) 
  { 
    FocusNode appBarTitleFocusNode = FocusNode();
    
    return Theme
    (
      data: appTheme,
      child: Scaffold
      (      
        appBar: AppBar
        (
          title: Semantics
          (
            focusable: true, 
            child: Focus
            (
              focusNode: appBarTitleFocusNode,
              child: const Text('MyTestingApp'),
            )
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>
            [
              if (!_isPreferenceLoaded) 
                CircularProgressIndicator()    
              else
              ...[       
                Expanded
                (
                  child: Container()
                ),
                Visibility
                (
                  visible: _visibilityStatus,
                  child: CustomDismissableRectangularArea
                  (
                    message1: 'This is your first context analysis.', 
                    message2: 'The dashboard will be displayed after data from the context analysis has been saved.',
                    messagesColor: paleCyan, // from app_themes
                    actionText:'Please click the message area to acknowledge.',
                    actionTextColor: paleCyan, // from app_themes,
                    areaBackgroundColor: navyBlue, // from app_themes
                    parentWidgetAreaOnTapCallBackFunction: _hideMessageArea
                  ), 
                ),
                Gap(30),
                ElevatedButton.icon
                (
                  onPressed: () async 
                  {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('startMessageAcknowledged', false);
                    // to rebuild and re-display the code
                    setState(() {
                      _visibilityStatus = true;
                    });
                  }, 
                  label: const Text('Reset to display the message again'),
                ),
              ],        
            ],
          ),
        ),
      ),
    );
  }
}