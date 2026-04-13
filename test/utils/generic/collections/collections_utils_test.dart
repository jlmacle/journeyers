import 'package:test/test.dart';

import 'package:journeyers/utils/generic/dev/utility_classes_export.dart';


void main() {
  group('areListsEqualSets', () {
    test('returns true for identical sets (same order)', () {
      expect(cu.areListsEqualSets([1, 2, 3], [1, 2, 3]), isTrue);
    });

    test('returns true for identical sets (different order)', () {
      expect(cu.areListsEqualSets([1, 2, 3], [3, 2, 1]), isTrue);
    });

    test('returns true for identical sets with duplicates', () {
      expect(cu.areListsEqualSets([1, 2, 2, 3], [3, 2, 1]), isTrue);
    });

    test('returns false for different sets', () {
      expect(cu.areListsEqualSets([1, 2, 3], [1, 2, 4]), isFalse);
    });

    test('returns false for different sets (2)', () {
      expect(cu.areListsEqualSets([1, 2, 3], []), isFalse);
    });

    test('returns true for empty lists', () {
      expect(cu.areListsEqualSets([], []), isTrue);
    });

    test('returns true for lists with null values', () {
      expect(cu.areListsEqualSets([1, null, 3], [null, 3, 1]), isTrue);
    });

    test('returns false for lists with different null counts', () {
      expect(cu.areListsEqualSets([1, null, 3], [1, 3]), isFalse);
    });
  });
}