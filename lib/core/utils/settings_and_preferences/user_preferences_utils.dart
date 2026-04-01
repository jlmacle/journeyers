import 'package:shared_preferences/shared_preferences.dart';

import 'package:journeyers/core/utils/dashboard/dashboard_utils.dart';

/// {@category Utils}
/// A utility class related to user preferences.
class UserPreferencesUtils 
{
  
  /// Method used to avoid stale values by reloading
  Future<void> reload() async
  {
    final prefs = await SharedPreferences.getInstance();
    prefs.reload();
  }

  //**************** ACKNOWLEDGMENT MODAL ****************/
  /// Method used to record that the acknowledgment modal has been acknowledged.
  Future<bool> saveInformationModalAcknowledgement() async 
  {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setBool('isInformationModalAcknowledged', true);
  }

  /// Method used to check if the acknowledgment modal has been acknowledged.
  Future<bool> isInformationModalAcknowledged() async 
  {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isInformationModalAcknowledged') ?? false;
  }

  /// Method used to reset the acknowledgment modal status
  Future<void> resetInformationModalStatus() async 
  {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isInformationModalAcknowledged', false);
  }

  //**************** FOLDER SELECTED FOR APPLICATION USE ****************/
  /// Method used to record the path of the folder selected for application use.
  Future<void> saveApplicationFolderPath(String folderPath) async 
  {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('applicationFolderPath', folderPath);
  }

  /// Method used to check if the application folder path has been saved.
  Future<String?> getApplicationFolderPath() async 
  {
    final prefs =  await SharedPreferences.getInstance();
    return prefs.getString('applicationFolderPath') ?? "";
  }


  //**************** EXISTING ANALYSIS SESSION DATA ? ****************/
  /// Method used to record that session data has been saved.
  Future<void> saveWasSessionDataSaved({required bool value, required String context}) async 
  {
    final prefs = await SharedPreferences.getInstance();
    switch (context)
    {
      case (DashboardUtils.contextAnalysesContext):
      {
        await prefs.setBool('wasSessionDataSaved', value);
      }
      case (DashboardUtils.groupProblemSolvingsContext):
      {
        await prefs.setBool('wasGroupProblemSolvingSessionDataSaved', value);
      }
    }   
  }

  /// Method used to check if session data has been saved.
  Future<bool?> wasSessionDataSaved({required String context}) async 
  {
    final prefs = await SharedPreferences.getInstance();
    switch (context)
    {
      case (DashboardUtils.contextAnalysesContext):
      {
        return prefs.getBool('wasSessionDataSaved') ?? false;
      }
      case (DashboardUtils.groupProblemSolvingsContext):
      {
        return prefs.getBool('wasGroupProblemSolvingSessionDataSaved') ?? false;
      }   
      default:
        return null;
    }     
  }

  /// Method used to reset to false if session data has been saved.
  Future<void> resetWasSessionDataSavedStatus({required String context}) async 
  {
    final prefs = await SharedPreferences.getInstance();
    switch (context)
    {
      case (DashboardUtils.contextAnalysesContext):
      {
        await prefs.setBool('wasSessionDataSaved', false);
      }
      case (DashboardUtils.groupProblemSolvingsContext):
      {
        await prefs.setBool('wasGroupProblemSolvingSessionDataSaved', false);
      }
    }
  }
}
