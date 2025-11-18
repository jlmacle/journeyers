import 'dart:io';

String eol = Platform.lineTerminator;

String commentExtraction({required File file, required String delimiterLine})
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
