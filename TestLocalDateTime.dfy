include "LocalDateTime.dfy"
include "Duration.dfy"

module TestLocalDateTime {
  import LDT = Std.DateTime.LocalDateTime
  import Duration = Std.DateTime.Duration

  method TestOfFunction()
  {
    print "=== Testing Of Function ===\n";
    
    // Test valid date
    var result1 := LDT.Of(2023, 6, 15, 14, 30, 45, 123);
    match result1 {
      case Success(dt) => {
        print "✓ Valid date created: ", LDT.ToString(dt), "\n";
      }
      case Failure(error) => {
        print "✗ Unexpected error: ", error, "\n";
      }
    }
    
    // Test invalid month (improved error message)
    var result2 := LDT.Of(2023, 13, 15, 14, 30, 45, 123);
    match result2 {
      case Success(dt) => {
        print "✗ Should have failed for invalid month\n";
      }
      case Failure(error) => {
        print "✓ Enhanced error for invalid month: ", error, "\n";
      }
    }
    
    // Test Feb 29 in non-leap year (improved error message)
    var result3 := LDT.Of(2023, 2, 29, 14, 30, 45, 123);
    match result3 {
      case Success(dt) => {
        print "✗ Should have failed for Feb 29 in non-leap year\n";
      }
      case Failure(error) => {
        print "✓ Enhanced error for Feb 29 in non-leap year: ", error, "\n";
      }
    }
    
    // Test Feb 29 in leap year
    var result4 := LDT.Of(2020, 2, 29, 14, 30, 45, 123);
    match result4 {
      case Success(dt) => {
        print "✓ Feb 29 in leap year: ", LDT.ToString(dt), "\n";
      }
      case Failure(error) => {
        print "✗ Unexpected error for leap year: ", error, "\n";
      }
    }
    
    // Test other invalid values with enhanced error messages
    var result5 := LDT.Of(2023, 6, 32, 14, 30, 45, 123);
    match result5 {
      case Success(dt) => {
        print "✗ Should have failed for invalid day\n";
      }
      case Failure(error) => {
        print "✓ Enhanced error for invalid day: ", error, "\n";
      }
    }
    
    var result6 := LDT.Of(2023, 6, 15, 25, 30, 45, 123);
    match result6 {
      case Success(dt) => {
        print "✗ Should have failed for invalid hour\n";
      }
      case Failure(error) => {
        print "✓ Enhanced error for invalid hour: ", error, "\n";
      }
    }
    
    var result7 := LDT.Of(2023, 6, 15, 14, 60, 45, 123);
    match result7 {
      case Success(dt) => {
        print "✗ Should have failed for invalid minute\n";
      }
      case Failure(error) => {
        print "✓ Enhanced error for invalid minute: ", error, "\n";
      }
    }
  }

  method TestParseFunction()
  {
    print "\n=== Testing Parse Function ===\n";
    
    // Test valid ISO format
    var result1 := LDT.Parse("2023-06-15T14:30:45.123");
    match result1 {
      case Success(dt) => {
        print "✓ Parsed: ", LDT.ToString(dt), "\n";
      }
      case Failure(error) => {
        print "✗ Parse error: ", error, "\n";
      }
    }
    
    // Test invalid format
    var result2 := LDT.Parse("2023/06/15 14:30:45");
    match result2 {
      case Success(dt) => {
        print "✗ Should have failed for invalid format\n";
      }
      case Failure(error) => {
        print "✓ Expected error for invalid format: ", error, "\n";
      }
    }
    
    // Test short string
    var result3 := LDT.Parse("2023-06-15");
    match result3 {
      case Success(dt) => {
        print "✗ Should have failed for short string\n";
      }
      case Failure(error) => {
        print "✓ Expected error for short string: ", error, "\n";
      }
    }
  }

  method TestCompareFunction()
  {
    print "\n=== Testing Compare Function ===\n";
    
    var dt1 := LDT.LocalDateTime(2023, 6, 15, 14, 30, 45, 123);
    var dt2 := LDT.LocalDateTime(2023, 6, 15, 14, 30, 45, 124);
    var dt3 := LDT.LocalDateTime(2023, 6, 15, 14, 30, 45, 123);
    
    var cmp1 := LDT.CompareLocal(dt1, dt2);
    var cmp2 := LDT.CompareLocal(dt2, dt1);
    var cmp3 := LDT.CompareLocal(dt1, dt3);
    
    print "dt1 < dt2: ", cmp1, " (expected: -1)\n";
    print "dt2 > dt1: ", cmp2, " (expected: 1)\n";
    print "dt1 == dt3: ", cmp3, " (expected: 0)\n";
  }

  method TestArithmeticFunctions()
  {
    print "\n=== Testing Arithmetic Functions ===\n";
    
    var dt := LDT.LocalDateTime(2023, 6, 15, 14, 30, 45, 123);
    var duration := Duration.Duration(3661, 500); // 1 hour, 1 minute, 1 second, 500ms
    
    print "Original: ", LDT.ToString(dt), "\n";
    
    var plusResult := LDT.Plus(dt, duration);
    print "Plus 1h 1m 1s 500ms: ", LDT.ToString(plusResult), "\n";
    
    var minusResult := LDT.Minus(dt, duration);
    print "Minus 1h 1m 1s 500ms: ", LDT.ToString(minusResult), "\n";
    
    // Test cross-day boundary
    var lateNight := LDT.LocalDateTime(2023, 6, 15, 23, 30, 45, 123);
    var longDuration := Duration.Duration(7200, 0); // 2 hours
    var nextDay := LDT.Plus(lateNight, longDuration);
    print "23:30 + 2h = ", LDT.ToString(nextDay), "\n";
  }

  method TestFormatFunction()
  {
    print "\n=== Testing Format Function ===\n";
    
    var dt := LDT.LocalDateTime(2023, 6, 15, 14, 30, 45, 123);
    
    print "Original: ", LDT.ToString(dt), "\n";
    print "Date only: ", LDT.Format(dt, "yyyy-MM-dd"), "\n";
    print "Time only: ", LDT.Format(dt, "HH:mm:ss"), "\n";
    print "Date time: ", LDT.Format(dt, "yyyy-MM-dd HH:mm:ss"), "\n";
    print "European: ", LDT.Format(dt, "dd/MM/yyyy"), "\n";
    print "US format: ", LDT.Format(dt, "MM/dd/yyyy"), "\n";
    print "Unknown pattern: ", LDT.Format(dt, "custom"), "\n";
  }

  method TestHelperFunctions()
  {
    print "\n=== Testing Helper Functions ===\n";
    
    var dt := LDT.LocalDateTime(2023, 6, 15, 14, 30, 45, 123); // Thursday
    
    print "Date: ", LDT.ToString(dt), "\n";
    print "Day of week: ", LDT.GetDayOfWeek(dt), " (0=Sun, 1=Mon, ..., 6=Sat)\n";
    print "Day of year: ", LDT.GetDayOfYear(dt), " (optimized lookup)\n";
    
    // Test New Year's Day
    var newYear := LDT.LocalDateTime(2023, 1, 1, 0, 0, 0, 0);
    print "Jan 1 day of year: ", LDT.GetDayOfYear(newYear), "\n";
    
    // Test month name function
    print "Month 6 name: ", LDT.GetMonthName(6), "\n";
    print "Month 2 name: ", LDT.GetMonthName(2), "\n";
    print "Month 12 name: ", LDT.GetMonthName(12), "\n";
    
    // Test time conversion functions
    var timeMillis := LDT.TimeToMilliseconds(dt);
    print "Time as milliseconds: ", timeMillis, "\n";
    var (h, m, s, ms) := LDT.MillisecondsToTime(timeMillis);
    print "Converted back - Hour: ", h, ", Minute: ", m, ", Second: ", s, ", Millisecond: ", ms, "\n";
    
    // Test leap year
    print "2020 is leap year: ", LDT.IsLeapYear(2020), "\n";
    print "2021 is leap year: ", LDT.IsLeapYear(2021), "\n";
    print "1900 is leap year: ", LDT.IsLeapYear(1900), "\n";
    print "2000 is leap year: ", LDT.IsLeapYear(2000), "\n";
  }

  method TestEdgeCases()
  {
    print "\n=== Testing Edge Cases ===\n";
    
    // Test year boundaries
    var endOfYear := LDT.LocalDateTime(2023, 12, 31, 23, 59, 59, 999);
    var oneMS := Duration.Duration(0, 1);
    var newYear := LDT.Plus(endOfYear, oneMS);
    print "End of year + 1ms: ", LDT.ToString(newYear), "\n";
    
    // Test month boundaries
    var endOfJan := LDT.LocalDateTime(2023, 1, 31, 23, 59, 59, 999);
    var nextDay := LDT.Plus(endOfJan, oneMS);
    print "Jan 31 23:59:59.999 + 1ms: ", LDT.ToString(nextDay), "\n";
    
    // Test large duration
    var bigDuration := Duration.Duration(86399, 999); // Almost a full day
    var almostNextDay := LDT.Plus(endOfYear, bigDuration);
    print "End of year + 23:59:59.999: ", LDT.ToString(almostNextDay), "\n";
  }

  method TestOptimizations()
  {
    print "\n=== Testing Optimizations ===\n";
    
    // Test optimized arithmetic functions
    var baseTime := LDT.LocalDateTime(2023, 6, 15, 12, 0, 0, 0);
    
    // Test multiple operations to verify performance
    var duration1 := Duration.Duration(3600, 500); // 1 hour 500ms
    var duration2 := Duration.Duration(1800, 250); // 30 min 250ms
    var duration3 := Duration.Duration(900, 750);  // 15 min 750ms
    
    var result1 := LDT.Plus(baseTime, duration1);
    var result2 := LDT.Plus(result1, duration2);
    var result3 := LDT.Plus(result2, duration3);
    
    print "Base time: ", LDT.ToString(baseTime), "\n";
    print "After +1h 500ms: ", LDT.ToString(result1), "\n";
    print "After +30m 250ms: ", LDT.ToString(result2), "\n";
    print "After +15m 750ms: ", LDT.ToString(result3), "\n";
    
    // Test optimized subtraction
    var backToStart := LDT.Minus(LDT.Minus(LDT.Minus(result3, duration3), duration2), duration1);
    print "Back to start: ", LDT.ToString(backToStart), "\n";
    
    // Test GetDayOfYear optimization for various months
    print "Day of year tests (optimized lookup):\n";
    var months := [1, 3, 6, 9, 12];
    var i := 0;
    while i < |months|
    {
      var testDate := LDT.LocalDateTime(2023, months[i], 15, 12, 0, 0, 0);
      var dayOfYear := LDT.GetDayOfYear(testDate);
      var monthName := LDT.GetMonthName(months[i]);
      print "- ", monthName, " 15: Day ", dayOfYear, "\n";
      i := i + 1;
    }
    
    // Test time conversion round-trip
    var originalTime := LDT.LocalDateTime(2023, 6, 15, 14, 30, 45, 123);
    var millis := LDT.TimeToMilliseconds(originalTime);
    var (h, m, s, ms) := LDT.MillisecondsToTime(millis);
    var reconstructed := LDT.LocalDateTime(2023, 6, 15, h, m, s, ms);
    
    print "Time conversion round-trip test:\n";
    print "Original: ", LDT.ToString(originalTime), "\n";
    print "Reconstructed: ", LDT.ToString(reconstructed), "\n";
    print "Round-trip successful: ", if LDT.CompareLocal(originalTime, reconstructed) == 0 then "✓" else "✗", "\n";
  }

  method TestNowFunction()
  {
    print "\n=== Testing Now Function ===\n";
    
    // Test basic Now functionality
    var result := LDT.Now();
    match result {
      case Success(dt) => {
        assert LDT.IsValidLocalDateTime(dt);  // This follows from Now's ensures clause
        print "✓ Current time obtained successfully\n";
        // Test validation - the current time should always be valid
        if LDT.IsValidLocalDateTime(dt) {
          print "✓ Current time is valid\n";
        } else {
          print "✗ Current time is invalid\n";
        }
        // Test formatting
        print "  ISO format: ", LDT.ToString(dt), "\n";
      }
      case Failure(error) => {
        print "✗ Error getting current time: ", error, "\n";
      }
    }
  }
}

method Main()
{
  TestLocalDateTime.TestOfFunction();
  TestLocalDateTime.TestParseFunction();
  TestLocalDateTime.TestCompareFunction();
  TestLocalDateTime.TestArithmeticFunctions();
  TestLocalDateTime.TestFormatFunction();
  TestLocalDateTime.TestHelperFunctions();
  TestLocalDateTime.TestEdgeCases();
  TestLocalDateTime.TestOptimizations();
  TestLocalDateTime.TestNowFunction();
}