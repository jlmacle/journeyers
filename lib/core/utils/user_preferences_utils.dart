import 'package:shared_preferences/shared_preferences.dart';


//                MATERIAL BANNER (Kept for educational purposes)
Future<void> saveMaterialBannerDismissal() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('bannerDismissed', true);
}

Future<bool> isMaterialBannerDismissed() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('bannerDismissed') ?? false;
}
////////////////////////////////////////////////////
//                SNACKBAR (Kept for educational purposes)
Future<void> saveStartSnackbarMessageAcknowledgement() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('startSnackbarMessageAcknowledged', true);
}

Future<bool> isStartSnackbarMessageAcknowledged() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('startSnackbarMessageAcknowledged') ?? false;
}

////////////////////////////////////////////////////
//              CONTAINER
Future<void> saveStartMessageAcknowledgement() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('startMessageAcknowledged', true);
}

Future<bool> isStartMessageAcknowledged() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('startMessageAcknowledged') ?? false;
}