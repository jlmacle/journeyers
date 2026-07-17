import "dart:convert";
import "dart:io";

import "package:path_provider/path_provider.dart";

import "package:journeyers/debug_constants.dart";
import "package:journeyers/utils/generic/alphabet/alphabet_utils.dart";
import "package:journeyers/utils/generic/dev/test_utils.dart";
import "package:journeyers/utils/generic/dev/utility_classes_import.dart";
import "package:journeyers/utils/project_specific/dev/sort_utils.dart";
import "package:journeyers/widgets/utility/lists/database/text_lists_storage_externalized_strings.dart";


/// {@category Utils - Project-specific}
/// {@category Lists}
/// Persists a list of participants list data with the pattern:
/// { "key": { 
///             "itemText": "participantListLabel", 
///             "itemTextKey": "a0" , 
///             "itemTextKeywords": ["Household", "Workplace"]  ,
///             "subItemsListData": subItemsListData , 
///             "displayFunction": displayFunction
///           } 
/// }
/// to a single JSON file located in the application-support directory 
/// (see [getApplicationSupportDirectory]).
/// The structure is meant to be reusable, for categorized text lists with sub-items. 
class ListsDB {
  static var _fileName = "journeyers_gps_participants_lists22a.json";

  // ── Internal helpers ────────────────────────────────────────────────────────

  // Method used to get the file where the data is stored 
  // (or null if the file doesn"t exist).
  Future<File?> _getFile() async {
    var dir = await getApplicationSupportDirectory();
    var file = File("${dir.path}/$_fileName");
    if (!file.existsSync()) 
    {
      try
      {
        if (listDebug) pu.printd("List debug: ListsDB: _getFile: file DB not existant. File creation");

        if (isInTestEnvironment) _fileName = "tmp_list_data.json";

        file = File("${dir.path}/$_fileName");
        file.createSync();
        if (listDebug) pu.printd("List debug: ListsDB: _getFile: file created: ${file.path}");
        List<Map<String, String>> records = [];
        String content = jsonEncode(records);
        // writeAsStringSync - Widget testing fails with writeAsString
        file.writeAsStringSync(content);
        // readAsStringSync - Widget testing fails with readAsString
        content = file.readAsStringSync();
        if (listDebug) pu.printd("List debug: ListsDB: _getFile: file content: $content");
      }
      catch(e,s)
      {
        pu.printd("Error at new listsDB creation: $e: $s");
      }
      
      return file;
    }
    else
    {
      if (listDebug) pu.printd("List debug: ListsDB: _getFile: file DB exists");
      if (listDebug) pu.printd("List debug: ListsDB: _getFile: file content: ${file.readAsStringSync()}");
    }
    return file;
  }

  // Method used to find the next alphabet "number", by switching/adding alphabetical "digits".
  // e.g.: 
  // alphabetPart: zz
  // nextAlphabetPart: aaa  

  // Case 1: a <= alphabetPartLastLetter <= y: nextAlphabetPart: determining next last letter
  // Case 2: alphabetPartLastLetter = z: nextAlphabetPart: 
  //          determining the sequence of "z"s before reaching a letter between a and y
  String _nextAlphabetPart(String alphabetPart)
  {
    // the next alphabet part
    String nextAlphabetPart = "";
    // the alphabet part before alphabetPartLastLetter
    String alphabetPartRoot = "";
    // The number of consecutive "z"s at the end of alphabetPart
    int zEndSequenceCount = 0;

    // Starting by the end of alphabetPart

    String alphabetPartLastLetter = alphabetPart[alphabetPart.length - 1];
    String nextLetter;      

    // Case 1: a <= alphabetPartLastLetter <= y
    // Case 2: alphabetPartLastLetter = z
    switch(alphabetListMinusZ.contains(alphabetPartLastLetter))
    {
      // letter is between a and y
      // e.g.
      // ay -> az
      // abca -> abcb

      // Case 1: a <= alphabetPartLastLetter <= y
      case(true):
      {
        // Building next letter
        nextLetter = alphabetList[ alphabetToIndexMap[alphabetPartLastLetter]! + 1 ];

        // if more than 1 letter in alphabetPart
        if (alphabetPart.length > 1)
        {
          // if more than 1 letter in alphabetPart, adding alphabetPartRoot to build the key
          if (alphabetPart != alphabetPart[alphabetPart.length - 1]) alphabetPartRoot = alphabetPart.substring(0, alphabetPart.length - 1);
          // nextAlphabetPart is built
          return nextAlphabetPart = "${alphabetPartRoot}${nextLetter}";
        }
        // alphabetPart.length == 1: was processing a single letter
        else
        {
          return nextAlphabetPart = nextLetter;
        }       
      }

      // alphabetPartLastLetter is z
      // e.g.
      // zz -> aaa
      // az -> ba
      // zzz -> aaaa

      // Case 2: alphabetPartLastLetter = z
      case(false):
      {
        // determining the sequence of "z"s before reaching a letter between a and y
        // alphabetPartLastLetter was "z"
        bool nonBrokenZSequence = true;
        for (var index = alphabetPart.length - 1; index >= 0;  index--)
        {
          // if sequence of "z"s
          // "a" added by the front to nextAlphabetPart
          // one extra "a" to add eventually if alphabetPart made of "z"s
          if (alphabetPart[index] == "z" && nonBrokenZSequence)  
          {
            zEndSequenceCount++;
            nextAlphabetPart = "a" + nextAlphabetPart;
           
            // if (listDebug) pu.printd("List debug: nextAlphabetPart: $nextAlphabetPart");
            // remains one extra "a" to add if alphabetPart made only of "z"s
          }

          // Reached a letter different than "z".
          // End of the sequence of "z"s
          else
          {
            nonBrokenZSequence = false;

            // Removing the sequence of "z"s at the end, 
            // before applying _nextAlphabetPart to remaining part, to determine additional part to add to the "a"(s)
            // or before adding an extra "a"
            // The last letter is a "z", therefore at least one "z" to remove
            String alphabetPartWithoutZSequence = 
                alphabetPart.substring(0, alphabetPart.length - zEndSequenceCount);
           
            nextAlphabetPart = _nextAlphabetPart(alphabetPartWithoutZSequence) + nextAlphabetPart;

            // if (listDebug) pu.printd("List debug: alphabetPart: $alphabetPart");
            // if (listDebug) pu.printd("List debug: zCount: $zEndSequenceCount");
            // if (listDebug) pu.printd("List debug: alphabetPartWithoutZSequence: $alphabetPartWithoutZSequence");

            return nextAlphabetPart;
          }
        }
      }
    }
    // All "z"s, "a" to add in front
    if(alphabetPart.length == zEndSequenceCount) nextAlphabetPart = "a" + nextAlphabetPart;
    return nextAlphabetPart;
  }


  // ── public API ───────────────────────────────────────────────────────────────

  // Method used to load the data structure
  Future<List<dynamic>> loadDataStructure() async
  {
    // Getting the file
    File? f = await _getFile();

    if (f == null) 
    {
      if (listDebug) pu.printd("List debug: ListsDB: loadDataStructure: no data to load"); 
      return [];
    }

    // Decoding the file
    // readAsStringSync - Widget testing fails with readAsString
    var stringData = f.readAsStringSync();
    var decodedData = jsonDecode(stringData);
    if (listDebug) pu.printd("List debug: ListsDB: loadDataStructure: decoded data: $decodedData"); 
    return decodedData;
  } 

  // To clean: Code duplication
  /// Returns `true` when [label] already exists in the list of participants lists labels (async).
  Future<bool> listLabelExistsAsync(String label) async {
    var data = await loadDataStructure();
    for (var index = 0; index < data.length; index++)
    {
      var listData = data[index] as Map<String, dynamic>;
      var listDataValues = listData.values.first;
      if (listDataValues[itemTextKey] == label) return true;
    }
    return false; 
  }

  /// Returns `true` when [label] already exists in the list of grouped texts (sync).
  bool listLabelExistsSync({required String label, required List<dynamic> dataStructure}) {
    for (var index = 0; index < dataStructure.length; index++)
    {
      var listData = dataStructure[index] as Map<String, dynamic>;
      var listDataValues = listData.values.first;
      // if (listDebug) pu.printd("List debug: listData.values.first: ${listData.values.first}");
      if (listDataValues[itemTextKey] == label) return true;
    }
    return false; 
  }

  /// Loads the texts for [label]. Throws [ArgumentError] when absent.
  List<String> loadTextsByListLabelSync({required String label, required List<dynamic> dataStructure})
  {
    // if (listDebug) pu.printd("List debug: label: $label");
    // if (listDebug) pu.printd("List debug: dataStructure: $dataStructure");

    bool labelExists = listLabelExistsSync(label: label, dataStructure: dataStructure);
    if (!labelExists) {
      throw ArgumentError("No list found for label: '$label'.");
    }

    // Lists-level loop
    for (var indexLists = 0; indexLists < dataStructure.length; indexLists++)
    {
      var texts = [];
      // Retrieving the data for the current list  
      var currentListData = dataStructure[indexLists] as Map<String, dynamic>;  
      // Retrieving the data values for the current list
      var currentListDataValues = currentListData.values.first;
      // Retrieving the label for the current list  
      var listLabel = currentListDataValues[itemTextKey];
      // Retrieving the sub-items data
      List<dynamic> subItemsData = currentListDataValues[subItemsDataListKey];
      // Retrieving the texts for the current list  
      for (var indexSubItems = 0; indexSubItems < subItemsData.length; indexSubItems++)
      {
        // Retrieving the data for the current sub-item 
        var currentSubItemData = subItemsData[indexSubItems];
        // Retrieving the data values for the current sub-item 
        var currentSubItemDataValues = currentSubItemData.values.first;
        // Retrieving the text for the current sub-item 
        var text = currentSubItemDataValues[itemTextKey];
        // Adding the  text  to the list
        texts.add(text);
      }

      // if (listDebug) pu.printd("List debug: texts: $texts");
      if (listLabel == label) return List.from(texts);   
    }

    return [];
  }

  /// Loads the data for [label]: 
  ///   The unique key
  ///   The texts
  ///   The keywords if any
  /// Throws [ArgumentError] when absent.
  Map<String, dynamic> loadListDataByListLabelSync({required String label, required List<dynamic> dataStructure})
  {

    // if (listDebug) pu.printd("List debug: dataStructure: $dataStructure");

    Map<String, dynamic> listData = {};

    bool labelExists = listLabelExistsSync(label: label, dataStructure: dataStructure);
    if (!labelExists) {
      throw ArgumentError("No list found for label: '$label'.");
    }

    // Lists-level loop
    for (var indexLists = 0; indexLists < dataStructure.length; indexLists++)
    {
      // var listUniqueKey = "";
      // var listTexts = [];
      // var listKeywords = [];
      
      // Retrieving the data for the current list  
      var currentListData = dataStructure[indexLists] as Map<String, dynamic>;  
      // Retrieving the data values for the current list
      var currentListDataValues = currentListData.values.first;
      // Retrieving the label for the current list  
      var listLabel = currentListDataValues[itemTextKey];

      if (listLabel == label) return currentListDataValues;

       
    }

    return {};
  }


  /// Returns a list made of all the lists of texts.
  Future<List<List<String>>> getListOfGroupedTexts() async {

    // Loading the data
    var data = await loadDataStructure();
    // if (listDebug) pu.printd("List debug: data: $data");

    List<List<String>> listOfGroupedTexts =[];

    // Lists-level loop
    for (var indexLists = 0; indexLists < data.length; indexLists++)
    {
      var currentListData = data[indexLists] as Map<String, dynamic>;      
      var currentListDataValues = currentListData.values.first;
      var currentSubItemsListData = currentListDataValues[subItemsDataListKey];

      List<String> textsList = [];
      
      // Sub-items-level loop
      for (var indexSubItems = 0; indexSubItems < currentSubItemsListData.length; indexSubItems++)
      {
        // Retrieving the data for the current sub-item 
        var currentSubItemData = currentSubItemsListData[indexSubItems];
        // Retrieving the data values for the current sub-item 
        var currentSubItemDataValues = currentSubItemData.values.first;
        // Retrieving the text for the current sub-item 
        var text = currentSubItemDataValues[itemTextKey];
        // Adding the  text  to the list
        textsList.add(text);
      }
      // Adding to the list
      listOfGroupedTexts.add(textsList);
    }
    // if (listDebug) pu.printd("List debug: listOfGroupedTexts(): listOfGroupedTexts: $listOfGroupedTexts");
    return listOfGroupedTexts;
  }

  /// Returns all saved group labels, sorted alphabetically.
  Future<List<String>> getSortedLabels({List<dynamic>? dataStructure}) async {
    var data = dataStructure ?? await loadDataStructure();

    List<String> labels =[];

    // Lists-level loop
    for (var indexLists = 0; indexLists < data.length; indexLists++)
    {
      var listData = data[indexLists] as Map<String, dynamic>;      
      var listDataValues = listData.values.first;
      var listLabel = listDataValues[itemTextKey];
      labels.add(listLabel);
    }

    return labels;
  }

  // Method used to build a list/item text key
  // Keys have an alphabet part and a digit part: e.g. aa3
  // Simplified memo:
  // Case 1: 0 <= digitPart <= 8: nextGenKey: determining next digit
  // Case 2: digitPart = 9 and  a <= alphabetPartLastLetter <= y: nextGenKey: determining next last letter
  // Case 3: digitPart = 9 and  alphabetPartLastLetter = z: nextGenKey: need to increment the alphabet part before z
  String getNextKey({required String key})
  {

    //print(alphabetToIndexMap);

    String nextKey = "";
    int digitPart = int.parse( key[key.length -1] );
    String alphabetPart = key.substring(0, key.length-1);

    //if (listDebug) pu.printd("List debug: digitPart: $digitPart");
    //if (listDebug) pu.printd("List debug: alphabetPart: $alphabetPart");

    // Case 1: 0 <= digitPart <= 8
    switch (List.generate(8, (i) => i).contains(digitPart))
    {
      // Case 1: 0 <= digitPart <= 8 
      case true:
      {
        int nextDigit = digitPart + 1;
        // nextKey building
        return nextKey = "$alphabetPart$nextDigit";
      }

      // Case 2: digitPart = 9 and  a <= alphabetPartLastLetter <= y
      // Case 3: digitPart = 9 and  alphabetPartLastLetter = z
      // need to modify the alphabet part
      // digitPart is 9
      case false:
      {
        // the next digit is 0
        String nextDigitPart = "0";

        // searching to determine the next alphabet part
        String nextAlphabetPart = "";
        // alphabetPartRoot, the alphabet part before alphabetPartLastLetter
        String alphabetPartRoot = "";
        // determining the last letter
        String alphabetPartLastLetter = alphabetPart[alphabetPart.length - 1];
        // determining the root part of alphabetPart
        if (alphabetPart != alphabetPartLastLetter) alphabetPartRoot = alphabetPart.substring(0, alphabetPart.length - 1);

        //if (listDebug) pu.printd("List debug: alphabetPartRoot: $alphabetPartRoot");
        
        // Case 2: digitPart = 9 and  a <= alphabetPartLastLetter <= y
        switch(alphabetListMinusZ.contains(alphabetPartLastLetter))
        {
          // The last letter in alphabetPart is between a and y

          // e.g.: ab9
          // digitPart: 9
          // nextDigitPart: 0
          // alphabetPart:  ab
          // alphabetPartLastLetter: b
          // nextLetterAfterAlphabetPartLastLetter: C
          // nextAlphabetPart: ac
          // nextKey: ac0
          case true:
          {
            nextAlphabetPart = _nextAlphabetPart(alphabetPart);
            nextKey = "${nextAlphabetPart}${nextDigitPart}";
          }
          
          // e.g.: zz9
          // digitPart: 9
          // nextDigitPart: 0
          // alphabetPart:  zz
          // alphabetPartLastLetter: z
          // nextLetterAfterAlphabetPartLastLetter: a
          // nextAlphabetPartRoot = aaa
          // nextKey: aaa0

          // Case 3: digitPart = 9 and  alphabetPartLastLetter = z
          case false:
          {
            // Retrieving the next letter in the alphabet after z: a
            String nextLetterAfterAlphabetPartLastLetter ="a";
            // Building the new alphabet part root
            // String nextAlphabetPartRoot = _nextAlphabetPart(alphabetPartRoot);
            String nextAlphabetPart = _nextAlphabetPart(alphabetPart);
            nextKey = "${nextAlphabetPart}${nextDigitPart}";
            // nextKey = "${nextAlphabetPartRoot}${nextLetterAfterAlphabetPartLastLetter}${nextDigitPart}";
            //if (listDebug) pu.printd("List debug: nextKey: $nextKey");
          }
        }
      }

    }

    return nextKey;
  }

  /// Method used to get the longest key in a list of keys.
  List<String> getLongestKeys(List<String> keys)
  {
    int longestKeyLength = 0;

    Set<String> longestKeysSet = Set.from(keys);

    // Keys should be unique
    if (keys.length != Set.from(keys).length) throw Exception("Keys should be unique: keysUsed: $keys");

    // Searching for max longestKeyLength
    for (var keyIndex = 0; keyIndex < keys.length; keyIndex++)
    {
      // Is the key longer than longestKeyLength
      if ( longestKeyLength <= keys[keyIndex].length )
      {
        // New reference length
        longestKeyLength = keys[keyIndex].length;
      }
      else
      {
        // Removing the key from longestKeysSet
        // if (listDebug) pu.printd("List debug: Removing: ${keys[keyIndex]}: longestKeyLength: $longestKeyLength");
        longestKeysSet.remove(keys[keyIndex]);
      }
    }

    // if (listDebug) pu.printd("List debug: longestKeysSet after first loop: $longestKeysSet");

    // Removing all values smaller than longestKeyLength
    List<String> longestKeysList = longestKeysSet.toList();
    for (var keyIndex = 0; keyIndex < longestKeysList.length; keyIndex++)
    {
      // Is the key longer than longestKeyLength
      if ( longestKeyLength > longestKeysList[keyIndex].length )
      {
        // if (listDebug) pu.printd("List debug: Removing: ${longestKeysList[keyIndex]}");
        // Removing the key from longestKeysSet
        longestKeysSet.remove(longestKeysList[keyIndex]);
        
      }
    }

    return longestKeysSet.toList();
  }

  /// Method used to get the last key used in the list
  Future<String> getLastKey() async
  {
    String lastKey = "";

    // Getting the data
    List<dynamic> dataList = await loadDataStructure();

    // Searching all the keys used
    List<String> keysUsed = [];
    for (var currentListIndex = 0; currentListIndex < dataList.length; currentListIndex++)
    {
      // Adding the list keys
      keysUsed.add(dataList[currentListIndex].keys.first);

      // Searching for the subitems keys
      Map<String, dynamic> currentListData =  dataList[currentListIndex].values.first;
      List<dynamic> subItemsDataList = currentListData[subItemsDataListKey];
      for (var subItemsDataIndex = 0; subItemsDataIndex < subItemsDataList.length; subItemsDataIndex++)
      {
        // Adding the subitems keys
         keysUsed.add((subItemsDataList[subItemsDataIndex]).keys.first);
      }
    }

    // Keeping only the longest keys
    List<String> longestKeys = getLongestKeys(keysUsed);

    // Getting the biggest key from the longest keys
    lastKey = getBiggestKey(longestKeys);

    return lastKey;
  }

  /// Method used to get a map "key-list index" from a list, or from a sub-items list.
  Map<String, int> getListKeyIndexMap(List<dynamic> list)
  {
    Map<String, int> map = {};

    for (var listIndex = 0; listIndex < list.length; listIndex++)
    {
      map[(list[listIndex]).keys.first] = listIndex;
    }


    return map;
  }

  // Method used to build a map names/keys from a subItemsDataList
  Map<String, String> getNamesKeys(List<dynamic> subItemsDataList)
  {
    // Getting a map names/keys from the stored subItemsDataList
    Map<String, String> actualNamesKeysMap = {};
    for (var currentsubItemIndex = 0; currentsubItemIndex < subItemsDataList.length; currentsubItemIndex++)
    {
      var currentsubItemValues = (subItemsDataList[currentsubItemIndex]).values.first;
      actualNamesKeysMap[currentsubItemValues[itemTextKey]] = currentsubItemValues[itemKey];
    }
    return actualNamesKeysMap;
  }
  

  /// Saves [texts] under [label], overwriting any previous entry.
  /// The key used is a sequence of letters followed by a digit (0 to 9)
  Future<void> saveListData(String label, List<String> texts, List<String> keywords) async {
    // if (listDebug) pu.printd("List debug: saveListData");

    List<dynamic> data = await loadDataStructure();

    // if (listDebug) pu.printd("List debug: data: $data");

    // Key building
    String listKey;
    String lastKeyInData;
    // Case: structure is empty
    if (data.isEmpty) 
    { 
      // if (listDebug) pu.printd("List debug: Empty list set");
      listKey = "a0"; 
      // if (listDebug) pu.printd("List debug: new key: $listKey");
    }
    // Case: structure is not empty
    else 
    {
      // Getting the last list data
      Map<String, dynamic> lastListData = data[data.length - 1];

      // Getting the list of sub-items
      var lastListDataValues = lastListData.values.first;
      List<dynamic> subItemsListData = lastListDataValues[subItemsDataListKey];

      // Getting the last sub-item
      var lastSubItemData = subItemsListData[subItemsListData.length - 1];

      // Getting the last sub-item key
      var lastKeyInData = lastSubItemData.keys.first;

      listKey = getNextKey(key: lastKeyInData);
      // if (listDebug) pu.printd("List debug: new list key: $listKey");
    }
  
    //List of sub-items data building
    List<dynamic> subItemsDataList = [];
    var key = listKey;
     
    // Building the items data
    for (var textIndex = 0; textIndex < texts.length; textIndex++)
    {
      // building the key from the previously used key
      key = getNextKey(key: key);
      // if (listDebug) pu.printd("List debug: item key: $key");
      Map<String, dynamic> itemDataMap = {itemKey: key, itemTextKey: texts[textIndex], subItemsDataListKey: null, displayFunctionKey: null};

      subItemsDataList.add({key: itemDataMap});
    }
    
    // if (listDebug) pu.printd("List debug: subItemsDataList: $subItemsDataList");

    // Building the list data
    var listDataMap=  {itemKey: listKey, itemTextKey: label, itemKeywordsKey: keywords..sort(), subItemsDataListKey: subItemsDataList, displayFunctionKey: null};
    var listData = {listKey: listDataMap};

    // if (listDebug) pu.printd("List debug: List data: $listData");

    // Adding the list (verified previously as unique)
    data.add(listData);
    // Saving the data
    var f = await _getFile();
    await f!.writeAsString(jsonEncode(data));
  }

  // todo: to clean
  /// Method used to add, or remove, one or several participants of the list.
  Future<String> updateListName(String updatedListName, Map<String, dynamic> listData) async
  {

    if (listDebug) pu.printd("List debug: ListsDB: updateListName: updatedListName: $updatedListName");

    var listLabel = listData[itemTextKey];
    if (listDebug) pu.printd("List debug: ListsDB: updateListName (before): listLabel: $listLabel");

    // listData[itemTextKey] = updatedListName;
    
    if (listDebug) pu.printd("List debug: ListsDB: updateListName (after): listLabel: $listLabel");
    return listLabel;
  }


  /// Method used to add, or remove, one or several participants of the list.
  Future<List<dynamic>> updateParticipants(Set<String> updatedParticipants, Map<String, dynamic> listData) async
  {
    var newKey = "";

    if (listDebug) pu.printd("List debug: ListsDB: updateParticipants: updatedParticipants: $updatedParticipants");
    List<String> updatedParticipantsList = updatedParticipants.toList();
    var subItemsDataList = listData[subItemsDataListKey];
    if (listDebug) pu.printd("List debug: ListsDB: updateParticipants (before): subItemsDataList: $subItemsDataList");

    // Getting a map names/keys from the stored subItemsDataList
    Map<String, String> actualNamesKeysMap = getNamesKeys(subItemsDataList);

    if (listDebug) pu.printd("List debug: ListsDB: updateParticipants: actualNamesKeysMap: $actualNamesKeysMap");

    // Verifying if some participants are to be removed from the subItemsDataList
    List<String> actualParticipants = actualNamesKeysMap.keys.toList();
    Map<String, int> keyActualIndexMap  = getListKeyIndexMap(subItemsDataList);

    if (listDebug) pu.printd("List debug: ListsDB: updateParticipants: actualParticipants: $actualParticipants");
    for (String actualParticipant in actualParticipants)
    {
      if (!updatedParticipantsList.contains(actualParticipant))
      {
        if (listDebug) pu.printd("List debug: ListsDB: updateParticipants: participant removal: $actualParticipant not in $updatedParticipantsList");
        // removing from subItemsDataList
        String? keyForRemoval = actualNamesKeysMap[actualParticipant];
        var indexForRemoval = keyActualIndexMap[keyForRemoval!];
        subItemsDataList.removeAt(indexForRemoval);


        // Todo: data structure
        // updating the index map
        keyActualIndexMap  = getListKeyIndexMap(subItemsDataList);
      }
    }

    // Verifying if some participants are to be added to the subItemsDataList
    // Getting actualParticipantsList from updated subItemsDataList
    actualNamesKeysMap = getNamesKeys(subItemsDataList);
    var actualParticipantsList = actualNamesKeysMap.keys.toList();
    if (listDebug) pu.printd("List debug: ListsDB: updateParticipants: updatedParticipants: $updatedParticipants");
    for (String updatedParticipant in updatedParticipants)
    {
      if (!actualParticipantsList.contains(updatedParticipant))
      {
        if (listDebug) pu.printd("List debug: ListsDB: updateParticipants: participant addition: $updatedParticipant not in $actualParticipantsList");
        
        // Sub-item data needs to be added
        Map<String, dynamic> subItemData = {};

        // Getting the key value
        if (newKey == "") 
        { 
          var lastKey = await getLastKey(); 
           newKey = getNextKey(key: lastKey);
        }
        else { newKey = getNextKey(key: newKey); }

        subItemData[itemKey] = newKey;
        subItemData[itemTextKey] = updatedParticipant;
        subItemData[subItemsDataListKey] = null;
        subItemData[displayFunctionKey] = null;

        // adding subItemData to subItemsDataList
        subItemsDataList.add({newKey: subItemData});
      }
    }

    if (listDebug) pu.printd("List debug: ListsDB: updateParticipants (after): subItemsDataList: $subItemsDataList");
    return subItemsDataList;
  }

  /// Updates a list data.
  Future<void> updateListData(String listKey, Map<String, dynamic> listData) async {

    // if (listDebug) pu.printd("List debug: updateListData: ");
    // if (listDebug) pu.printd("List debug: listData: $listData");

    List<dynamic> data = await loadDataStructure();

    for (var index = 0; index < data.length; index++)
    {
      var currentListData = data[index] as Map<String, dynamic>;
      var currentListDataKeys = currentListData.keys.first;
      if (currentListDataKeys == listKey) 
      {

        // Updating the list data by index and key
        data[index][listKey] = listData;
        // if (listDebug) pu.printd("List debug: data[index][listKey]: ${data[index][listKey]}");

      }
    }

    // if (listDebug) pu.printd("List debug: data (updated): $data"); 

    // Saving the data
    var f = await _getFile();
    await f!.writeAsString(jsonEncode(data));
  }

  /// Removes a list data.
  Future<void> removeListData(List<String> listKeys) async {

    if (listDebug) pu.printd("List debug: ListsDB: removeListData: ");

    List<dynamic> data = await loadDataStructure();

    for (var index = 0; index < data.length; index++)
    {
      var currentListData = data[index] as Map<String, dynamic>;
      var currentListDataKey = currentListData.keys.first;
      if (listKeys.contains(currentListDataKey)) 
      {
        // Removing the list data
        data.removeAt(index);
      }
    }

    if (listDebug) pu.printd("List debug: ListsDB: removeListData: data (updated): $data"); 

    // Saving the data
    var f = await _getFile();
    await f!.writeAsString(jsonEncode(data));
  }
}


