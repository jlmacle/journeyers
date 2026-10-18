
import "dart:io";

import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";

import "package:journeyers/debug_constants.dart";
import "package:journeyers/utils/generic/dev/utility_classes_import.dart";
import "package:journeyers/utils/generic/testing/test_utils.dart";

/// A method getting a locale language code for a widget test.
String getLocaleLanguageCode(WidgetTester tester)
{
  var context = tester.element(find.byType(Scaffold).first);
  Locale? currentLocale = (Localizations.localeOf(context));
  var localeLanguageCode = currentLocale.languageCode;

  logt("operatingSystem", Platform.operatingSystem);
  logt("localeLanguageCode", localeLanguageCode);
  
  return localeLanguageCode;
}
