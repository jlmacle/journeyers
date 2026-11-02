import "dart:io";

import "package:flutter_test/flutter_test.dart";
import "package:material_ui/material_ui.dart";

import "package:journeyers/utils/generic/testing/test_utils.dart";

/// A method getting a locale language code for a widget test.
String getLocaleLanguageCode(WidgetTester tester) {
  var context = tester.element(find.byType(Scaffold).first);
  Locale? currentLocale = (Localizations.localeOf(context));
  var localeLanguageCode = currentLocale.languageCode;

  logt("operatingSystem", Platform.operatingSystem);
  logt("localeLanguageCode", localeLanguageCode);

  return localeLanguageCode;
}
