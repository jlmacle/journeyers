import 'dart:io';

import 'package:flutter/services.dart';
import 'package:journeyers/app_themes.dart';
import 'package:shared_preferences/shared_preferences.dart';



/// {@category Utils}
/// A utility class related to user preferences.
class UserPreferencesUtils 
{
  static const _platformIOS = MethodChannel('dev.journeyers/iossaf'); 
  // TODO: to complete for Android

  
  /// Method used to avoid stale values by reloading
  Future<void> reload() async
  {
    final prefs = await SharedPreferences.getInstance();
    prefs.reload();
  }

  //**************** ACKNOWLEDGMENT MODAL ****************/
  /// Method used to record that the acknowledgment modal has been acknowledged.
  Future<void> saveInformationModalAcknowledgement() async 
  {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isInformationModalAcknowledged', true);
  }

  /// Method used to check if the acknowledgment modal has been acknowledged.
  Future<bool> isInformationModalAcknowledged() async 
  {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isInformationModalAcknowledged') ?? false;
  }

  /// Method used to reset the acknowledgment modal status
  void resetInformationModalStatus() async 
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
    String? folderPathData;

    if (Platform.isIOS)
      {
        folderPathData = await _platformIOS.invokeMethod('getStoredDirectory');
        print("******* Platform.isIOS: folderPathData: $folderPathData    **********");
      }
    else
    {
      final prefs = await SharedPreferences.getInstance();
      folderPathData = prefs.getString('applicationFolderPath') ?? "";
    }
    
    return Future.value(folderPathData);    
  }

  //**************** EXISTING SESSION DATA ? ****************/
  /// Method used to record that session data has been saved.
  Future<void> saveWasSessionDataSaved(bool value) async 
  {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('wasSessionDataSaved', value);
  }

  /// Method used to check if session data has been saved.
  Future<bool> wasSessionDataSaved() async 
  {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('wasSessionDataSaved') ?? false;
  }

  /// Method used to reset to false if session data has been saved.
  Future<bool> resetWasSessionDataSavedStatus() async 
  {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setBool('wasSessionDataSaved', false);
  }
}
