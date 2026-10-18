
import "dart:io";

import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";

import "package:journeyers/debug_constants.dart";
import "package:journeyers/utils/generic/dev/utility_classes_import.dart";

import "package:path_provider_platform_interface/path_provider_platform_interface.dart";

/// {@category Utils - Generic}
/// A generic utility class used to define a folder value for getApplicationSupportPath (PathProvider) when testing.
class PathProviderPlatformRedirectForTesting extends PathProviderPlatform {
  PathProviderPlatformRedirectForTesting(this._path);

  final String _path;

  @override
  Future<String?> getApplicationSupportPath() async => _path;
}

/// {@category Utils - Generic}
/// A getter to test if a test is being run.
bool get isInTestEnvironment =>
    WidgetsBinding.instance.runtimeType.toString().contains("Test");

/// {@category Utils - Generic}
/// A method used to get a locale language code for a widget test.
String getLocaleLanguageCode2(WidgetTester tester)
{
  var context = tester.element(find.byType(Scaffold).first);
  Locale? currentLocale = (Localizations.localeOf(context));
  var localeLanguageCode = currentLocale.languageCode;

  logt("operatingSystem", Platform.operatingSystem);  
  logt("localeLanguageCode", localeLanguageCode);

  return localeLanguageCode;
}

/// {@category Utils - Generic}
/// A method used to verify that text on-screen is consistent with what was expected.
void verifyTextOnScreen(WidgetTester tester, String varName, Map<String,String> expectedTexts, String onScreenValue)
{
  var localeLanguageCode = getLocaleLanguageCode2(tester);

  var expectedText = "";

  switch(localeLanguageCode.toLowerCase())
  {
    case("en"): 
    { 
      expectedText = expectedTexts["en"] ?? "";
    }
    case("fr"): 
    { 
      expectedText = expectedTexts["fr"] ?? "";                
    }              
  }

  logt(varName, expectedText);

  // Verifying consistency between hard-coded string and localized string
  expect(onScreenValue, expectedText);
}


/// {@category Utils - Generic}
/// A method used to print all Text widgets data.
void printTextData(WidgetTester tester)
{
    var textsFinder = find.byType(Text);
    for (var i= 0 ; i < textsFinder.evaluate().length; i++)
    {
      var textFinder = textsFinder.at(i);
      var textWidget = tester.widget<Text>(textFinder);

      logt("textWidget.data", textWidget.data);
    }
}

/// {@category Utils - Generic}
/// A method used to test if a CircularProgressIndicator is present.
void isCircularProgressIndicatorPresent(WidgetTester tester)
{
  var circularProgressIndicatorFinder = find.byType(CircularProgressIndicator);
  bool isPresent = ( circularProgressIndicatorFinder.evaluate().isNotEmpty );
  if(isPresent)
  {
    logt("CircularProgressIndicator present");
  }
  else
  {
    logt("CircularProgressIndicator absent");
  }

}

/// {@category Utils - Generic}
/// A method used to print a total number of candidates for those that meet the requirements set by the finder.
  int printFinderTotal(Finder finder, String label)
  {
    int totalFinder = finder.evaluate().length;
    logt("Number of candidates for $label", totalFinder);
    return totalFinder;
  }


/// {@category Utils - Generic}
/// A method used to log data related to the testingDebug boolean.
/// logt(msg); -> Testing Debug: "msg"
/// logt(msg, anExpressionFResult);  -> Testing Debug: "msg": anExpressionFResult
void logt(String msg, [ Object? anExpressionResult ])
{
  if (anExpressionResult == null) {
    if (testingDebug) pu.printd("Testing Debug: $msg");
  }
  else{
    if (testingDebug) pu.printd("Testing Debug: $msg: $anExpressionResult");
  }  
}

/// {@category Utils - Generic}
/// A method used to log data related to the sessionMetadataDebug boolean.
/// logm(msg); -> Session Metadata: "msg"
/// logm(msg, anExpressionFResult);  -> Session Metadata: "msg": anExpressionFResult
void logm(String msg, [ Object? anExpressionResult ])
{
  if (anExpressionResult == null) {
    if (sessionMetadataDebug) pu.printd("Session Metadata: $msg");
  }
  else{
    if (sessionMetadataDebug) pu.printd("Session Metadata: $msg: $anExpressionResult");
  }  
}
