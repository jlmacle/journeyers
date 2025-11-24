import 'dart:convert';
import 'dart:io';

import 'package:logging/logging.dart';

final logger = Logger("Json Utils");

/// This method assumes for the json file to be simple hashmap
Future<void> savePreference({required String jsonFilePath,required String preferenceName,required dynamic preferenceValue}) async
{
  var jsonFile = File(jsonFilePath);
  Map<String,dynamic> newData = {preferenceName:preferenceValue};
  String jsonString = jsonEncode(newData);

  //If the file doesn't exist
  if (! jsonFile.existsSync())
  {
    // File creation with the new data
    try{await jsonFile.writeAsString(jsonString);}
    on Exception catch (e){logger.shout("Error while writing the Json String");logger.shout(e);} 
  }
  else
  {
    try
    {
      jsonString = await jsonFile.readAsString();
      Map<String,dynamic>  map = jsonDecode(jsonString);
      map.addEntries(newData.entries);
      String updatedJsonString = jsonEncode(map);
      await jsonFile.writeAsString(updatedJsonString);
    }
    on Exception catch (e){logger.shout("Error while readding/decoding the Json String");logger.shout(e);} 
  }
}