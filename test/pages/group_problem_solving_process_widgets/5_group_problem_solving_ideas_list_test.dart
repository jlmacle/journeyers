// ignore: file_names
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";

import "package:journeyers/l10n/app_localizations.dart";
import "package:journeyers/l10n/localized_gps_strings.dart";
import "package:journeyers/pages/group_problem_solving/group_problem_solving_process_widgets/5_group_problem_solving_ideas_list.dart";

void main() 
{
  Future<void> pumpGPSIdeasList(WidgetTester tester) async
  {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: GPSIdeasList
          (
            ideas: [],
          ),
        ),
      ),
    );
  }

  group("GPSIdeasList Tests: \n", 
  () 
  {  
    group("GPSIdeasList default aspect: \n", 
    () 
    {
      // "The title is present"
      testWidgets("The title is present", 
      (WidgetTester tester) async 
      {
        // Pumping the widget
        await pumpGPSIdeasList(tester);
        await tester.pumpAndSettle();

        // Accessing the localized data
        var context = tester.element(find.byType(Scaffold).first);
        LocalizedGPSStrings lgps = .new(context);

        // Verifying the title present
        expect(find.text(lgps.ideasListTitle), findsOne);        
      });    

      // "The placeholder is present"
      testWidgets("The placeholder is present", 
      (WidgetTester tester) async 
      {
        // Pumping the widget
        await pumpGPSIdeasList(tester);

        // Accessing the localized data
        var context = tester.element(find.byType(Scaffold).first);
        LocalizedGPSStrings? lgps = .new(context);

        // Verifying the placeholder present
        expect(find.text(lgps.ideasListPlaceholder), findsOne);        
      });          
    
    });
  });
}