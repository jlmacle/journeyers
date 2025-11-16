import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveDismissal() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('bannerDismissed', true);
}

Future<bool> isBannerDismissed() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('bannerDismissed') ?? false;
}
