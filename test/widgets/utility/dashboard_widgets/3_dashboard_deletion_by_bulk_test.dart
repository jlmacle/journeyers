import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:journeyers/app_themes.dart';
import 'package:journeyers/utils/generic/dashboard/dashboard_utils.dart';
import 'package:journeyers/widgets/utility/dashboard_widgets/3_dashboard_deletion_by_bulk.dart';


void main() {
  // Test metadata
  final sessionsMetadata = [
    {DashboardUtils.keyTitle: 'Session 1', DashboardUtils.keyFilePath: 'path/1'},
    {DashboardUtils.keyTitle: 'Session 2',  DashboardUtils.keyFilePath: 'path/2', },
  ];

  List<dynamic>? allSessions;
  List<dynamic>? filteredSessions;
  List<dynamic>? sessionsSelected;

  setUp(() {
    allSessions = List.from(sessionsMetadata);
    filteredSessions = List.from(sessionsMetadata);
    sessionsSelected = ['path/1']; // Session selected by default
  });

  Widget createWidgetUnderTest({
    bool areSessionsForDeletion = true,
    String context = DashboardUtils.caContext,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: DashboardDeletionByBulk(
          dashboardContext: context,
          areSessionsForDeletion: areSessionsForDeletion,
          allSessions: allSessions!,
          filteredSessions: filteredSessions!,
          sessionsSelectedForDeletion: sessionsSelected!,
          dashboardCallbackFunctionToRefreshTheSessionsList: () {},
        ),
      ),
    );
  }

  group('DashboardDeletionByBulk UI Tests', () {

    testWidgets('Empty selection color is transparent', (WidgetTester tester) async 
    {
        sessionsSelected = [];
        await tester.pumpWidget(createWidgetUnderTest(areSessionsForDeletion: false));

        // Checks the delete icon is transparent
        var iconDeleteFinder = find.byIcon(Icons.delete).first;
        Icon deleteIcon = tester.widget(iconDeleteFinder);
        expect(deleteIcon.color, transparent);

        // Checks if the label is transparent
        var textDeleteFinder = find.byType(Text).first;
        Text textDelete = tester.widget(textDeleteFinder);
        expect(textDelete.style?.color, transparent);
      });
    });

    testWidgets('Non empty selection has "Delete (n)" in label, and color is red', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      var textDeleteFinder = find.byType(Text).first;
      Text textDelete = tester.widget(textDeleteFinder);

      // Checks if the label displays the correct count from sessionsSelected
      expect(textDelete.data, 'Delete (1)');
      // Checks if the label is red
      expect(textDelete.style?.color, red);
      
      // Checks the delete icon is red
      var iconDeleteFinder = find.byIcon(Icons.delete).first;
      Icon deleteIcon = tester.widget(iconDeleteFinder);
      expect(deleteIcon.color, red);
    });     
}