module Std.Median {
    import Std.Sort;

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
}