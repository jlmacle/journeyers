import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:journeyers/utils/generic/dashboard/dashboard_utils.dart";
import "package:journeyers/widgets/utility/dashboard/dashboard_widgets/dashboard_const_strings.dart";

import "package:journeyers/widgets/utility/dashboard/dashboard_widgets/2_dashboard_filtering_and_sorting_feature.dart";
import "package:journeyers/widgets/utility/dashboard/dashboard_widgets/2b_dashboard_sorting_by_date.dart";
import "package:journeyers/widgets/utility/dashboard/dashboard_widgets/2a_dashboard_sorting_by_title.dart";
import "package:journeyers/widgets/utility/dashboard/dashboard_widgets/2c_dashboard_filtering_by_keywords.dart";

void main() {
  group("DashboardFilteringFeature Widget Tests: \n", () {
    GlobalKey<DashboardFilteringByKeywordsState>? testKey;
    List<String>? keywordsAll;
    List<String>? keywordsSelected;
    List<dynamic>? sessionsMetadataAll;
    List<dynamic>? sessionsMetadataFiltered;

    setUp(() {
      testKey = GlobalKey<DashboardFilteringByKeywordsState>();
      keywordsAll = ["Flutter", "Dart", "Testing"];
      keywordsSelected = [];
      sessionsMetadataAll = [{"title": "A"}, {"title": "B"}];
      sessionsMetadataFiltered = [{"title": "A"}];
    });

    // Helper to wrap the widget under test
    Widget createWidgetUnderTest() {
      return MaterialApp(
        home: Scaffold(
          body: DashboardSortingAndFilteringFeature(
            dashboardContext: DashboardUtils.caContext,
            sessionsMetadataAll: sessionsMetadataAll,
            sessionsMetadataFiltered: sessionsMetadataFiltered,
            keywordsAll: keywordsAll!,
            keywordsSelected: keywordsSelected!,
            parentCallbackFunctionToRefreshTheSessionsList: () {},
            dashboardFilteringByKeywordsKey: testKey!,
          ),
        ),
      );
    }

    testWidgets("Renders all sub-components labels and title text", (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Checks for the children and pre-defined labels 
      // sorting by title
      expect(find.byType(DashboardSortingByTitle), findsOneWidget);
      // String interpolation used for the text
      expect(find.textContaining(sortByTitle), findsOneWidget);

      // sorting by date
      expect(find.byType(DashboardSortingByDate), findsOneWidget);
      expect(find.text(sortByDate), findsOneWidget);

      // filtering by keywords
      expect(find.byType(DashboardFilteringByKeywords), findsOneWidget);
      expect(find.text(filterByKeywordsLabel), findsOneWidget);     
    });

    testWidgets("Wraps sorting widgets inside a Wrap widget", (WidgetTester tester) async {
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
  });
}