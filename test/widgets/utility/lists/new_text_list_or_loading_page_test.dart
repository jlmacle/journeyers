import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:journeyers/widgets/utility/lists/new_text_list_or_loading_page.dart';

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

  group('NewTextListOrLoadingPage Tests: \n', () 
  {
    // 'Participants Lists Options Page: correct title'
    testWidgets('Participants Lists Options Page: correct title', 
    (WidgetTester tester) async 
    {
      // Pumping the widget
      await pumpTestableWidget(tester);

      // Verifying the correct title present
      var textFinder = find.text('Participants lists');
      expect(textFinder, findsOne);      
    }
    );    
  }
);  

}