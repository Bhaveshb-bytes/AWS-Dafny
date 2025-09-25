include "statistics.dfy"

module TestStatistics {
  import opened Statistics


  method {:test} test_median_Odd() {
    var s := [3.0, 1.0, 2.0];
    var m: real;
    m := Median(s);
    merge_split_Length(s);
    var t := merge_split(s);
    assert m == t[|t|/2];
  }

  method {:test} test_median_Even() {
    var s := [4.0, 1.0, 2.0, 3.0];
    var m: real;
    m := Median(s);
    merge_split_Length(s);
    var t := merge_split(s);
    assert |t| % 2 == 0;
    assert m == (t[|t|/2 - 1] + t[|t|/2]) / 2.0;
  }

  method {:test} test_median_negative() {
    var s := [-5.0, -1.0, -3.0];
    var m: real;
    m := Median(s);
    merge_split_Length(s);
    var t := merge_split(s);
    assert m == t[|t|/2];
  }
}
