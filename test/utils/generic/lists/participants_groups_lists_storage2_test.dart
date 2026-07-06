import 'package:test/test.dart';

import 'package:journeyers/widgets/utility/lists/database/text_lists_storage.dart';


void main() {
  ListsDB storage = ListsDB();

  group('getNextKey', () {
    // 'Next key after "a1"'
    test('Next key after "a1"', () 
    {
      String nextKey = storage.getNextKey(key: "a1");      

      expect(nextKey, "a2");
    });

    // 'Next key after "ab9"'
    test('Next key after "ab9"', () 
    {
      String nextKey = storage.getNextKey(key: "ab9");      

      expect(nextKey, "ac0");
    });

    // 'Next key after "z9"'
    test('Next key after "z9"', () 
    {
      String nextKey = storage.getNextKey(key: "z9");      

      expect(nextKey, "aa0");
    });

    // 'Next key after "zzz9"'
    test('Next key after "zzz9"', () 
    {
      String nextKey = storage.getNextKey(key: "zzz9");      

      expect(nextKey, "aaaa0");
    });

    // 'Next key after "az9"'
    test('Next key after "az9"', () 
    {
      String nextKey = storage.getNextKey(key: "az9");      

      expect(nextKey, "ba0");
    });

    // 'Next key after "aaz9"'
    test('Next key after "aaz9"', () 
    {
      String nextKey = storage.getNextKey(key: "aaz9");      

      expect(nextKey, "aba0");
    });

  });  
}