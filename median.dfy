module Std.Median {
    
    import Std.Sort; //This will work when we have a sorting library which will have different sorting techniques

    // The method to calculate median based on even and odd indices. It depends on sort functioon to first get the sorted aray
    method Median(s: array<int>) returns (median: int)
        requires |s| > 0
        ensures (|s| % 2 == 1 ==> Median(s) == Sort(s)[|s|/2])
        ensures (|s| % 2 == 0 ==> Median(s) == (Sort(s)[|s|/2 - 1] + Sort(s)[|s|/2]) / 2.0) {
        var sorted := Sort(s)
        if |s| % 2 == 1 then
            sorted[|s| / 2]
        else
            (sorted[|s| / 2 - 1] + sorted[|s| / 2]) / 2.0
    }

    
    // The sorting function which uses the merge sort principle to sort the array 
    method Sort(ia: array<int>) returns (fa: array<int>) {
        var tmp := new int[|ia|]
        mergesort(ia, tmp, 0, |ia|)
        fa := ia
    }
    // The merge sort method that recursively divides the array and then calls the merge function to sort it
    method mergesort(ia: array<int>, tmp: array<int>, first: int, last: int) {
        if last -first <= 1 then
            return
        var middle := first+ (last - first)/ 2
        mergesort(ia, tmp, first, middle)
        mergesort(ia, tmp, middle, last)
        Merge(ia, tmp, first, middle, last)
    }

    // The final merge function which merges the elements in a sorted manner
    method Merge(ia: array<int>, tmp: array<int>, first: int, middle: int, last: int) {
        var i := first
        var j := middle
        var k := 0
        while i < middle && j < last do
            if ia[i] <= ia[j] then
                tmp[k]:= ia[i]; i:=i + 1
            else
                tmp[k] := ia[j]; j:= j + 1
            k := k + 1
        while i < middle do
            tmp[k]:= ia[i]; i:= i + 1; k:= k + 1

        while j < last do
            tmp[k]:= ia[j]; j:= j + 1; k:= k + 1

        var t:= 0
        while t < k do
            ia[first + t]:= tmp[t]
            t:= t + 1
    }
}
