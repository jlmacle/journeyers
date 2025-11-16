import 'package:shared_preferences/shared_preferences.dart';


//                MATERIAL BANNER
Future<void> saveMaterialBannerDismissal() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('bannerDismissed', true);
}

Future<bool> isMaterialBannerDismissed() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('bannerDismissed') ?? false;
}
////////////////////////////////////////////////////
//                SNACKBAR
Future<void> saveStartMessageAcknowledgement() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('startMessageAcknowledged', true);
}

Future<bool> isStartMessageAcknowledged() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('startMessageAcknowledged') ?? false;
}
