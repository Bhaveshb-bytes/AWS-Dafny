module StatisticsLibrary {
    // A function to sum the elements of a sequence
    function Sum(s: seq<real>): real
        ensures s == [] ==> Sum(s) == 0.0
        ensures |s| > 0 ==> Sum(s) == s[0] + Sum(s[1..])
    {
        if |s| == 0 then
            0.0
        else
            s[0] + Sum(s[1..])
    }

    // A function to compute the mean (average) as a real number
    function Mean(s: seq<real>): real
        requires |s| > 0
        ensures Mean(s) == Sum(s) / (|s| as real)
    {
        Sum(s) / (|s| as real)
    }

    // A helper function to calculate the sum of squared differences from a given mean
    function SumSquaredDifferences(s: seq<real>, avg: real): real
        ensures SumSquaredDifferences(s, avg) >= 0.0
        ensures s == [] ==> SumSquaredDifferences(s, avg) == 0.0
        ensures |s| > 0 ==> SumSquaredDifferences(s, avg) == (s[0] - avg) * (s[0] - avg) + SumSquaredDifferences(s[1..], avg)
    {
        if |s| == 0 then
            0.0
        else
            var diff := s[0] - avg;
            diff * diff + SumSquaredDifferences(s[1..], avg)
    }

    // A function to calculate Population Variance
    function VariancePopulation(s: seq<real>): real
        requires |s| > 0
        ensures VariancePopulation(s) >= 0.0
        ensures VariancePopulation(s) == SumSquaredDifferences(s, Mean(s)) / (|s| as real)
    {
        var avg := Mean(s);
        SumSquaredDifferences(s, avg) / (|s| as real)
    }

     // A function to calculate Sample Variance
    function VarianceSample(s: seq<real>): real
      requires |s| > 1
      ensures VarianceSample(s) >= 0.0
    {
      var avg := Mean(s);
      (SumSquaredDifferences(s, avg)) / ((|s| - 1) as real)
    }

     // A function to calculate Population Standard Deviation
    function StdDevPopulation(s: seq<real>): real
      requires |s| > 0
      ensures StdDevPopulation(s) >= 0.0
    {
      sqrt(VariancePopulation(s)) // here I would use the extern library as Robin suggested during the meeting, currently this method is not working but I will update it next time.
    }

    // A function to calculate Sample Standard Deviation
    function StdDevSample(s: seq<real>): real
      requires |s| > 1
      ensures StdDevSample(s) >= 0.0
    {
      sqrt(VarianceSample(s)) // here I would use the extern library as Robin suggested during the meeting, currently this method is not working but I will update it next time.
    }

}
