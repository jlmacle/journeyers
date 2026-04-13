/// {@category Utils - Generic}
/// A generic utility class related to collections of items.
class CollectionsUtils 
{
  /// Method used to test that two lists have identical sets of elements
  bool areListsEqualSets(List list1, List list2) 
  {
    return Set.from(list1).difference(Set.from(list2)).isEmpty;
  }

}
