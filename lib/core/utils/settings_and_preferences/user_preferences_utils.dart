import 'package:shared_preferences/shared_preferences.dart';

/// {@category Utils}
/// A utility class related to user preferences.
class UserPreferencesUtils 
{
  /// Method used to record that the start message has been acknowledged.
  Future<void> saveStartMessageAcknowledgement() async 
  {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDialogStartMessageAcknowledged', true);
  }

  /// Method used to check if the start message has been acknowledged.
  Future<bool> isStartMessageAcknowledged() async 
  {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isDialogStartMessageAcknowledged') ?? false;
  }

  /// Method used to record that session data has been saved.
  Future<void> saveSessionDataHasBeenSaved() async 
  {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('wasSessionDataSaved', true);
  }

  /// Method used to check if session data has been saved.
  Future<bool> wasSessionDataSaved() async 
  {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('wasSessionDataSaved') ?? false;
  }
}
