include "statistics.dfy"

module TestStatistics {
  import opened Statistics

  method {:test} TestSum() {
    assert Sum([]) == 0.0;
    assert Sum([1.0, 2.0, 3.0]) == 6.0;
    assert Sum([-5.0, 0.0, 10.0]) == 5.0;
  }

  method {:test} TestMean() {
    assert Mean([42.0]) == 42.0;
    assert Mean([2.0, 4.0, 6.0, 8.0]) == 5.0;
    assert Mean([1.5, 2.5, 3.5]) == 2.5;
  }

  method {:test} TestMedianByDefinition_Odd() {
    var s := [3.0, 1.0, 2.0];
    var m: real;
    m := Median(s);
    MergeSort_Length(s);
    var t := MergeSort(s);
    assert m == t[|t|/2];
  }

  method {:test} TestMedianByDefinition_Even() {
    var s := [4.0, 1.0, 2.0, 3.0];
    var m: real;
    m := Median(s);
    MergeSort_Length(s);
    var t := MergeSort(s);
    assert |t| % 2 == 0;
    EvenPositiveImpliesAtLeastTwo(|t| as nat);
    assert m == (t[|t|/2 - 1] + t[|t|/2]) / 2.0;
  }

  method {:test} TestMedianNegatives_ByDefinition() {
    var s := [-5.0, -1.0, -3.0];
    var m: real;
    m := Median(s);
    MergeSort_Length(s);
    var t := MergeSort(s);
    assert m == t[|t|/2];
  }
}
