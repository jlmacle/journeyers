// ignore: file_names

import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";

import "package:journeyers/debug_constants.dart";
import "package:journeyers/l10n/app_localizations.dart";
import "package:journeyers/l10n/localized_gps_strings.dart";
import "package:journeyers/pages/group_problem_solving/group_problem_solving_process_widgets/1_group_problem_solving_problem_to_solve_declaration.dart";
import "package:journeyers/pages/group_problem_solving/group_problem_solving_process_widgets/3_group_problem_solving_checklist.dart";
import "package:journeyers/pages/group_problem_solving/group_problem_solving_process_widgets/4_group_problem_solving_keywords_declaration.dart";
import "package:journeyers/pages/group_problem_solving/group_problem_solving_process_widgets/5_group_problem_solving_ideas_list.dart";
import "package:journeyers/pages/group_problem_solving/group_problem_solving_process_widgets/6_group_problem_solving_new_idea.dart";
import "package:journeyers/pages/group_problem_solving/group_problem_solving_process_widgets/_group_problem_solving_externalized_variables.dart";
import "package:journeyers/utils/generic/dev/utility_classes_import.dart";
import "package:journeyers/widgets/utility/process/session_file_name_on_mobile_platforms.dart";

import "../../_widget_testing_utils/widget_testing_utils.dart";

void main() {
    Future<void> pumpGPSProblemToSolveDeclaration(WidgetTester tester) async
    {
      var tfec = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale(testingLocaleOption),
          home: Scaffold(
            body: GPSProblemToSolveDeclaration
            (
              sessionTitleTec: tfec,
              caPreviousSessions: const [],
              onTitleModified: () {},
              onSessionSelected: (_){},
              onTitleTapped: (){},
              onTextFieldLosingFocus: (){},
            ),
          ),
        ),
      );
    }

    group("GPSProblemToSolveDeclaration Tests: \n", () {  
      group("Default values: \n", () { 
          testWidgets("Correct default title value", 
          (WidgetTester tester) async 
          {
            // Pumping the widget
            await pumpGPSProblemToSolveDeclaration(tester);

            // Getting the localized strings
            var context = tester.element(find.byType(Scaffold).first);
            LocalizedGPSStrings lgps = .new(context);
            
            // Default title hard-coded strings
            var defaultTitle = "";
            
            var localeLanguageCode = getLocaleLanguageCode(tester);

            switch(localeLanguageCode.toLowerCase())
            {
              case("en"): { defaultTitle = "Problem To Solve"; }
              case("fr"): { defaultTitle = "Problème à résoudre"; }        
            }
            if (testingDebug) pu.printd("Testing Debug: defaultTitle: $defaultTitle");

            // Verifying consistency between hard-coded string and localized string
            expect(defaultTitle, lgps.gpsDefaultProcessSessionTitle);     

            // Verifying the default title present
            expect(find.text(lgps.gpsDefaultProcessSessionTitle), findsOneWidget);
          }
          );

          testWidgets("Correct text field hint", 
          (WidgetTester tester) async 
          {
            // Pumping the widget
            await pumpGPSProblemToSolveDeclaration(tester);

            // Getting the localized strings
            var context = tester.element(find.byType(Scaffold).first);
            LocalizedGPSStrings lgps = .new(context);
            
            // Default title hard-coded strings
            var defaultTitle = "";
            // Default text field hint hard-coded strings
            var defaultTextFieldHint = "";
            
            var localeLanguageCode = getLocaleLanguageCode(tester);

            switch(localeLanguageCode.toLowerCase())
            {
              case("en"): 
              { 
                defaultTitle = "Problem To Solve";
                defaultTextFieldHint = "Please enter a title or select below."; 
              }
              case("fr"): 
              { 
                defaultTitle = "Problème à résoudre";
                defaultTextFieldHint = "Veuillez entrer un titre ou en choisir un ci-dessous, si disponible."; 
              }        
            }
            if (testingDebug) pu.printd("Testing Debug: defaultTitle: $defaultTitle");
            if (testingDebug) pu.printd("Testing Debug: defaultTextFieldHint: $defaultTextFieldHint");

            // Verifying consistency between hard-coded strings and localized strings
            expect(defaultTitle, lgps.gpsDefaultProcessSessionTitle); 
            expect(defaultTextFieldHint, lgps.gpsProcessTitleTextFieldHint);   

            // Tapping on the default title
            var titleFinder = find.text(defaultTitle);
            await tester.tap(titleFinder);
            await tester.pumpAndSettle();  

            // Verifying the text field hint present
            expect(find.text(lgps.gpsProcessTitleTextFieldHint), findsOneWidget);
          }
          );
      });
        
      group("Click toward text field: \n", () { 
          testWidgets("Clicking on the title reveals a text field", 
          (WidgetTester tester) async 
          {
            // Pumping the widget
            await pumpGPSProblemToSolveDeclaration(tester);

            // Verifying the text field absent
            expect(find.byType(TextField), findsNothing);

            // Default title hard-coded strings
            var defaultTitle = "";
            
            var localeLanguageCode = getLocaleLanguageCode(tester);

            switch(localeLanguageCode.toLowerCase())
            {
              case("en"): { defaultTitle = "Problem To Solve"; }
              case("fr"): { defaultTitle = "Problème à résoudre"; }        
            }
            if (testingDebug) pu.printd("Testing Debug: defaultTitle: $defaultTitle");

            // Getting the default title finder
            var titleFinder = find.text(defaultTitle);

            // Clicking on the default title
            await tester.tap(titleFinder);
            await tester.pumpAndSettle();

            // Verifying the text field present
            expect(find.byType(TextField), findsOne);
          }
          );
      
          testWidgets("Clicking on the edit emoji reveals a text field", 
          (WidgetTester tester) async 
          {
            // Pumping the widget
            await pumpGPSProblemToSolveDeclaration(tester);

            // Verifying the text field absent
            expect(find.byType(TextField), findsNothing);

            // Getting the edit emoji
            var emojiFinder = find.text(editEmoji);

            // Clicking on the emoji
            await tester.tap(emojiFinder);
            await tester.pumpAndSettle();

            // Verifying the text field present
            expect(find.byType(TextField), findsOne);
          }
          );      
      });

      group("Display: \n", () { 
          testWidgets("Clicking on the title removes all other widgets", 
          (WidgetTester tester) async 
          {
            // Pumping the widget
            await pumpGPSProblemToSolveDeclaration(tester);

            // Default title hard-coded strings
            var defaultTitle = "";
            
            var localeLanguageCode = getLocaleLanguageCode(tester);

            switch(localeLanguageCode.toLowerCase())
            {
              case("en"): { defaultTitle = "Problem To Solve"; }
              case("fr"): { defaultTitle = "Problème à résoudre"; }        
            }
            if (testingDebug) pu.printd("Testing Debug: defaultTitle: $defaultTitle");

            // Clicking on the default title
            var titleFinder = find.text(defaultTitle);            
            await tester.tap(titleFinder);
            await tester.pumpAndSettle();

            // Verifying the other widgets absent
            expect(find.text(addEmoji), findsNothing);
            expect(find.byType(GPSChecklist), findsNothing);
            expect(find.text(editEmoji), findsNothing);         
            expect(find.byType(GPSKeywordsDeclaration), findsNothing);
            expect(find.byType(GPSIdeasList), findsNothing);
            expect(find.byType(GPSNewIdea), findsNothing);
            expect(find.byType(SessionFileNameOnMobilePlatforms), findsNothing);
          });
      });
    });
}