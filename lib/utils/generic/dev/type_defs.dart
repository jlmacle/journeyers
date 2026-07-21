/// {@category Utils - Generic}
/// A function that returns a record,
/// with a boolean (true if a string should be sanitized),
/// and with a function to sanitize the string.
typedef StringSanitizerBundle = 
({
  bool shouldStringBeSanitized, 
  dynamic Function(dynamic) sanitizingFunction
}) 
Function(String);

/// {@category Utils - Generic}
/// A function that returns true if a string should be blocked.
typedef BlacklistingFunction = 
bool Function(String value);

/// {@category Utils - Generic}
/// An async function without parameters, and returning Future\<void\>.
typedef FutureVoidCallback = 
Future<void> Function();

/// {@category Utils - Generic}
/// An async function with a Set\<String\> parameter, and a String parameter.
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
/// An async function typedef with a String parameter, a Set\<String\> parameter, and a Map\<String, dynamic\> parameter,
/// and used with the ParticipantsListsItem widget.
typedef OnParticipantListsItemSetStringUpdatedCallbackFunctionType = 
Future<void> Function({required String? listKey, required Set<String> updatedItems, required Map<String, dynamic> listData});



