include "DateTimeUtils.dfy"

module TestEpochTimeConversion {
  import DateTimeUtils
  
  method TestToEpochTimeMilliseconds()
  {
    // Test a known date: 2023-01-01 00:00:00.000
    var epochMillis := DateTimeUtils.ToEpochTimeMilliseconds(2023, 1, 1, 0, 0, 0, 0);
    print "Epoch milliseconds for 2023-01-01 00:00:00.000: ", epochMillis, "\n";
    
    // Test another date: 2024-12-31 23:59:59.999
    var epochMillis2 := DateTimeUtils.ToEpochTimeMilliseconds(2024, 12, 31, 23, 59, 59, 999);
    print "Epoch milliseconds for 2024-12-31 23:59:59.999: ", epochMillis2, "\n";
  }
  
  method TestFromEpochTimeMilliseconds()
  {
    // Test conversion from epoch milliseconds back to date components
    var epochMillis := 1672531200000; // 2023-01-01 00:00:00.000 UTC
    var components := DateTimeUtils.FromEpochTimeMilliseconds(epochMillis);
    
    print "Components for epoch ", epochMillis, ": ";
    print "Year: ", components[0], ", ";
    print "Month: ", components[1], ", ";
    print "Day: ", components[2], ", ";
    print "Hour: ", components[3], ", ";
    print "Minute: ", components[4], ", ";
    print "Second: ", components[5], ", ";
    print "Millisecond: ", components[6], "\n";
  }
  
  method TestRoundTrip()
  {
    // Test round trip conversion
    var year, month, day, hour, minute, second, millisecond := 2023, 6, 15, 14, 30, 45, 123;
    
    print "Original: ", year, "-", month, "-", day, " ", hour, ":", minute, ":", second, ".", millisecond, "\n";
    
    // Convert to epoch milliseconds
    var epochMillis := DateTimeUtils.ToEpochTimeMilliseconds(year, month, day, hour, minute, second, millisecond);
    print "Epoch milliseconds: ", epochMillis, "\n";
    
    // Convert back to components
    var components := DateTimeUtils.FromEpochTimeMilliseconds(epochMillis);
    print "Round trip result: ";
    print components[0], "-", components[1], "-", components[2], " ";
    print components[3], ":", components[4], ":", components[5], ".", components[6], "\n";
    
    // Verify they match
    if year == components[0] && month == components[1] && day == components[2] &&
       hour == components[3] && minute == components[4] && second == components[5] &&
       millisecond == components[6] {
      print "Round trip test PASSED\n";
    } else {
      print "Round trip test FAILED\n";
    }
  }
  
  method Main()
  {
    print "Testing epoch time conversion functions...\n";
    print "========================================\n";
    
    TestToEpochTimeMilliseconds();
    print "\n";
    
    TestFromEpochTimeMilliseconds();
    print "\n";
    
    TestRoundTrip();
    print "\n";
    
    print "Test completed.\n";
  }
}