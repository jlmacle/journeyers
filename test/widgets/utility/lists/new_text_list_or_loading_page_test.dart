import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";

import "package:journeyers/widgets/utility/lists/new_text_list_or_loading_page.dart";

void main() {

  Future<void> pumpTestableWidget(WidgetTester tester)
  {
    // Building the widget
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NewTextListOrLoadingPage
          (
            onParticipantsLoadedCallbackFunction: (_) {},
          ),
        ),
      ),
    );    
  }

  group("NewTextListOrLoadingPage Tests: \n", () 
  {
    // "Participants Lists Options Page: correct title"
    testWidgets("Participants Lists Options Page: correct title", 
    (WidgetTester tester) async 
    {
      // Pumping the widget
      await pumpTestableWidget(tester);
      await tester.pumpAndSettle();

      // Verifying the correct title present
      var textFinder = find.text("Participants lists");
      expect(textFinder, findsOne);      
    }); 
    
    // "Participants Lists Options Page: correct subtitle"
    testWidgets("Participants Lists Options Page: correct subtitle", 
    (WidgetTester tester) async 
    {
      // Pumping the widget
      await pumpTestableWidget(tester);
      await tester.pumpAndSettle();

      // Verifying the correct subtitle present
      var textFinder = find.text("What would you like to do?");
      expect(textFinder, findsOne);     
    }); 

    // "Participants Lists Options Page: correct option 1 label"
    testWidgets("Participants Lists Options Page: correct option 1 label", 
    (WidgetTester tester) async 
    {
      // Pumping the widget
      await pumpTestableWidget(tester);
      await tester.pumpAndSettle();

      // Verifying the correct option 1 label
      var textFinder = find.text("To load the list\nof previous groups?");
      expect(textFinder, findsOne);    
    }); 
    
    // "Participants Lists Options Page: correct option 2 label"
    testWidgets("Participants Lists Options Page: correct option 2 label", 
    (WidgetTester tester) async 
    {
      // Pumping the widget
      await pumpTestableWidget(tester);
      await tester.pumpAndSettle();

      // Verifying the correct option 2 label
      var textFinder = find.text("To add a new group?");
      expect(textFinder, findsOne);   
    }); 
    
  }
);  

}