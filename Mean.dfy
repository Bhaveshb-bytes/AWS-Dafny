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

    // Compute the mean of a list of natural numbers.
    // The result is a rational number represented as a pair (numerator, denominator).

    method Min(list: array<int>) returns (min: int)
        requires NonEmpty(list)
    method Max(list: array<int>) returns (max: int)
        requires NonEmpty(list)

    method Mean(list: array<int>) returns (mean: int) 
        ensures Mean(list) == Sum(list) / |list|
        ensures Min(list) <= Mean(list) <= Max(list) {
        sum := Sum(list);
        len := list.Length;
        if len == 0 {
            return 0;
        } else {
            return sum / len;
        }
    }       
}