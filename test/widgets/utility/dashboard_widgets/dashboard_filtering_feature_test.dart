import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journeyers/utils/generic/dashboard/dashboard_utils.dart';
import 'package:journeyers/utils/project_specific/dashboard/dashboard_strings.dart';

import 'package:journeyers/widgets/utility/dashboard_widgets/dashboard_filtering_feature.dart';
import 'package:journeyers/widgets/utility/dashboard_widgets/dashboard_sorting_by_date.dart';
import 'package:journeyers/widgets/utility/dashboard_widgets/dashboard_sorting_by_title.dart';
import 'package:journeyers/widgets/utility/dashboard_widgets/dashboard_filtering_by_keywords.dart';

void main() {
  group('DashboardFilteringFeature Widget Tests:\n', () {
    late GlobalKey<DashboardFilteringByKeywordsState> testKey;
    late List<String> usedKeywords;
    late List<String> selectedKeywords;
    late List<dynamic> allSessions;
    late List<dynamic> filteredSessions;

    setUp(() {
      testKey = GlobalKey<DashboardFilteringByKeywordsState>();
      usedKeywords = ['Flutter', 'Dart', 'Testing'];
      selectedKeywords = [];
      allSessions = [{'title': 'A'}, {'title': 'B'}];
      filteredSessions = [{'title': 'A'}];
    });

    // Helper to wrap the widget under test
    Widget createWidgetUnderTest() {
      return MaterialApp(
        home: Scaffold(
          body: DashboardFilteringFeature(
            dashboardContext: DashboardUtils.contextAnalysesContext,
            allSessions: allSessions,
            filteredSessions: filteredSessions,
            usedKeywords: usedKeywords,
            selectedKeywords: selectedKeywords,
            parentCallbackFunctionToRefreshTheSessionsList: () {},
            dashboardFilteringByKeywordsKey: testKey,
          ),
        ),
      );
    }

    testWidgets('renders all sub-components and title text', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Checks for the children and pre-defined labels 
      // sorting by Title
      expect(find.byType(DashboardSortingByTitle), findsOneWidget);
      // String interpolation used for the text
      expect(find.textContaining(sortByTitleLabel), findsOneWidget);

      // sorting by Date
      expect(find.byType(DashboardSortingByDate), findsOneWidget);
      expect(find.text(sortByDateLabel), findsOneWidget);

      // filtering by keywords
      expect(find.byType(DashboardFilteringByKeywords), findsOneWidget);
      expect(find.text(filterByKeywordsLabel), findsOneWidget);     
    });

    testWidgets('wraps sorting widgets inside a Wrap widget', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Checks for Wrap widget
      final wrapFinder = find.byType(Wrap).first;
      expect(wrapFinder, findsOneWidget);

      // Verifies sorting widgets are children of the Wrap
      expect(
        find.descendant(of: wrapFinder, matching: find.byType(DashboardSortingByTitle)),
        findsOneWidget,
      );
    });


    testWidgets('Scrollview is present with correct key', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final scrollviewFinder = find.byKey(const Key('dashboard-scrollview'));
      expect(scrollviewFinder, findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });
}