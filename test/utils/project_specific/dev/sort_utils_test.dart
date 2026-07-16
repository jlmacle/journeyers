import "package:test/test.dart";

import "package:journeyers/utils/project_specific/dev/sort_utils.dart";

/// The method assumes that all keys have the same length.
void main()
{

  group("sort_utils", () 
  {
    test('["a3","a1","a2"]', 
    ()
    {
      expect(getBiggestKey(["a3","a1","a2"]), "a3");
    });

    test('["aa3","ab1","da2"]', 
    ()
    {
      expect(getBiggestKey(["aa3","ab1","da2"]), "da2");
    });


     test('["aabz3","afsf1","dfds2"]', 
    ()
    {
      expect(getBiggestKey(["aabz3","afsf1","dfds2"]), "dfds2");
    });


  });
}
