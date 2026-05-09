import 'package:flutter_test/flutter_test.dart';

import 'package:journeyers/pages/context_analysis/context_analysis_process_widgets/_context_analysis_questions_fields.dart';
  
// Labels of the level 2 and 3 titles
final q = CAQuestionsFields();

// Method used to open the expansion tile with the individual perspective
Future<void> openIndividualExpansionTile(WidgetTester tester) async
  {
    // Opening the individual perspective expansion tile
    await tester.tap(find.text(q.level2TitleIndividual));

    // Waiting for the expansion tile to be unfolded before searching descendants
    await tester.pump(const Duration(seconds: 2));

    // pumpAndSettle timed out exception if pumpAndSettle is used
    // await tester.pumpAndSettle();
  }

  // Method used to open the expansion tile with the group/team perspective
  Future<void> openGroupExpansionTile(WidgetTester tester) async
  {
    // Opening the group/team perspective expansion tile
    await tester.tap(find.text(q.level2TitleGroup));

    // Waiting for the expansion tile to be unfolded before searching descendants
    await tester.pump(const Duration(seconds: 2));

    // pumpAndSettle timed out exception if pumpAndSettle is used
    // await tester.pumpAndSettle();
  }

  