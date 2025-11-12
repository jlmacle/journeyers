import 'package:flutter/foundation.dart';

void printd(String text){
  if(kDebugMode) //https://api.flutter.dev/flutter/foundation/kDebugMode-constant.html
  {
    debugPrint("Debug: $text"); //https://api.flutter.dev/flutter/rendering/debugPrint.html
    
  }
}
