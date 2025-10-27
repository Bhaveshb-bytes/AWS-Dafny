include "Duration.dfy"

module TestDuration {
  import Duration

  method TestOfParseString() {
    var parsedResult := Duration.ParseString("PT9650H30M45.123S");
    expect Duration.GetMilliseconds(parsedResult) == 123;
  }

  method Main() {

    TestOfParseString();

    var d1 :=Duration.Duration(1,2);
    var d2 :=Duration.Duration(1,3);
    // Compute total ms
    var total1 := Duration.ToTotalMilliseconds(d1);

    // Addition
    var d3 := Duration.Plus(d1, d2);
    // Subtraction
    var d4 := Duration.Minus(d1, d2);
    // Comparison
    var cmp := Duration.Compare(d1, d2);

    // Equality
    assert d1 == d1;
    assert !(d1==d2);

//basic math and roundtrip correctness

  var d := Duration.Duration(2, 500); // 2.5 seconds
  var scaled := Duration.Scale(d, 2); // 5 seconds
  assert Duration.ToTotalMilliseconds(scaled) == 5000;

  var divided := Duration.Divide(scaled, 2);
  assert divided == d;
  var mod := Duration.Mod(scaled, d);
  assert mod == Duration.FromMilliseconds(0);
  var dmin := Duration.Min(d, scaled);
  var dmax := Duration.Max(d, scaled);
  assert dmin == d;
  assert dmax == scaled;
//Conversion between seconds, minutes, hours
  var oneSec := Duration.FromSeconds(1);
  assert Duration.ToTotalMilliseconds(oneSec) == 1000;

  var oneMin := Duration.FromMinutes(1);
  assert Duration.ToTotalMilliseconds(oneMin) == 60000;

  var oneHour := Duration.FromHours(1);
  assert Duration.ToTotalMilliseconds(oneHour) == 3600000;

  var oneDay := Duration.FromDays(1);
  assert Duration.ToTotalMilliseconds(oneDay) == 86400000;
// Sequence Aggregation(Min/Max)
  var d_1 := Duration.Duration(0, 500);
  var d_2 := Duration.Duration(1, 0);
  var d_3 := Duration.Duration(1, 500);

//comparing edge cases
  var d5 := Duration.FromMilliseconds(1000);
  var d6 := Duration.FromMilliseconds(999);
  assert Duration.Less(d6, d5);
  assert !Duration.Less(d5, d6);

  assert Duration.Compare(d5, d5) == 0;
  assert Duration.Compare(d5, d6) == 1;
  assert Duration.Compare(d6, d5) == -1;

// comparing epoch difference
   var e1 := 5000;
   var e2 := 8000;
   var dd := Duration.EpochDifference(e1, e2);
   assert Duration.ToTotalMilliseconds(dd) == 3000;


//normalization
  var d8 := Duration.FromMilliseconds(2500);
  assert Duration.GetSeconds(d8) == 2;
  assert Duration.GetMilliseconds(d8) == 500;

  }

}