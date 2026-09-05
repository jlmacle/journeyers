// ignore: file_names
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";

import "package:journeyers/app_themes.dart";
import "package:journeyers/debug_constants.dart";
import "package:journeyers/l10n/app_localizations.dart";
import "package:journeyers/l10n/localized_gps_strings.dart";
import "package:journeyers/pages/group_problem_solving/group_problem_solving_process_widgets/5_group_problem_solving_ideas_list.dart";
import "package:journeyers/utils/generic/dev/utility_classes_import.dart";

import "../../_widget_testing_utils/widget_testing_utils.dart";

void main() {
  Future<void> pumpGPSIdeasList(WidgetTester tester) async
  {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale(testingLocaleOption),
        home: Scaffold(
          body: GPSIdeasList
          (
            ideas: [],
          ),
        ),
      ),
    );
  }

  group("GPSIdeasList Tests: \n", () {  
    group("GPSIdeasList default aspect: \n", () {
      testWidgets("The correct title is present", 
      (WidgetTester tester) async 
      {
        // Pumping the widget
        await pumpGPSIdeasList(tester);
        await tester.pumpAndSettle();

        // Accessing the localized data
        var context = tester.element(find.byType(Scaffold).first);
        LocalizedGPSStrings lgps = .new(context);

        // ideasListTitle hard-coded strings
        var ideasListTitle = "";
        
        var localeLanguageCode = getLocaleLanguageCode(tester);

        switch(localeLanguageCode.toLowerCase())
        {
          case("en"): { ideasListTitle = "List of ideas"; }
          case("fr"): { ideasListTitle = "Liste des idées"; }        
        }
        if (testingDebug) pu.printd("Testing Debug: ideasListTitle: $ideasListTitle");

        // Verifying consistency between hard-coded string and localized string
        expect(ideasListTitle, lgps.ideasListTitle);     

        // Verifying the ideasListTitle present
        expect(find.text(lgps.ideasListTitle), findsOne);        
      });    

      testWidgets("The correct placeholder is present", 
      (WidgetTester tester) async 
      {
        // Pumping the widget
        await pumpGPSIdeasList(tester);

        // Accessing the localized data
        var context = tester.element(find.byType(Scaffold).first);
        LocalizedGPSStrings? lgps = .new(context);

        // ideasListPlaceholder hard-coded strings
        var ideasListPlaceholder = "";
        
        var localeLanguageCode = getLocaleLanguageCode(tester);

        switch(localeLanguageCode.toLowerCase())
        {
          case("en"): { ideasListPlaceholder = "No ideas added yet."; }
          case("fr"): { ideasListPlaceholder = "Liste d'idées vide"; }        
        }
        if (testingDebug) pu.printd("Testing Debug: ideasListPlaceholder: $ideasListPlaceholder");

        // Verifying consistency between hard-coded string and localized string
        expect(ideasListPlaceholder, lgps.ideasListPlaceholder);   

        // Verifying the placeholder present
        expect(find.text(lgps.ideasListPlaceholder), findsOne);        
      });    
    });

    group("GPSIdeasList overlay default aspect: \n", () {
      testWidgets("The correct appbar title is present", 
      (WidgetTester tester) async 
      {
        // Pumping the widget
        await pumpGPSIdeasList(tester);
        await tester.pumpAndSettle();

         // Accessing the localized data
        var context = tester.element(find.byType(Scaffold).first);
        LocalizedGPSStrings lgps = .new(context);

        // Tapping on the title
        await tester.tap(find.text(lgps.ideasListTitle));
        await tester.pumpAndSettle();

        // ideasListAppBarTitle hard-coded strings
        var ideasListAppBarTitle = "";
        
        var localeLanguageCode = getLocaleLanguageCode(tester);

        switch(localeLanguageCode.toLowerCase())
        {
          case("en"): { ideasListAppBarTitle = "List of ideas"; }
          case("fr"): { ideasListAppBarTitle = "Liste des idées"; }        
        }
        if (testingDebug) pu.printd("Testing Debug: ideasListAppBarTitle: $ideasListAppBarTitle");

        // Verifying consistency between hard-coded string and localized string
        expect(ideasListAppBarTitle, lgps.ideasListAppBarTitle);     

        // Verifying the ideasListAppBarTitle present
        expect(find.text(lgps.ideasListAppBarTitle), findsNWidgets(2));        
      });    

      testWidgets("The correct appbar foreground color is present", 
      /// "[foregroundColor], which specifies the color for icons and text within
      ///  the app bar."
      (WidgetTester tester) async 
      {
        // Pumping the widget
        await pumpGPSIdeasList(tester);
        await tester.pumpAndSettle();

        // Getting the localized strings
        var context = tester.element(find.byType(Scaffold).first);
        LocalizedGPSStrings lgps = .new(context);      

         // Tapping on the title
        await tester.tap(find.text(lgps.ideasListTitle));
        await tester.pumpAndSettle();

        // Verifying the color
        var iconButtonsFinder = find.byType(IconButton);
        var iconButtonWidget = tester.widget<IconButton>(iconButtonsFinder.last);            
        expect(iconButtonWidget.color, appBarWhite);        
      });          

      testWidgets("The correct text field placeholder is present", 
      (WidgetTester tester) async 
      {
        // Pumping the widget
        await pumpGPSIdeasList(tester);
        await tester.pumpAndSettle();

         // Accessing the localized data
        var context = tester.element(find.byType(Scaffold).first);
        LocalizedGPSStrings lgps = .new(context);

        // Tapping on the title
        await tester.tap(find.text(lgps.ideasListTitle));
        await tester.pumpAndSettle();

        // newIdeaTextFieldHint hard-coded strings
        var newIdeaTextFieldHint = "";
        
        var localeLanguageCode = getLocaleLanguageCode(tester);

        switch(localeLanguageCode.toLowerCase())
        {
          case("en"): { newIdeaTextFieldHint = "Please enter an idea."; }
          case("fr"): { newIdeaTextFieldHint = "Veuillez entrer une idée."; }        
        }
        if (testingDebug) pu.printd("Testing Debug: newIdeaTextFieldHint: $newIdeaTextFieldHint");

        // Verifying consistency between hard-coded string and localized string
        expect(newIdeaTextFieldHint, lgps.newIdeaTextFieldHint);     

        // Verifying the newIdeaTextFieldHint present
        expect(find.text(lgps.newIdeaTextFieldHint), findsOne);        
      });    

    });
  });
}