// [a, b, ..., y]
List<String> alphabetList =
[
  for (int i = 0; i <= 25; i++) String.fromCharCode(97 + i)
];

// [a, b, ..., y]
List<String> alphabetListMinusZ =
[
  for (int i = 0; i <= 24; i++) String.fromCharCode(97 + i)
];


// {"a":0, "b":1, ... }
Map<String, int> alphabetToIndexMap = 
{
  for (int i = 0; i <= 25; i++) String.fromCharCode(97 + i) : i,
};