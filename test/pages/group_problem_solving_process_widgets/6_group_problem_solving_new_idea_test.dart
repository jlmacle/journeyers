// ignore: file_names
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";

import "package:journeyers/debug_constants.dart";
import "package:journeyers/l10n/app_localizations.dart";
import "package:journeyers/l10n/localized_gps_strings.dart";
import "package:journeyers/pages/group_problem_solving/group_problem_solving_process_widgets/6_group_problem_solving_new_idea.dart";

void main() 
{
  Future<void> pumpGPSNewIdea(WidgetTester tester) async
  {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale(testingLocaleOption),
        home: Scaffold(
          body: GPSNewIdea
          (
            newIdeaOnAddedCallbackFunction: (_){},
          ),
        ),
      ),
    );
  }

  group("GPSNewIdea Tests: \n", 
  () 
  {  
    group("GPSNewIdea default aspect: \n", 
    () 
    {      
      // "The hint text is present"
      testWidgets("The hint text is present", 
      (WidgetTester tester) async 
      {
        // Pumping the widget
        await pumpGPSNewIdea(tester);

        // Getting the localized strings
        var context = tester.element(find.byType(Scaffold).first);
        LocalizedGPSStrings lgps = .new(context);

        // Verifying the hint text present
        expect(find.text(lgps.newIdeaTextFieldHint), findsOne);        
      });          
    
    });
  });
}