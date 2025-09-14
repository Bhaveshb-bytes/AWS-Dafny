include "Duration.dfy"

module TestDuration {
  import Std.DateTime.Duration

  method Main() {
    var d1 := Duration.Duration(10, 500);
    var d2 := Duration.Duration(5, 250);

    // Check validity
    assert Duration.IsValid(d1);
    assert Duration.IsValid(d2);

    // Compute total ms
    var total1 := Duration.ToTotalMilliseconds(d1);
    print "d1 total ms: ", total1, "\n";

    // Addition
    var d3 := Duration.Plus(d1, d2);
    print "d1 + d2 = ", d3, "\n";
    //ShowDuration(d3);
    // Subtraction
    var d4 := Duration.Minus(d1, d2);
    print "d1 - d2 = ", d4, "\n";
    //ShowDuration(d4);
    // Comparison
    var cmp := Duration.Compare(d1, d2);
    print "compare(d1,d2) = ", cmp, "\n";

    // Equality
    assert Duration.Equal(d1, d1);
    assert !Duration.Equal(d1, d2);
  }
  
}

