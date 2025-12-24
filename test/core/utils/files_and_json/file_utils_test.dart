// @Skip('All tests in file_utils_test.dart are skipped')
// library;

import "dart:io";

import 'package:path/path.dart' as path;
import 'package:test/test.dart';

import 'package:journeyers/core/utils/files/files_utils.dart';

void main()
{
  var fu = FileUtils();
  var testFilePath = path.join("test","core","utils","files_and_json","file_utils_test_data","file.txt");

  group('File utils tests:', () 
  {
    test('the content to write should be found in the file', () async
    {
      
      var contentToWrite = 'Hello world';
      var file = File(testFilePath);

      // deleting the file if existant
      if (file.existsSync())
      {
        await file.delete();
      }
      // checking that the file has been deleted
      var fileExists = file.existsSync();
      expect(fileExists, isFalse);

      // using the library
      await fu.appendText(filePath: testFilePath,text: contentToWrite);

      // testing if the content was written
      var testFile = File(testFilePath);
      var content = await testFile.readAsString();
      expect(content, equals(contentToWrite));      
      
    });
  });
}