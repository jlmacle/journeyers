// ignore: file_names
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:journeyers/debug_constants.dart";
import "package:journeyers/l10n/app_localizations.dart";

import "package:journeyers/l10n/localized_gps_strings.dart";
import "package:journeyers/pages/group_problem_solving/group_problem_solving_process_widgets/3_group_problem_solving_checklist.dart";
import "package:journeyers/pages/group_problem_solving/group_problem_solving_process_widgets/_group_problem_solving_externalized_variables.dart";
import "package:journeyers/utils/generic/dev/utility_classes_import.dart";

import "../../../integration_test/externalized_code/externalized_testing_code.dart";
import "../../_widget_testing_utils/widget_testing_utils.dart";

void main() 
{
  Future<void> pumpGPSChecklist(WidgetTester tester) async
  {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale(testingLocaleOption),
        home: Scaffold(
          body: GPSChecklist(),
        ),
      ),
    );
  }

  group("GPSChecklist Tests: \n", 
  () 
  {  
    group("GPSChecklist default aspect: \n", 
    () 
    { 
      testWidgets("The default rectangle color is orange", 
      (WidgetTester tester) async 
      {
        // Pumping the widget
        await pumpGPSChecklist(tester);

        // Verifying the default rectangle color is orange
        await gpsTestChecklistTitleBorderColor(tester, rectangleColor);
      });          
      

      testWidgets("The correct title is present", 
      (WidgetTester tester) async 
      {
        // Pumping the widget
        await pumpGPSChecklist(tester);

        // Getting the localized strings
        var context = tester.element(find.byType(Scaffold).first);
        LocalizedGPSStrings lgps = .new(context);

        // Default title hard-coded strings
        var defaultTitle = "";
        
        var localeLanguageCode = getLocaleLanguageCode(tester);

        switch(localeLanguageCode.toLowerCase())
        {
          case("en"): { defaultTitle = "Checklist"; }
          case("fr"): { defaultTitle = "Check-list"; }        
        }
        if (testingDebug) pu.printd("Testing Debug: defaultTitle: $defaultTitle");

        // Verifying consistency between hard-coded string and localized string
        expect(defaultTitle, lgps.checkListTitle);

        // Verifying the title present
        expect(find.text(lgps.checkListTitle), findsOne);        
      });  

    });        
    
    });
  
}