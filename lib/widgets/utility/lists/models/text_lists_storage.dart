import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'text_lists_storage_externalized_strings.dart';
import '../../../../utils/generic/alphabet/alphabet_utils.dart';


// new category to consider
/// {@category Utils - Generic}
/// Persists a list of participants list data with the pattern:
/// { "key": { "itemText": "participantListLabel", "itemTextKey": "a0" , 
///             "itemTextKeywords": ["Household", "Workplace"]  ,
///             "subItemsListData": subItemsListData , "displayFunction": displayFunction} }
/// to a single JSON file located in the application-support directory 
/// (see [getApplicationSupportDirectory]).
class TextListsDB {
  static const _fileName = 'journeyers_gps_participants_groups_lists19.json';

  // ── Internal helpers ────────────────────────────────────────────────────────

  // Method used to get the file where the data is stored.
  Future<File> _getFile() async {
    var dir = await getApplicationSupportDirectory();
    return File('${dir.path}/$_fileName');
  }

  // Method used to find the next alphabet "number", by switching/adding alphabetical "digits".
  // e.g.: 
  // alphabetPart: zz
  // nextAlphabetPart: aaa  

  // Case 1: a <= alphabetPartLastLetter <= y: nextAlphabetPart: determining next last letter
  // Case 2: alphabetPartLastLetter = z: nextAlphabetPart: 
  //          determining the sequence of 'z's before reaching a letter between a and y
  String _nextAlphabetPart(String alphabetPart)
  {
    // the next alphabet part
    String nextAlphabetPart = "";
    // the alphabet part before alphabetPartLastLetter
    String alphabetPartRoot = "";
    // The number of consecutive 'z's at the end of alphabetPart
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
        // determining the sequence of 'z's before reaching a letter between a and y
        // alphabetPartLastLetter was 'z'
        bool nonBrokenZSequence = true;
        for (var index = alphabetPart.length - 1; index >= 0;  index--)
        {
          // if sequence of 'z's
          // 'a' added by the front to nextAlphabetPart
          // one extra 'a' to add eventually if alphabetPart made of 'z's
          if (alphabetPart[index] == 'z' && nonBrokenZSequence)  
          {
            zEndSequenceCount++;
            nextAlphabetPart = 'a' + nextAlphabetPart;
           
            print("nextAlphabetPart: $nextAlphabetPart");
            // remains one extra 'a' to add if alphabetPart made only of 'z's
          }

          // Reached a letter different than 'z'.
          // End of the sequence of 'z's
          else
          {
            nonBrokenZSequence = false;

            // Removing the sequence of 'z's at the end, 
            // before applying _nextAlphabetPart to remaining part, to determine additional part to add to the 'a'(s)
            // or before adding an extra 'a'
            // The last letter is a 'z', therefore at least one 'z' to remove
            String alphabetPartWithoutZSequence = 
                alphabetPart.substring(0, alphabetPart.length - zEndSequenceCount);
           
            nextAlphabetPart = _nextAlphabetPart(alphabetPartWithoutZSequence) + nextAlphabetPart;

            print("alphabetPart: $alphabetPart");
            print("zCount: $zEndSequenceCount");
            print("alphabetPartWithoutZSequence: $alphabetPartWithoutZSequence");

            return nextAlphabetPart;
          }
        }
      }
    }
    // All 'z's, 'a' to add in front
    if(alphabetPart.length == zEndSequenceCount) nextAlphabetPart = 'a' + nextAlphabetPart;
    return nextAlphabetPart;
  }


  // ── public API ───────────────────────────────────────────────────────────────

  // Method used to load the data structure
  Future<List<dynamic>> loadDataStructure() async
  {
    // Getting the file
    File f = await _getFile();

    // Decoding the file
    if (!await f.exists()) return [];

    var stringData = await f.readAsString();
    return jsonDecode(stringData);
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
      // print("listData.values.first: ${listData.values.first}");
      if (listDataValues[itemTextKey] == label) return true;
    }
    return false; 
  }

  /// Loads the texts for [label]. Throws [ArgumentError] when absent.
  List<String> loadTextsByListLabelSync({required String label, required List<dynamic> dataStructure})
  {
    // print("label: $label");
    // print("dataStructure: $dataStructure");

    bool labelExists = listLabelExistsSync(label: label, dataStructure: dataStructure);
    if (!labelExists) {
      throw ArgumentError('No list found for label: "$label".');
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

      // print("texts: $texts");
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

    print("dataStructure: $dataStructure");

    Map<String, dynamic> listData = {};

    bool labelExists = listLabelExistsSync(label: label, dataStructure: dataStructure);
    if (!labelExists) {
      throw ArgumentError('No list found for label: "$label".');
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
  Future<List<List<String>>> listOfGroupedTexts() async {

    // Loading the data
    var data = await loadDataStructure();
    print("data: $data");

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
    print("listOfGroupedTexts(): listOfGroupedTexts: $listOfGroupedTexts");
    return listOfGroupedTexts;
  }

  /// Returns all saved group labels, sorted alphabetically.
  Future<List<String>> sortedLabels({List<dynamic>? dataStructure}) async {
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

    //print("digitPart: $digitPart");
    //print("alphabetPart: $alphabetPart");

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
        String nextDigitPart = '0';

        // searching to determine the next alphabet part
        String nextAlphabetPart = "";
        // alphabetPartRoot, the alphabet part before alphabetPartLastLetter
        String alphabetPartRoot = "";
        // determining the last letter
        String alphabetPartLastLetter = alphabetPart[alphabetPart.length - 1];
        // determining the root part of alphabetPart
        if (alphabetPart != alphabetPartLastLetter) alphabetPartRoot = alphabetPart.substring(0, alphabetPart.length - 1);

        //print("alphabetPartRoot: $alphabetPartRoot");
        
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
            String nextLetterAfterAlphabetPartLastLetter ='a';
            // Building the new alphabet part root
            // String nextAlphabetPartRoot = _nextAlphabetPart(alphabetPartRoot);
            String nextAlphabetPart = _nextAlphabetPart(alphabetPart);
            nextKey = "${nextAlphabetPart}${nextDigitPart}";
            // nextKey = "${nextAlphabetPartRoot}${nextLetterAfterAlphabetPartLastLetter}${nextDigitPart}";
            //print("nextKey: $nextKey");
          }
        }
      }

    }

    return nextKey;
  }

  /// Saves [texts] under [label], overwriting any previous entry.
  /// The key used is a sequence of letters followed by a digit (0 to 9)
  Future<void> saveListData(String label, List<String> texts, List<String> keywords) async {
    print("saveListData");

    List<dynamic> data = await loadDataStructure();

    print("data: $data");

    // Key building
    String listKey;
    String lastKeyInData;
    // Case: structure is empty
    if (data.isEmpty) 
    { 
      print("Empty list set");
      listKey = "a0"; 
      print("new key: $listKey");
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
      print("new list key: $listKey");
    }
  
    //List of sub-items data building
    List<dynamic> subItemsDataList = [];
    var key = listKey;
     
    // Building the items data
    for (var textIndex = 0; textIndex < texts.length; textIndex++)
    {
      // building the key from the previously used key
      key = getNextKey(key: key);
      print("item key: $key");
      Map<String, dynamic> itemDataMap = {itemKey: key, itemTextKey: texts[textIndex], subItemsDataListKey: null, displayFunctionKey: null};

      subItemsDataList.add({key: itemDataMap});
    }
    
    print("subItemsDataList: $subItemsDataList");

    // Building the list data
    var listDataMap=  {itemKey: listKey, itemTextKey: label, itemKeywordsKey: ["Household", "Workplace"],  subItemsDataListKey: subItemsDataList, displayFunctionKey: null};
    var listData = {listKey: listDataMap};

    print("List data: $listData");

    // Adding the list (verified previously as unique)
    data.add(listData);
    // Saving the data
    var f = await _getFile();
    await f.writeAsString(jsonEncode(data));
  }

  /// Updates a list data.
  Future<void> updateListData(String listKey, Map<String, dynamic> listData) async {

    print("updateListData: ");
    print("listData: $listData");

    List<dynamic> data = await loadDataStructure();

    for (var index = 0; index < data.length; index++)
    {
      var currentListData = data[index] as Map<String, dynamic>;
      var currentListDataKeys = currentListData.keys.first;
      if (currentListDataKeys == listKey) 
      {

        // Updating the list data by index and key
        data[index][listKey] = listData;
        print("data[index][listKey]: ${data[index][listKey]}");

      }
    }

    print("data (updated): $data"); 

    // Saving the data
    var f = await _getFile();
    await f.writeAsString(jsonEncode(data));
  }

  /// Removes a list data.
  Future<void> removeListData(List<String> listKeys) async {

    print("removeListData: ");

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

    print("data (updated): $data"); 

    // Saving the data
    var f = await _getFile();
    await f.writeAsString(jsonEncode(data));
  }
}


