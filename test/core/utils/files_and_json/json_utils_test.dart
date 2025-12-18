import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

import 'package:journeyers/core/utils/printing_and_logging/logging_utils.dart';
import 'package:journeyers/core/utils/files_and_json/json_utils.dart';

void main()
{
  // Map<String,dynamic> newData = {"startMessageAcknowledged":true};
  String preferenceName = "startMessageAcknowledged";
  bool preferenceValue = true;

  String updatedFilesDirectoryPath = path.join('test','core','utils','files_and_json','json_utils_test_data','updated_files');
  Directory updatedFilesfolder = Directory(updatedFilesDirectoryPath);   

  setUpAll(() async
  {
    setupLogging();
    final logger = Logger('MyTestingCode');    
    
    // .list() produces a stream, not a list. toList() does.
    List<FileSystemEntity> updatedFilesfolderEntities = await updatedFilesfolder.list().toList();
    // Emptying the updated_files folder if non empty
    if (updatedFilesfolderEntities.isNotEmpty)
    {
      for(var entity in updatedFilesfolderEntities)
      {
        if(entity is File)
        {
          logger.shout("Deleting: $entity");
          try {entity.deleteSync();}
          on Exception catch(e){logger.shout("");logger.shout("Issue at copying in $updatedFilesDirectoryPath");logger.shout(e);}
        }               
      }  
      // testing for the folder to be empty  
      int remainingFilesNbr = 0;
      for(var entity in updatedFilesfolderEntities)
      {
        if(entity is File)
        {
          remainingFilesNbr++;
        }
      } 
      expect(remainingFilesNbr, 0);
    }
    // Copying the files from the source folder into the updated_files folder
    String sourceFilesDirectoryPath = path.join('test','core','utils','files_and_json','json_utils_test_data','source_files');
    Directory sourceFilesfolder = Directory(sourceFilesDirectoryPath);  

    List<FileSystemEntity> sourceFilesfolderEntities = await sourceFilesfolder.list().toList();
    
    if (sourceFilesfolderEntities.isNotEmpty)
    {           
      for(var entity in sourceFilesfolderEntities)
      {
        if(entity is File)
        {
          try
          {
            // Getting the file name
            var fileName = path.basename(entity.path);
            var completeFilePath = path.join(updatedFilesDirectoryPath,fileName);
            entity.copySync(completeFilePath);
          }
          on Exception catch(e){logger.shout("");logger.shout("Issue at copying in $updatedFilesDirectoryPath");logger.shout(e);}          
        }        
      }    
    }
  });
  

  group("Json utils tests: preference saving:", ()
  {
    test("case where the json file doesn't exist.", () async
    {
      String jsonFileName = "preference_doesnt_exist.json";
      String jsonFilePath = path.join(updatedFilesDirectoryPath, jsonFileName);
      await savePreference(jsonFilePath:jsonFilePath, preferenceName: preferenceName, preferenceValue: preferenceValue);

      // without await, the file doesn't exist for the remainder of the code to succeed
      String jsonFileContent = File(jsonFilePath).readAsStringSync();
      Map<String,dynamic> jsonData  = jsonDecode(jsonFileContent) as Map<String,dynamic> ;
      assert(const DeepCollectionEquality().equals(jsonData, {"startMessageAcknowledged": true}));
    });

    test("case where the preference key doesn't exist.", () async
    {
      String jsonFileName = "preference_absent.json";
      String jsonFilePath = path.join(updatedFilesDirectoryPath, jsonFileName);
      await savePreference(jsonFilePath:jsonFilePath, preferenceName: preferenceName, preferenceValue: preferenceValue);

      String jsonFileContent = File(jsonFilePath).readAsStringSync();
      Map<String,dynamic> jsonData  = jsonDecode(jsonFileContent) as Map<String,dynamic>;
      assert(const DeepCollectionEquality().equals(jsonData, {"aPreference":true,"startMessageAcknowledged": true}));
    });

     test("case where the preference key does exist and needs to be updated.", () async
    {
      String jsonFileName = "preference_present.json";
      String jsonFilePath = path.join(updatedFilesDirectoryPath, jsonFileName);
      await savePreference(jsonFilePath:jsonFilePath, preferenceName: preferenceName, preferenceValue: preferenceValue);

      String jsonFileContent = File(jsonFilePath).readAsStringSync();
      Map<String,dynamic> jsonData  = jsonDecode(jsonFileContent) as Map<String,dynamic>;
      assert(const DeepCollectionEquality().equals(jsonData, {"startMessageAcknowledged": true}));
    });
  });
}