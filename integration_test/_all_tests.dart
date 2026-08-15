import "_context_analysis_integration_tests_test.dart" as context_analysis_integration_tests_test;
import "_group_problem_solving_integration_tests_test.dart" as group_problem_solving_integration_tests_test;
import "_app_test.dart" as app_test;
// ignore: library_prefixes
import "session_file_name_mobile_platforms_As_a_widget_test_runs_on_Windows_even_if_Android_is_specified_as_device_test.dart" as session_file_name_mobile_platforms_As_a_widget_test_runs_on_Windows_even_if_Android_is_specified_as_device_test;

void main() async {
  session_file_name_mobile_platforms_As_a_widget_test_runs_on_Windows_even_if_Android_is_specified_as_device_test.main();
  await Future.delayed(const Duration(seconds: 2)); 
  await context_analysis_integration_tests_test.main();
  // To help with intermittent failures
  await Future.delayed(const Duration(seconds: 10)); 
  await group_problem_solving_integration_tests_test.main();
  // To help with intermittent failures
  await Future.delayed(const Duration(seconds: 10)); 
  await app_test.main();
}