// @Skip('All tests in file_utils_test.dart are skipped')

import "dart:io";

import 'package:path/path.dart' as path;
import 'package:test/test.dart';

import 'package:journeyers/utils/generic/dev/utility_classes_export.dart';

void main() {
  var testFilePath = path.join(
    "test",
    "core",
    "utils",
    "files_and_json",
    "file_utils_test_data",
    "file.txt"
  );

  group('File utils tests:', () {
    test('the content to write should be found in the file', () async {
      var contentToWrite = 'Hello world';
      var file = File(testFilePath);

      // deleting the file if existant
      if (file.existsSync()) {
        await file.delete();
      }
      // checking that the file has been deleted
      var fileExists = file.existsSync();
      expect(fileExists, isFalse);

      // using the library
      await fu.addTextAtFileEnd(filePath: testFilePath, text: contentToWrite);

      // testing if the content was written
      var testFile = File(testFilePath);
      var content = await testFile.readAsString();
      expect(content, equals(contentToWrite));
    });
  });
}
