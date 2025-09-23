module Statistics {

  function Sum(s: seq<real>) : real
    decreases |s|
  {
    if |s| == 0 then 0.0 else s[0] + Sum(s[1..])
  }

  function Mean(s: seq<real>) : real
    requires |s| > 0
  {
    Sum(s) / (|s| as real)
  }

  predicate Sorted(s: seq<real>)
  {
    forall i :: 0 <= i && i + 1 < |s| ==> s[i] <= s[i+1]
  }

  function Merge(left: seq<real>, right: seq<real>) : seq<real>
    decreases |left| + |right|
  {
    if |left| == 0 then right
    else if |right| == 0 then left
    else if left[0] <= right[0]
         then [left[0]] + Merge(left[1..], right)
         else [right[0]] + Merge(left, right[1..])
  }

  function MergeSort(s: seq<real>) : seq<real>
    decreases |s|
  {
    if |s| <= 1 then s
    else
      var mid := |s| / 2;
      Merge(MergeSort(s[..mid]), MergeSort(s[mid..]))
  }

  lemma Merge_Length(left: seq<real>, right: seq<real>)
    ensures |Merge(left,right)| == |left| + |right|
    decreases |left| + |right|
  {
    if |left| == 0 || |right| == 0 { }
    else if left[0] <= right[0] {
      Merge_Length(left[1..], right);
    } else {
      Merge_Length(left, right[1..]);
    }
  }

  lemma MergeSort_Length(s: seq<real>)
    ensures |MergeSort(s)| == |s|
    decreases |s|
  {
    if |s| <= 1 { }
    else {
      var mid := |s| / 2;
      MergeSort_Length(s[..mid]);
      MergeSort_Length(s[mid..]);
      Merge_Length(MergeSort(s[..mid]), MergeSort(s[mid..]));
    }
  }

  lemma Merge_Sorted(left: seq<real>, right: seq<real>)
    requires Sorted(left) && Sorted(right)
    ensures Sorted(Merge(left,right))
    decreases |left| + |right|
  {
    if |left| == 0 || |right| == 0 {
    } else if left[0] <= right[0] {
      Merge_Sorted(left[1..], right);
      if |left| >= 2 {
        assert left[0] <= left[1];
      } else {
        assert left[0] <= right[0];
      }
    } else {
      Merge_Sorted(left, right[1..]);
      if |right| >= 2 {
        assert right[0] <= right[1];
      } else {
        assert right[0] <= left[0];
      }
    }
  }

  lemma MergeSort_Sorted(s: seq<real>)
    ensures Sorted(MergeSort(s))
    decreases |s|
  {
    if |s| <= 1 { }
    else {
      var mid := |s| / 2;
      MergeSort_Sorted(s[..mid]);
      MergeSort_Sorted(s[mid..]);
      Merge_Sorted(MergeSort(s[..mid]), MergeSort(s[mid..]));
    }
  }

  lemma EvenPositiveImpliesAtLeastTwo(n: nat)
    requires n > 0 && n % 2 == 0
    ensures n >= 2
  { }

  method Median(s: seq<real>) returns (m: real)
    requires |s| > 0
    ensures if |MergeSort(s)| % 2 == 1
            then m == MergeSort(s)[|MergeSort(s)|/2]
            else m == (MergeSort(s)[|MergeSort(s)|/2 - 1] + MergeSort(s)[|MergeSort(s)|/2]) / 2.0
  {
    var t := MergeSort(s);
    MergeSort_Length(s);
    if |t| % 2 == 1 {
      m := t[|t|/2];
      assert m == MergeSort(s)[|MergeSort(s)|/2];
    } else {
      assert |t| > 0;
      EvenPositiveImpliesAtLeastTwo(|t| as nat);
      m := (t[|t|/2 - 1] + t[|t|/2]) / 2.0;
      assert m == (MergeSort(s)[|MergeSort(s)|/2 - 1] + MergeSort(s)[|MergeSort(s)|/2]) / 2.0;
    }
  }
}
