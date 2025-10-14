module Std.Mean {

    // this is to sum up all elements in the array
    method Sum(arr: array<int>) returns (total: int) 
      requires arr != null
      ensures total == (sum i | 0 <= i < arr.Length :: arr[i]) 
    {
      total := 0;
      var i := 0;
      // this will loop through and add each element
      while i < arr.Length
        invariant 0 <= i <= arr.Length
        invariant total == (sum j | 0 <= j < i :: arr[j])
      {
        total := total + arr[i];
        i := i + 1;
      }
    }   
  
    // This function is here is to compute the mean (average) as a real number
    method Mean(arr: array<int>) returns (average: real)
      requires arr != null && arr.Length > 0
      ensures average == (sum i | 0 <= i < arr.Length :: arr[i]) as real / arr.Length
    {
      var sumVal := Sum(arr);
      average := sumVal as real / arr.Length;
    }
  
    // this function is to calculate Population variance (in which we divide squared differences by n)
    method VariancePopulation(arr: array<int>) returns (variance: real)
      requires arr != null && arr.Length > 0
      ensures variance >= 0.0
    {
      var avg := Mean(arr);            // first we will get the mean
      var squaredTotal := 0.0;         // here we calculate the sum of squared differences
      var i := 0;
      while i < arr.Length
      {
        var gap := arr[i] as real - avg; // this is done here to calculate the difference from mean
        squaredTotal := squaredTotal + gap*gap;
        i := i + 1;
      }
      variance := squaredTotal / arr.Length;
    }
  
    // This function is to calculate Sample variance (in which we divide squared differences by n-1)
    method VarianceSample(arr: array<int>) returns (variance: real)
      requires arr != null && arr.Length > 1
      ensures variance >= 0.0
    {
      var avg := Mean(arr);
      var squaredTotal := 0.0;
      var i := 0;
      while i < arr.Length
      {
        var gap := arr[i] as real - avg;
        squaredTotal := squaredTotal + gap*gap;
        i := i + 1;
      }
      variance := squaredTotal / (arr.Length - 1);
    }
  }
