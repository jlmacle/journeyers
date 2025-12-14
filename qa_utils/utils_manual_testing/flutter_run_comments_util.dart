// Uses Platform, therefore cannot function on a web app

// On macOS, gets a PathAccessException when using a project root environment variable: JOURNEYERS_DIR
// Cannot open file, path = '/Users/dev/Desktop/journeyers/test/pages/context_analysis_context_form_page_visual_testing.dart' 
// (OS Error: Operation not permitted, errno = 1)

// flutter run -t ./qa_utils/utils_manual_testing/flutter_run_comments_util.dart -d linux
// flutter run -t ./qa_utils/utils_manual_testing/flutter_run_comments_util.dart -d macos
// flutter run -t ./qa_utils/utils_manual_testing/flutter_run_comments_util.dart -d windows
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:journeyers/core/utils/files_and_json/file_utils.dart';
import 'package:logging/logging.dart';

import 'package:journeyers/core/utils/printing_and_logging/logging_utils.dart';

/// Given a relative path as filePath value, 
/// the previous pattern of comments is added at the top of the code.
void main() async
{
  setupLogging();
  final logger = Logger("flutter_run_comment_helper");
  String eol = Platform.lineTerminator;
  FileUtils fileUtils = FileUtils();
  /// https://docs.flutter.dev/platform-integration/desktop#from-the-command-line
  /// "A path is represented by a number of path components separated by a path separator which is a / on POSIX systems and can be a / or \ on Windows."
  /// https://hackage.haskell.org/package/path-0.9.6/docs/Path-Posix.html#:~:text=A%20path%20is%20represented%20by%20a%20number%20of%20path%20components%20separated%20by%20a%20path%20separator%20which%20is%20a%20/%20on%20POSIX%20systems%20and%20can%20be%20a%20/%20or%20%5C%20on%20Windows.
  
  Map<String, String> envVars = Platform.environment;
  String projectDir = "";
  if (defaultTargetPlatform == TargetPlatform.macOS) 
  {projectDir = envVars['JOURNEYERS_DIR']!;}

  String filePath =  "test/pages/context_analysis_context_form_page_visual_testing.dart";
  // String filePath = "./test/common_widgets/display_and_content/custom_dismissable_rectangular_area_visual_testing.dart";
  String commentBegin = "// flutter run -t ";
  String deviceFlag =  " -d ";
  String commentEndChrome = "chrome";
  String commentEndLinux = "linux";
  String commentEndMacOS = "macos";
  String commentEndWindows = "windows";

  String delimiterLine = "//Line for automated processing";

  File file = File("$projectDir$filePath");
  if (!file.existsSync()) 
  {
    logger.shout("File doesn't exist: ${file.path}");
    logger.shout("Current working directory: ${Directory.current}");
    exit(0);    
  }

  String content;
  try
  {
    content = file.readAsStringSync();
    if (content.contains(delimiterLine))
    {
      logger.shout("The delimiter line was found in $filePath");
      logger.shout("");      
    }
  else 
  {
    logger.info("The delimiter line wasn't found in $filePath");
    logger.info("Addition to the file");
    // Converting \ into /
    filePath = filePath.replaceAll("\\", "/");
    if (! filePath.startsWith('./'))   {filePath = './$filePath';}

    String comment = delimiterLine + eol +
                      commentBegin + filePath + deviceFlag + commentEndChrome + eol +
                      commentBegin + filePath + deviceFlag + commentEndLinux + eol +
                      commentBegin + filePath + deviceFlag + commentEndMacOS  + eol +
                      commentBegin + filePath + deviceFlag + commentEndWindows + eol +
                      delimiterLine + eol;    
    await fileUtils.appendTextInFront(filePath: filePath,text: comment);
    logger.info("The comments should have been added.");
    logger.shout("");
  }
  }
  on PathAccessException catch(e)
  {
    logger.shout("PathAccessException: $e");
  }
   
  
}