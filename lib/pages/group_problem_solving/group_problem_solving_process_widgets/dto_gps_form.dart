import "dart:convert";
import "dart:core";

import "package:journeyers/utils/generic/dev/utility_classes_import.dart";

/// {@category Group problem-solving}
/// A DTO for the form part of the group problem-solving process 
/// (the ideas saved during the process).
class DTOGPSForm 
{  
  DTOGPSForm();

  // ─── FIELDS ───────────────────────────────────────
  List<String> ideas = [];

  /// Static method used to populates a [DTOGPSForm] from a TXT string.
  static Future<DTOGPSForm> fromTXT(String txtContent) async 
  {
    final dto = DTOGPSForm();
    dto.ideas = await ideasFrom(LineSplitter.split(txtContent).toList());
    return dto;
  }

  // ─── HELPER FUNCTIONS ───────────────────────────────────────

  // todo: to modify to use a file path.
  // Static method used to return the list of ideas stored in the gps session data
  static Future<List<String>> ideasFrom(List<String> txtLines) async
  {
    List<String> ideas = [];

    if (txtLines.length >= 5) {       
        // Ideas start after the "---" separator (index 3 onwards)
        // Numbering prefixes "1. ", "2. " are stripped
        ideas = txtLines
            .skip(4)
            .where((line) => line.trim().isNotEmpty)
            .map((line) => line.replaceFirst(RegExp(r"^\d+\.\s"), ""))
            .toList();   
    }

    return ideas;
  }  

  // ─── PRINTING METHODS ───────────────────────────────────────

  /// Prints all DTO field values to the console for debugging purposes.
  void printToConsole() {
    pu.printd("─── DTOGPSForm ──────────────────────────────────────────────");
    pu.printd("─────────────────────────────────────────────────────────────");
    pu.printd("  Ideas        : $ideas");
    pu.printd("─────────────────────────────────────────────────────────────");
  }

}