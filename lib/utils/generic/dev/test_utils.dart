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
/// A method used to print all Text widgets data.
void printTextData(WidgetTester tester)
{
    var textsFinder = find.byType(Text);
    for (var i= 0 ; i < textsFinder.evaluate().length; i++)
    {
      var textFinder = textsFinder.at(i);
      var textWidget = tester.widget<Text>(textFinder);
      if (testingDebug) pu.printd("Testing Debug: textWidget.data: ${textWidget.data}");
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
    if (testingDebug) pu.printd("Testing Debug: CircularProgressIndicator present");
  }
  else
  {
    if (testingDebug) pu.printd("Testing Debug: CircularProgressIndicator absent");
  }

}