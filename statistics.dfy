module Statistics {

  
  predicate Sorted(s: seq<real>)
  {
    forall i :: 0 <= i && i + 1 < |s| ==> s[i] <= s[i+1]
  }
 // This is the join function which combines the 2 sorted parts
  function merge_join(first: seq<real>, second: seq<real>) : seq<real>
    decreases |first| + |second|
  {
    if |first| == 0 then second
    else if |second| == 0 then first
    else if first[0] <= second[0]
         then [first[0]] + merge_join(first[1..], second)
         else [second[0]] + merge_join(first, second[1..])
  }
// This is the split function which splits the sequence into 2 parts
  function merge_split(s: seq<real>) : seq<real>
    decreases |s|
  {
    if |s| <= 1 then s
    else
      var mid := |s| / 2;
      merge_join(merge_split(s[..mid]), merge_split(s[mid..]))
  }

  lemma merge_join_Length(first: seq<real>, second: seq<real>)
    ensures |merge_join(first,second)| == |first| + |second|
    decreases |first| + |second|
  {
    if |first| == 0 || |second| == 0 { }
    else if first[0] <= second[0] {
      merge_join_Length(first[1..], second);
    } else {
      merge_join_Length(first, second[1..]);
    }
  }

  lemma merge_split_Length(s: seq<real>)
    ensures |merge_split(s)| == |s|
    decreases |s|
  {
    if |s| <= 1 { }
    else {
      var mid := |s| / 2;
      merge_split_Length(s[..mid]);
      merge_split_Length(s[mid..]);
      merge_join_Length(merge_split(s[..mid]), merge_split(s[mid..]));
    }
  }

  lemma merge_join_sorted(first: seq<real>, second: seq<real>)
    requires Sorted(first) && Sorted(second)
    ensures Sorted(merge_join(first,second))
    decreases |first| + |second|
  {
    if |first| == 0 || |second| == 0 {
    } else if first[0] <= second[0] {
      merge_join_sorted(first[1..], second);
      if |first| >= 2 {
        assert first[0] <= first[1];
      } else {
        assert first[0] <= second[0];
      }
    } else {
      merge_join_sorted(first, second[1..]);
      if |second| >= 2 {
        assert second[0] <= second[1];
      } else {
        assert second[0] <= first[0];
      }
    }
  }

  lemma merge_split_Sorted(s: seq<real>)
    ensures Sorted(merge_split(s))
    decreases |s|
  {
    if |s| <= 1 { }
    else {
      var mid := |s| / 2;
      merge_split_Sorted(s[..mid]);
      merge_split_Sorted(s[mid..]);
      merge_join_sorted(merge_split(s[..mid]), merge_split(s[mid..]));
    }
  }

  

  method Median(s: seq<real>) returns (m: real)
  requires |s| > 0
  ensures (|merge_split(s)| % 2 == 1 ==> 
             m == merge_split(s)[|merge_split(s)|/2])
  ensures (|merge_split(s)| % 2 == 0 && |merge_split(s)| >= 2 ==> 
             m == (merge_split(s)[|merge_split(s)|/2 - 1] + merge_split(s)[|merge_split(s)|/2]) / 2.0)
{
  var t := merge_split(s);
 merge_split_Length(s);                         
  if |t| % 2 == 1 {
    m := t[|t|/2];
  } else {
    m := (t[|t|/2 - 1] + t[|t|/2]) / 2.0;
  }
}
}
