// flutter run -t qa_utils\test_semi_automation_utils\widgets_visual_testing_helper_generation.dart -d linux
// flutter run -t qa_utils\test_semi_automation_utils\widgets_visual_testing_helper_generation.dart -d macos
// flutter run -t qa_utils\test_semi_automation_utils\widgets_visual_testing_helper_generation.dart -d windows

// The purpose of this code is to gather the flutter commands needed to test visually the custom widgets
// and to create a batch file launching the widgets, testing these custom widgets, in Chrome tabs.
// You might have to augent the timeout lett
import 'dart:io';

import 'package:journeyers/core/utils/files_and_json/file_utils.dart';
import 'package:journeyers/core/utils/printing_and_logging/print_utils.dart';
import 'package:path/path.dart' as path;

import 'comment_content_extractor.dart';

String eol = Platform.lineTerminator;
FileUtils fileUtils = FileUtils();

// checking the widgets present in lib/common_widgets
String directoryPath = path.join("test","common_widgets");
Directory widgetsDir = Directory(directoryPath);

void main() async
{
  List<File> fileList= fileUtils.getFilesInDirectory(directoryPath: directoryPath, fileExtension: ".dart", searchIsRecursive: true);
  int initPort = 8090;
  String cmdLines = 'REM Batch file launching the widgets, testing the custom widgets, in Chrome tabs.$eol'                 
                  'cd ../..$eol'
                  '@echo off$eol'
                  // 'set BROWSER=\'${path.join("")}C:\Program Files\Google\Chrome\Application\chrome.exe"$eol' // to fix an IDE issue
                  "set BROWSER=\"${path.join('C:','Program Files','Google','Chrome','Application','chrome.exe')}\"$eol" // to fix an IDE issue
                  'echo Programm to wait for the web servers to start before opening browser tabs$eol'
                  'timeout /t 5 >nul$eol$eol';
  for(var file in fileList)
  {
    printd("file.path: ${file.path}");
    String comment = firstCommentExtraction(file:file, delimiterLine:"//Line for automated processing");
    // Removing // at the start
    comment = comment.substring(2);
    // Removing everything after .dart
    comment = comment.substring(0,comment.indexOf(".dart") + 5);
    comment = comment.trim();

    //Building the cmd command
    ++initPort;
    String cmdFlutterSnippet = "start $comment -d web-server --web-port $initPort$eol";
    cmdLines += cmdFlutterSnippet;
  }
  // Timeout for the servers to start
  cmdLines += eol;
  cmdLines += "timeout /t 35 >nul$eol";
  // initPort has been incremented
  for (var i = 8091; i<=initPort; i++)
  {
    cmdLines += '%BROWSER% "http://localhost:$i$eol';
  }

  String filePath = path.join("qa_utils","automated_and_semi_automated_tests","widget_visual_testing_helper.bat");
  await fileUtils.createFileIfNecessaryAndAddContent(filePath:filePath, text:cmdLines);
  printd("The file should have been created at $filePath");
}

