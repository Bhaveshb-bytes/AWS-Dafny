// This file shows the test cases for Sum, mean and variance

include "StatisticsLibrary.dfy"

module TestModule {
  import opened StatisticsLibrary

  // Test cases for the StatisticsLibrary functions

  // A test case for the Sum function with various inputs
 
  method  {:test} TestSum() {
    assert Sum([1.0, 2.0, 3.0, 4.0, 5.0]) == 15.0;
    assert Sum([1.5, 2.5, 3.5]) == 7.5;
    assert Sum([100.0]) == 100.0;
    assert Sum([-10.0, 0.0, 10.0, 20.0]) == 20.0;
    assert Sum([]) == 0.0;
  }

  // A test case for the Mean function
  method {:test} TestMean() {
    assert Mean([1.0, 2.0, 3.0, 4.0, 5.0]) == 3.0;
    assert Mean([1.5, 2.5, 3.5]) == 2.5;
    assert Mean([100.0]) == 100.0;
    assert Mean([-10.0, 0.0, 10.0, 20.0]) == 5.0;
  }

  // A test case for the Variance functions
  method {:test} TestVariance() {
    var data := [1.0, 2.0, 3.0, 4.0, 5.0];
    assert VariancePopulation(data) == 2.0;
    assert VarianceSample(data) == 2.5;

    var data2 := [6.0, 7.0, 8.0, 9.0, 10.0];
    assert VariancePopulation(data2) == 2.0;
    assert VarianceSample(data2) == 2.5;
    
    // Example with decimals
    var data3 := [1.5, 2.5, 3.5, 4.5, 5.5];
    assert VariancePopulation(data3) == 2.0;
    assert VarianceSample(data3) == 2.5;
  }
}
