import 'dart:convert';
import 'dart:io';

class ProcessUtils 
{
  
  late int dataRank;

  ///
  /// Method to determine the rank of the new session data to be added to the dashboard data file.
  /// The method is useful to determine the file name for the session data to be saved.
  /// The method assumes a json file of `Map<String, dynamic>`.
  ///
  int newFileNumberDetermination(String pathToDashboardDataFile) 
  {
    var dashboardDataFile = File(pathToDashboardDataFile);
    // does the file exist?
    if(!dashboardDataFile.existsSync())
    {
      // file creation
      dashboardDataFile.createSync();
      dataRank = 1;
    }
    else
    {
      var dashboardDataFile = File(pathToDashboardDataFile);
      var jsonString = dashboardDataFile.readAsStringSync();
      Map<String,dynamic> dashboardData = jsonDecode(jsonString);
      
      var records = dashboardData["records"] as List;
      var lineNbr = records.length;
      dataRank = lineNbr+1;
    }

    return dataRank;

  }
}