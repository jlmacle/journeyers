// flutter run -t .\test\common_widgets\display_and_content\custom_dismissable_rectangular_area_visual_testing.dart
import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart'; // for debugPaintSizeEnabled
import 'package:gap/gap.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:journeyers/app_themes.dart';
import 'package:journeyers/common_widgets/display_and_content/custom_dismissable_rectangular_area.dart';
import 'package:journeyers/core/utils/user_preferences_utils.dart';


typedef NewVisibilityStatusCallback = void Function(bool newVisibilityStatus);

void main() async {  
  // debugPaintSizeEnabled = true;

  var userPreferences = await SharedPreferences.getInstance();
  bool startMessageAcknowledged = userPreferences.getBool('startMessageAcknowledged') ?? false;

  runApp(MyTestingApp(startMessageAcknowledged: startMessageAcknowledged));
}

class MyTestingApp extends StatelessWidget {
  final bool startMessageAcknowledged; 

  const MyTestingApp
  ({
    super.key,
    required this.startMessageAcknowledged
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp
    (
      theme: appTheme,
      home: ScaffoldMessenger
      (
        child: MyTestingWidget(startMessageAcknowledged: startMessageAcknowledged)
      )
    );
  }
}


class MyTestingWidget extends StatefulWidget {
  final bool startMessageAcknowledged;

  const MyTestingWidget
  ({
    super.key,
    required this.startMessageAcknowledged
  });  

  @override
  State<MyTestingWidget> createState() => _MyTestingWidgetState();
}


class _MyTestingWidgetState extends State<MyTestingWidget> 
{
  late bool _visibilityStatus; 

   @override
  void initState() {
    super.initState();
    _visibilityStatus = !(widget.startMessageAcknowledged);   
  }
 
  void _hideMessageArea(bool newVisibilityStatus)
  {
    setState(() {
      _visibilityStatus = newVisibilityStatus;
    });
    saveStartMessageAcknowledgement();
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
              Expanded(child: Container()),
              Visibility
              (
                visible: _visibilityStatus,
                child: CustomDismissableRectangularArea(buildContext:context, 
                message1: 'This is your first context analysis.', 
                message2: 'The dashboard will be displayed after data from the context analysis has been saved.',
                messagesColor: paleCyan, // from app_themes
                actionText:'Please click the colored area to acknowledge.',
                actionTextColor: paleCyan, // from app_themes,
                areaBackgroundColor: navyBlue, // from app_themes
                setStateCallBack: _hideMessageArea), 

              ),
              Gap(30),
              ElevatedButton.icon(
                onPressed: () async 
                {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('startMessageAcknowledged', false);
                  // to rebuild and re-display the code
                  setState(() {
                    _visibilityStatus = true;
                  });
                }, 
                label: const Text('Reset user preference'),
              ),
              Gap(20)              
            ],
          ),
        ),
      ),
    );
  }
}