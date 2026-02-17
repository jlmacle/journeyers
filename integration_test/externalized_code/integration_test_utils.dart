
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:journeyers/core/utils/printing_and_logging/print_utils.dart';

PrintUtils _pu = PrintUtils();

/// Method used to list all the sessions titles
Future<List<String>> getSessionsTitlesList({required WidgetTester tester, required sessionData, required keyRoot}) async
{
  List<String> sessionsTitlesList = [];
  String currentTitle = "";

  for (int index = 0; index < sessionData.length; index++) 
  {
    // Getting the finder
    final titleFinder = find.byKey(ValueKey('$keyRoot$index'));
      // To have all the elements visible, therefore all the titles accessed
    await tester.ensureVisible(titleFinder); 
    await tester.pump();
    
    // Verifying the finder existence to get the loading complete
    expect(titleFinder, findsOneWidget);

    // Extracting the actual widget instance from the tester
    final Text titleWidget = tester.widget(titleFinder);            

    //Accessing the widget properties
    currentTitle = titleWidget.data!;
    sessionsTitlesList.add(currentTitle);
    _pu.printd('Title: ${titleWidget.data}');
  }
  return sessionsTitlesList;
}

/// Method used to test if the test data titles are already present in the pre-test sessions titles
bool isThereATestDataTitleDuplicated({
  required List<String> listOfSessionTitles, 
  required List<String> listOfTestDataTitles,
}) {
  return listOfTestDataTitles.any((String title) {
    final int occurrences = listOfSessionTitles
        .where((String s) => s == title)
        .length;
        
    return occurrences >= 2;
  });
}

/// Method used to scroll up the screen (-200 as default delta to go up the list)
Future<int> scrollListUpScreen({required WidgetTester tester, required Finder listFinder, required elementToReachFinder , double delta = -200}) async
{
  await tester.scrollUntilVisible
  (
    elementToReachFinder, 
    -200 , // getting back up the list
    scrollable:find.descendant
    (
      of: listFinder,
      matching: find.byType(Scrollable),
    )
  );
  return await tester.pumpAndSettle(); 
}