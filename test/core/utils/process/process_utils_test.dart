// @Skip('All tests in process_utils_test.dart are skipped')
// library;

import 'package:path/path.dart' as path;
import 'package:test/test.dart';

import 'package:journeyers/core/utils/process/process_utils.dart';

void main()
{
  var processUtils = ProcessUtils();
  var dashboardDataJsonFilePath = path.join("test","core","utils","process","process_utils_test_data","dashboard_session_data_context_analysis.json");

  group('Process utils tests:', ()
  {
    test('number of records in the dashboard data', (){
      var rank = processUtils.newFileNumberDetermination(pathToDashboardDataFile: dashboardDataJsonFilePath);
      expect(rank,equals(4));
    });
  });
}