import 'package:flutter/foundation.dart';

void printd(dynamic object)
{
  if(kDebugMode) //https://api.flutter.dev/flutter/foundation/kDebugMode-constant.html
  {
    debugPrint("Debug: $object"); //https://api.flutter.dev/flutter/rendering/debugPrint.html    
  }
}
