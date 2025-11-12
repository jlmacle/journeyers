
import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

import 'package:journeyers/core/utils/process_utils.dart';

void main()
{
  var processUtils = ProcessUtils();
  var dashboardDataJsonFileName = r"test\core\utils\process_utils_test_data\dashboard_data_context_analysis.json";

  group('Process utils tests:', ()
  {
    test('number of records in the dashboard data', (){
      var rank = processUtils.newFileNumberDetermination(dashboardDataJsonFileName);
      expect(rank,equals(4));

    });
  });



}