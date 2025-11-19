import 'dart:io';

String eol = Platform.lineTerminator;

///
/// The purpose of this code is to extract a flutter command from the custom widgets, 
/// before using the command to build a script.
///
String commentsExtraction({required File file, required String delimiterLine})
{
  String comment = "";
  List<String> lines = file.readAsLinesSync();
  int nbrDelimiterLinesFound = 0;

  for (var line in lines)
  {
    if (line.contains(delimiterLine))
    {
      ++nbrDelimiterLinesFound;
      continue;
    }

    if (nbrDelimiterLinesFound == 2) {break;}     
    else if (nbrDelimiterLinesFound == 1)
    {
      String trimmedCommentLine = line.trim();
      comment += "$trimmedCommentLine$eol";
    }
  }
  return comment;
}

String firstCommentExtraction({required File file, required String delimiterLine})
{
  String comment = "";
  List<String> lines = file.readAsLinesSync();
  int nbrDelimiterLinesFound = 0;
  int nbrCommentFound = 0;

  for (var line in lines)
  {
    if (line.contains(delimiterLine))
    {
      ++nbrDelimiterLinesFound;
      continue;
    }
    if (nbrCommentFound == 1){break;}

    if (nbrDelimiterLinesFound == 2) {break;}     
    else if (nbrDelimiterLinesFound == 1)
    {
      String trimmedCommentLine = line.trim();
      comment += "$trimmedCommentLine$eol";
      ++nbrCommentFound;
    }
  }
  return comment;
}