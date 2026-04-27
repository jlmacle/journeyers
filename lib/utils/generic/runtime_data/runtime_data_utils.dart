import 'package:shared_preferences/shared_preferences.dart';

import 'package:journeyers/utils/generic/dashboard/dashboard_utils.dart';

/// {@category Utils - Project-specific}
/// A project-specific utility class related to user preferences.
class RunTimeDataUtils 
{  
  /// Method used to avoid stale values by reloading.
  Future<void> reload() async
  {
    final prefs = await SharedPreferences.getInstance();
    prefs.reload();
  }

  // ─── FIRST-RUN MODAL ───────────────────────────────────────
  /// Method used to record that the first-run modal has been acknowledged.
  Future<bool> saveFirstRunModalAcknowledgement({required bool wasAcknowledged}) async 
  {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setBool('wasFirstRunModalAcknowledged', true);
  }

  /// Method used to check if the first-run modal has been acknowledged.
  Future<bool?> wasFirstRunModalAcknowledged() async 
  {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('wasFirstRunModalAcknowledged') ?? false;
  }

  /// Method used to reset the first-run modal status.
  Future<bool> resetFirstRunModalStatus() async 
  {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setBool('wasFirstRunModalAcknowledged', false);
  }

  // ─── FOLDER SELECTED FOR APPLICATION USE ───────────────────────────────────────
  // The setter is also in the Kotlin/Swift code

  /// Method used to retrieve the path to the application folder selected by the user (mobile applications).
  Future<String?> getApplicationFolderPath() async 
  {
    final prefs =  await SharedPreferences.getInstance();
    return prefs.getString('applicationFolderPath') ?? "";
  }

  /// Method used to save the path to the application folder selected by the user (mobile applications).
  Future<bool> saveApplicationFolderPath({required String path}) async 
  {
    final prefs =  await SharedPreferences.getInstance();
    return prefs.setString('applicationFolderPath', path);
  }

  // ─── EXISTING ANALYSIS SESSION DATA ? ───────────────────────────────────────
  /// Method used to record that session data has been saved.
  Future<bool> saveWasSessionDataSaved({required bool wasDataSaved, required String context}) async 
  {
    final prefs = await SharedPreferences.getInstance();
    switch (context)
    {
      case (DashboardUtils.caContext):
      {
        return await prefs.setBool('wasSessionDataSaved', wasDataSaved);
      }
      case (DashboardUtils.gpsContext):
      {
        return await prefs.setBool('wasGPSSessionDataSaved', wasDataSaved);
      }
      default: return false;
    }   
  }

  /// Method used to check if session data has been saved.
  Future<bool?> wasSessionDataSaved({required String context}) async 
  {
    final prefs = await SharedPreferences.getInstance();
    switch (context)
    {
      case (DashboardUtils.caContext):
      {
        return prefs.getBool('wasSessionDataSaved') ?? false;
      }
      case (DashboardUtils.gpsContext):
      {
        return prefs.getBool('wasGPSSessionDataSaved') ?? false;
      }   
      default:
        return null;
    }     
  }

  /// Method used to reset to false if session data has been saved.
  Future<bool> resetWasSessionDataSavedStatus({required String context}) async 
  {
    final prefs = await SharedPreferences.getInstance();
    switch (context)
    {
      case (DashboardUtils.caContext):
      {
        return await prefs.setBool('wasSessionDataSaved', false);
      }
      case (DashboardUtils.gpsContext):
      {
        return await prefs.setBool('wasGPSSessionDataSaved', false);
      }
      default: return false;
    }
  }
}
