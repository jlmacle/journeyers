/// {@category Utils - Project-specific}
/// A typedef for a function that returns a record,
/// with a boolean (true if a string should be sanitized),
/// and with a function to sanitize the string.
typedef StringSanitizerBundle = 
({
  bool shouldStringBeSanitized, 
  dynamic Function(dynamic) sanitizingFunction
}) 
Function(String);

/// {@category Utils - Project-specific}
/// A typedef for a function that returns true if a string should be blocked.
typedef BlacklistingFunction = 
bool Function(String value);

/// {@category Utils - Project-specific}
/// A typedef for an async function without parameters, and returning Future\<void\>.
typedef FutureVoidCallback = 
Future<void> Function();

/// {@category Utils - Project-specific}
/// A typedef for an async function with a Set\<String\> parameter, and a String parameter.
typedef OnKeywordsUpdatedCallbackFunctionType = 
Future<void> Function({required String? filePath, required Set<String> updatedKeywords});

/// {@category Utils - Project-specific}
/// A typedef for an onRetrievedSessionDataCallback.
typedef OnRetrievedSessionDataBeforeEditionCallbackFunctionType = 
void Function
({
    required String dashboardContext,
    required bool isSessionDataBeingEdited, 
    required String titleWhenEdition, 
    required Set<String> keywordsWhenEdition,
    required Object dtoWhenEdition, 
    required String fileNameWithoutExtensionWhenEdition,
    required String filePathWhenEdition                                         
  });

/// {@category Utils - Project-specific}
/// A typedef for an onListNameUpdatedCallbackFunction.
typedef OnListNameUpdatedCallbackFunctionType = 
Future<void> Function
({
  required String? listKey,
  required Map<String, dynamic> listData
});

/// {@category Utils - Project-specific}
/// A typedef for an async function typedef with a String parameter, a Set\<String\> parameter, and a Map\<String, dynamic\> parameter,
/// and used with the ParticipantsListsItem widget.
typedef OnParticipantListsItemSetStringUpdatedCallbackFunctionType = 
Future<void> Function({required String? listKey, required Set<String> updatedItems, required Map<String, dynamic> listData});

/// {@category Utils - Project-specific}
/// A typedef for an async function with a String parameter, and a Map\<String, dynamic\> parameter.
typedef OnListDataUpdatedCallbackFunctionType = 
Future<void> Function({required String? listKey, required Map<String, dynamic> listData});

/// {@category Utils - Project-specific}
/// A typedef for a function with a String parameter, an int parameter, and returning void.
typedef OnListItemValueUpdatedCallbackFunctionType = 
void Function({required int intParam, required String stringParam});

/// {@category Utils - Project-specific}
/// A typedef for a function with a bool? parameter, and an int parameter.
typedef OnCheckboxChangedCallbackFunctionType = 
void Function({required bool? boolParam, required int intParam});