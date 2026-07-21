// A typedef for a function that returns a record,
// with a boolean (true if a string should be sanitized),
// and with a function to sanitize the string.
typedef StringSanitizerBundle = 
({
  bool shouldStringBeSanitized, 
  dynamic Function(dynamic) sanitizingFunction
}) 
Function(String);

// A typedef for a function that returns true if a string should be blocked.
typedef BlacklistingFunction = 
bool Function(String value);

// A typedef for an async function without parameters, and returning Future\<void\>.
typedef FutureVoidCallback = 
Future<void> Function();

// A typedef for an onKeywordsUpdatedCallbackFunction.
typedef OnKeywordsUpdatedCallbackFunctionType = 
Future<void> Function({required String? filePath, required Set<String> updatedKeywords});

// A typedef for an onRetrievedCA/GPSSessionDataBeforeEditionCallbackFunction.
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

// A typedef for an onListNameUpdatedCallbackFunction.
typedef OnListNameUpdatedCallbackFunctionType = 
Future<void> Function
({
  required String? listKey,
  required Map<String, dynamic> listData
});

// A typedef used with the ParticipantsListsItem onKeywordsUpdatedCallbackFunction, onParticipantsUpdatedCallbackFunction.
typedef OnParticipantListsItemSetStringUpdatedCallbackFunctionType = 
Future<void> Function({required String? listKey, required Set<String> updatedItems, required Map<String, dynamic> listData});

// A typedef used with the ParticipantsListsItem onListNameUpdated, onParticipantsUpdated, onKeywordsUpdated.
typedef OnParticipantListsItemDataUpdatedCallbackFunctionType = 
Future<void> Function({required String? listKey, required Map<String, dynamic> listData});

// A typedef for a parentCallbackFunctionToUpdateTheListItemValue.
typedef OnListItemValueUpdatedCallbackFunctionType = 
void Function({required int intParam, required String stringParam});

// A typedef for an onCheckboxChangedCallbackFunction.
typedef OnCheckboxChangedCallbackFunctionType = 
void Function({required bool? boolParam, required int intParam});