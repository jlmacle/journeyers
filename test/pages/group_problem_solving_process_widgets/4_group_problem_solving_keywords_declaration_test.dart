// ignore: file_names
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";

import "package:journeyers/debug_constants.dart";
import "package:journeyers/l10n/app_localizations.dart";
import "package:journeyers/l10n/localized_gps_strings.dart";
import "package:journeyers/pages/group_problem_solving/group_problem_solving_process_widgets/4_group_problem_solving_keywords_declaration.dart";
import "package:journeyers/utils/generic/dev/utility_classes_import.dart";

import "../../_widget_testing_utils/widget_testing_utils.dart";

void main() 
{
  Future<void> pumpGPSKeywordsDeclaration(WidgetTester tester) async
  {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: GPSKeywordsDeclaration
          (
            currentKeywords: const {},
            onKeywordsUpdatedCallbackFunction: (_){},
          ),
        ),
      ),
    );
  }

  group("GPSKeywordsDeclaration Tests: \n", 
  () 
  {  
    group("GPSKeywordsDeclaration default aspect: \n", 
    () 
    {
      testWidgets("The correct title is present", 
      (WidgetTester tester) async 
      {
        // Pumping the widget
        await pumpGPSKeywordsDeclaration(tester);

        // Getting the localized strings
        var context = tester.element(find.byType(Scaffold).first);
        LocalizedGPSStrings lgps = .new(context);
        
        // Title hard-coded strings
        var keywordsTitle = "";
        
        var localeLanguageCode = getLocaleLanguageCode(tester);

        switch(localeLanguageCode.toLowerCase())
        {
          case("en"): { keywordsTitle = "Keywords"; }
          case("fr"): { keywordsTitle = "Mots-clés"; }        
        }
        if (testingDebug) pu.printd("Testing Debug: defaultTitle: $keywordsTitle");

        // Verifying consistency between hard-coded string and localized string
        expect(keywordsTitle, lgps.gpsKeywordsTitle);     


        // Verifying the title present
        expect(find.text(keywordsTitle), findsOne);        
      });          
    
      testWidgets("The correct appbar title is present", 
      (WidgetTester tester) async 
      {
        // Pumping the widget
        await pumpGPSKeywordsDeclaration(tester);
        await tester.pumpAndSettle();

        // Getting the localized strings
        var context = tester.element(find.byType(Scaffold).first);
        LocalizedGPSStrings lgps = .new(context);
        
        // Appbar title hard-coded strings
        var keywordsAppBarTitle = "";
        
        var localeLanguageCode = getLocaleLanguageCode(tester);

        switch(localeLanguageCode.toLowerCase())
        {
          case("en"): 
          { 
            keywordsAppBarTitle = "Keywords for the\nproblem-solving session"; 
          }
          case("fr"): 
          { 
            keywordsAppBarTitle = "Mots-clés pour la\nsession de résolution du problème"; 
          }        
        }
        if (testingDebug) pu.printd("Testing Debug: defaultTitle: $keywordsAppBarTitle");

        // Tapping to open the overlay
        var keywordsTitleFinder = find.text(lgps.gpsKeywordsTitle);
        await tester.tap(keywordsTitleFinder);
        await tester.pumpAndSettle();

        // Verifying consistency between hard-coded string and localized string
        expect(keywordsAppBarTitle, lgps.gpsKeywordsOverlayAppbarTitle);

        // Verifying the appbar title present
        expect(find.text(lgps.gpsKeywordsOverlayAppbarTitle), findsOne);        
      });          
    
    });
  });
}