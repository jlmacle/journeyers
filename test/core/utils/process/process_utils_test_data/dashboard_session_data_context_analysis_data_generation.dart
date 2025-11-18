// flutter run -t test\core\utils\process_utils_test_data\dashboard_session_data_context_analysis_data_generation.dart

import 'dart:convert';
import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;


void main() async
{
  String filePath = path.join('test','core','utils','process_utils_test_data','dashboard_session_data_context_analysis.json');
  var jsonFile = File(filePath);

  var now = DateTime.now();
  var formatter = DateFormat('MM/dd/yy');
  var formattedDate = formatter.format(now);

  // First record of data
  var title1 = "Title session 1";
  var date1 = formattedDate;
  List<String> tags1 = ["tag1", "tag2", "tag3"];
  var record1 = {'title':title1, 'date':date1 , 'tags':tags1};

  // Second record of data
  var title2 = "Title session 2";
  var date2 = formattedDate;
  List<String> tags2 = ["tag1", "tag2", "tag4"];
  var record2= {'title':title2, 'date':date2, 'tags':tags2};

  // Third record of data
  var title3 = "Title session 2";
  var date3 = formattedDate;
  List<String> tags3 = ["tag1", "tag3", "tag5"];
  var record3 = {'title':title3, 'date':date3, 'tags':tags3};

  List<Map> records = [record1,record2,record3];

  var data = {'records':records};
  var jsonString = jsonEncode(data);

  await jsonFile.writeAsString(jsonString);
}