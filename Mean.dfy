module Std.Mean {

    method Sum(arr: array<int>) returns (total: int) 
        requires arr != null
        ensures total == (sum i | 0 <= i < arr.Length :: arr[i]) {
        total := 0;
        var i := 0;

        while i < arr.Length
            invariant 0 <= i <= arr.Length
            invariant total == (sum j | 0 <= j < i :: arr[j])
        {
            total := total + arr[i];
            i := i + 1;
        }
    }   

   method Mean(arr: array<int>) returns (mean: real)
    requires arr != null && arr.Length > 0
    ensures mean == (sum i | 0 <= i < arr.Length :: arr[i]) as real / arr.Length
  {
    var s := Sum(arr);
    mean := s as real / arr.Length;
  }

}
