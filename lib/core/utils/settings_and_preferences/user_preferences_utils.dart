import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveStartMessageAcknowledgement() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('isDialogStartMessageAcknowledged', true);
}

Future<bool> isStartMessageAcknowledged() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('isDialogStartMessageAcknowledged') ?? false;
}
