import "dart:io";

import 'package:test/test.dart';

import 'package:journeyers/core/utils/file_utils.dart';

void main()
{
  var fileUtils = FileUtils();
  var tempDir = Directory.current.createTempSync('file_utils_test');

  group('File utils tests:', () 
  {
    test('the content to write should be found in the file', () async
    {
      // using the library
      var testFilePath = '${tempDir.path}${Platform.pathSeparator}test_file.txt';
      var contentToWrite = 'Hello world';
      var file = File(testFilePath);
      fileUtils.appendText(file, contentToWrite);

      // testing if the content was written
      var testFile = File(testFilePath);
      var content = await testFile.readAsString();
      expect(content, equals(contentToWrite));

      // cleaning the temporary files
      if (tempDir.existsSync())
      {
        tempDir.delete(recursive: true);
    }
    });
  });
}