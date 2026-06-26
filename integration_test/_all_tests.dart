import '_context_analysis_integration_tests_test.dart' as context_analysis_integration_tests_test;
import '_group_problem_solving_integration_tests_test.dart' as group_problem_solving_integration_tests_test;
import '_app_test.dart' as app_test;
import 'custom_text_field_sanitized_and_checked_using_a_blacklist_Mobile_part_of_the_test.dart' as custom_text_field_sanitized_and_checked_using_a_blacklist_Mobile_part_of_the_test;
// ignore: library_prefixes
import 'session_file_name_mobile_platforms_As_a_widget_test_runs_on_Windows_even_if_Android_is_specified_as_device_test.dart' as session_file_name_mobile_platforms_As_a_widget_test_runs_on_Windows_even_if_Android_is_specified_as_device_test;

void main() async {
  session_file_name_mobile_platforms_As_a_widget_test_runs_on_Windows_even_if_Android_is_specified_as_device_test.main();
  custom_text_field_sanitized_and_checked_using_a_blacklist_Mobile_part_of_the_test.main();
  await context_analysis_integration_tests_test.main();
  // To help with intermittent failures
  await Future.delayed(const Duration(seconds: 10)); 
  await group_problem_solving_integration_tests_test.main();
  // To help with intermittent failures
  await Future.delayed(const Duration(seconds: 10)); 
  await app_test.main();
}