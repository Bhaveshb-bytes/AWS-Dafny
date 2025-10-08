include "LocalDateTime.dfy"
include "Duration.dfy"
include "DateTimeUtils.dfy"

module TestLocalDateTimePrint {
  import LDT = LocalDateTime
  import Duration = Duration
  import DTUtils = DateTimeUtils

  method TestNowFunctionPrint()
  {
    print "=== Testing Now Function ===\n";
    var nowResult := LDT.Now();
    if nowResult.Success? {
      var currentTime := nowResult.value;
      print "Current DateTime: ", LDT.ToString(currentTime), "\n";
    } else {
      print "Failed to get current time: ", nowResult.error, "\n\n";
    }
  }

  method TestArithmeticFunctionsPrint()
  {
    print "=== Testing Arithmetic Functions ===\n";
    var dt := LDT.LocalDateTime(2023, 6, 15, 14, 30, 45, 123);
    var duration := Duration.Duration(3661, 500); // 1 hour, 1 minute, 1 second, 500ms
    
    print "Original DateTime: ", LDT.ToString(dt), "\n";
    print "Duration: ", duration.seconds, " seconds + ", duration.millis, " millis\n";

    var plusResult := LDT.PlusDuration(dt, duration);
    print "Plus Result: ", LDT.ToString(plusResult), "\n";
    print "Expected:    2023-06-15T15:31:46.623\n";
    print "Hour: ", LDT.GetHour(plusResult), " (expected: 15)\n";
    print "Minute: ", LDT.GetMinute(plusResult), " (expected: 31)\n";
    print "Second: ", LDT.GetSecond(plusResult), " (expected: 46)\n";
    print "Millisecond: ", LDT.GetMillisecond(plusResult), " (expected: 623)\n\n";

    var minusResult := LDT.MinusDuration(dt, duration);
    print "Minus Result: ", LDT.ToString(minusResult), "\n";
    print "Expected:     2023-06-15T13:29:43.623\n";
    print "Hour: ", LDT.GetHour(minusResult), " (expected: 13)\n";
    print "Minute: ", LDT.GetMinute(minusResult), " (expected: 29)\n";
    print "Second: ", LDT.GetSecond(minusResult), " (expected: 43)\n";
    print "Millisecond: ", LDT.GetMillisecond(minusResult), " (expected: 623)\n\n";

    // Test cross-day boundary
    var lateNight := LDT.LocalDateTime(2023, 6, 15, 23, 30, 45, 123);
    var longDuration := Duration.Duration(7200, 0); // 2 hours
    var nextDay := LDT.PlusDuration(lateNight, longDuration);
    print "Late night: ", LDT.ToString(lateNight), "\n";
    print "Plus 2 hours: ", LDT.ToString(nextDay), "\n";
    print "Expected: 2023-06-16T01:30:45.123\n";
    print "Day: ", LDT.GetDay(nextDay), " (expected: 16)\n";
    print "Hour: ", LDT.GetHour(nextDay), " (expected: 1)\n";
    print "Minute: ", LDT.GetMinute(nextDay), " (expected: 30)\n\n";
  }

  method TestPlusYearsPrint() {
    print "=== Testing PlusYears ===\n";
    // Test leap year to non-leap year (Feb 29 -> Feb 28)
    var leapDay := LDT.LocalDateTime(2020, 2, 29, 10, 0, 0, 0);
    print "Original (leap day): ", LDT.ToString(leapDay), "\n";
    var nextYear := LDT.PlusYears(leapDay, 1);
    print "Plus 1 year: ", LDT.ToString(nextYear), "\n";
    print "Expected: 2021-02-28T10:00:00.000\n";
    print "Year: ", nextYear.year, " (expected: 2021)\n";
    print "Month: ", nextYear.month, " (expected: 2)\n";
    print "Day: ", nextYear.day, " (expected: 28 - clamped from 29)\n\n";
  }

  method TestPlusMonthsPrint() {
    print "=== Testing PlusMonths ===\n";
    // Test month overflow across year boundary
    var novemberDt := LDT.LocalDateTime(2023, 11, 15, 10, 0, 0, 0);
    print "Original (November): ", LDT.ToString(novemberDt), "\n";
    var plusTwoMonths := LDT.PlusMonths(novemberDt, 2);
    print "Plus 2 months: ", LDT.ToString(plusTwoMonths), "\n";
    print "Expected: 2024-01-15T10:00:00.000\n";
    print "Year: ", plusTwoMonths.year, " (expected: 2024)\n";
    print "Month: ", plusTwoMonths.month, " (expected: 1)\n";
    print "Day: ", plusTwoMonths.day, " (expected: 15)\n\n";

    // Test day clamping when moving from 31-day month to 30-day month
    var jan31 := LDT.LocalDateTime(2023, 1, 31, 10, 0, 0, 0);
    print "Original (Jan 31): ", LDT.ToString(jan31), "\n";
    var plusOneMonth := LDT.PlusMonths(jan31, 1);
    print "Plus 1 month: ", LDT.ToString(plusOneMonth), "\n";
    print "Expected: 2023-02-28T10:00:00.000\n";
    print "Year: ", plusOneMonth.year, " (expected: 2023)\n";
    print "Month: ", plusOneMonth.month, " (expected: 2)\n";
    print "Day: ", plusOneMonth.day, " (expected: 28 - clamped from 31)\n\n";

    // Test leap year Feb 29 plus one month
    var feb29 := LDT.LocalDateTime(2020, 2, 29, 10, 0, 0, 0);
    print "Original (Feb 29 leap year): ", LDT.ToString(feb29), "\n";
    var feb29PlusOne := LDT.PlusMonths(feb29, 1);
    print "Plus 1 month: ", LDT.ToString(feb29PlusOne), "\n";
    print "Expected: 2020-03-29T10:00:00.000\n";
    print "Year: ", feb29PlusOne.year, " (expected: 2020)\n";
    print "Month: ", feb29PlusOne.month, " (expected: 3)\n";
    print "Day: ", feb29PlusOne.day, " (expected: 29)\n\n";

    // Test Jan 31 plus one month in non-leap year
    var jan31NonLeap := LDT.LocalDateTime(2023, 1, 31, 10, 0, 0, 0);
    print "Original (Jan 31 non-leap year): ", LDT.ToString(jan31NonLeap), "\n";
    var jan31PlusOne := LDT.PlusMonths(jan31NonLeap, 1);
    print "Plus 1 month: ", LDT.ToString(jan31PlusOne), "\n";
    print "Expected: 2023-02-28T10:00:00.000\n";
    print "Year: ", jan31PlusOne.year, " (expected: 2023)\n";
    print "Month: ", jan31PlusOne.month, " (expected: 2)\n";
    print "Day: ", jan31PlusOne.day, " (expected: 28 - clamped from 31)\n\n";
  }

  method TestPlusDaysPrint() {
    print "=== Testing PlusDays ===\n";
    // Test day overflow across month boundary
    var june29 := LDT.LocalDateTime(2023, 6, 29, 10, 0, 0, 0);
    print "Original (June 29): ", LDT.ToString(june29), "\n";
    var plusThreeDays := LDT.PlusDays(june29, 3);
    print "Plus 3 days: ", LDT.ToString(plusThreeDays), "\n";
    print "Expected: 2023-07-02T10:00:00.000\n";
    print "Year: ", plusThreeDays.year, " (expected: 2023)\n";
    print "Month: ", plusThreeDays.month, " (expected: 7)\n";
    print "Day: ", plusThreeDays.day, " (expected: 2)\n\n";

    // Test day overflow across year boundary
    var dec30 := LDT.LocalDateTime(2023, 12, 30, 10, 0, 0, 0);
    print "Original (Dec 30): ", LDT.ToString(dec30), "\n";
    var plusFiveDays := LDT.PlusDays(dec30, 5);
    print "Plus 5 days: ", LDT.ToString(plusFiveDays), "\n";
    print "Expected: 2024-01-04T10:00:00.000\n";
    print "Year: ", plusFiveDays.year, " (expected: 2024)\n";
    print "Month: ", plusFiveDays.month, " (expected: 1)\n";
    print "Day: ", plusFiveDays.day, " (expected: 4)\n\n";
  }

  method TestPlusHoursPrint() {
    print "=== Testing PlusHours ===\n";
    // Test hour overflow across day boundary
    var lateNight := LDT.LocalDateTime(2023, 6, 15, 22, 30, 45, 123);
    print "Original (late night): ", LDT.ToString(lateNight), "\n";
    var plusFiveHours := LDT.PlusHours(lateNight, 5);
    print "Plus 5 hours: ", LDT.ToString(plusFiveHours), "\n";
    print "Expected: 2023-06-16T03:30:45.123\n";
    print "Year: ", plusFiveHours.year, " (expected: 2023)\n";
    print "Month: ", plusFiveHours.month, " (expected: 6)\n";
    print "Day: ", plusFiveHours.day, " (expected: 16)\n";
    print "Hour: ", plusFiveHours.hour, " (expected: 3)\n";
    print "Minute: ", plusFiveHours.minute, " (expected: 30)\n\n";
  }

  method TestPlusMinutesPrint() {
    print "=== Testing PlusMinutes ===\n";
    // Test minute overflow across hour boundary
    var dt := LDT.LocalDateTime(2023, 6, 15, 14, 55, 45, 123);
    print "Original: ", LDT.ToString(dt), "\n";
    var plusTenMinutes := LDT.PlusMinutes(dt, 10);
    print "Plus 10 minutes: ", LDT.ToString(plusTenMinutes), "\n";
    print "Expected: 2023-06-15T15:05:45.123\n";
    print "Hour: ", plusTenMinutes.hour, " (expected: 15)\n";
    print "Minute: ", plusTenMinutes.minute, " (expected: 5)\n";
    print "Second: ", plusTenMinutes.second, " (expected: 45)\n\n";
  }

  method TestPlusSecondsPrint() {
    print "=== Testing PlusSeconds ===\n";
    // Test second overflow across minute boundary
    var dt := LDT.LocalDateTime(2023, 6, 15, 14, 30, 55, 123);
    print "Original: ", LDT.ToString(dt), "\n";
    var plusTenSeconds := LDT.PlusSeconds(dt, 10);
    print "Plus 10 seconds: ", LDT.ToString(plusTenSeconds), "\n";
    print "Expected: 2023-06-15T14:31:05.123\n";
    print "Minute: ", plusTenSeconds.minute, " (expected: 31)\n";
    print "Second: ", plusTenSeconds.second, " (expected: 5)\n";
    print "Millisecond: ", plusTenSeconds.millisecond, " (expected: 123)\n\n";
  }

  method TestPlusMillisecondsPrint() {
    print "=== Testing PlusMilliseconds ===\n";
    // Test millisecond overflow across second boundary
    var dt := LDT.LocalDateTime(2023, 6, 15, 14, 30, 45, 950);
    print "Original: ", LDT.ToString(dt), "\n";
    var plus100Millis := LDT.PlusMilliseconds(dt, 100);
    print "Plus 100 millis: ", LDT.ToString(plus100Millis), "\n";
    print "Expected: 2023-06-15T14:30:46.050\n";
    print "Second: ", plus100Millis.second, " (expected: 46)\n";
    print "Millisecond: ", plus100Millis.millisecond, " (expected: 50)\n\n";
  }

  method TestMinusYearsPrint() {
    print "=== Testing MinusYears ===\n";
    // Test leap year to non-leap year (Feb 29 -> Feb 28)
    var leapDay := LDT.LocalDateTime(2020, 2, 29, 10, 0, 0, 0);
    print "Original (leap day): ", LDT.ToString(leapDay), "\n";
    var prevYear := LDT.MinusYears(leapDay, 4);
    print "Minus 4 years: ", LDT.ToString(prevYear), "\n";
    print "Expected: 2016-02-29T10:00:00.000 (2016 is also leap)\n";
    print "Year: ", prevYear.year, " (expected: 2016)\n";
    print "Month: ", prevYear.month, " (expected: 2)\n";
    print "Day: ", prevYear.day, " (expected: 29)\n\n";

    var anoPrevYear := LDT.MinusYears(leapDay, 1);
    print "Minus 1 year: ", LDT.ToString(anoPrevYear), "\n";
    print "Expected: 2019-02-28T10:00:00.000 (2019 is not leap)\n";
    print "Year: ", anoPrevYear.year, " (expected: 2019)\n";
    print "Month: ", anoPrevYear.month, " (expected: 2)\n";
    print "Day: ", anoPrevYear.day, " (expected: 28 - clamped from 29)\n\n";
  }

  method TestMinusMonthsPrint() {
    print "=== Testing MinusMonths ===\n";
    // Test month underflow across year boundary
    var januaryDt := LDT.LocalDateTime(2024, 1, 15, 10, 0, 0, 0);
    print "Original (January): ", LDT.ToString(januaryDt), "\n";
    var minusTwoMonths := LDT.MinusMonths(januaryDt, 2);
    print "Minus 2 months: ", LDT.ToString(minusTwoMonths), "\n";
    print "Expected: 2023-11-15T10:00:00.000\n";
    print "Year: ", minusTwoMonths.year, " (expected: 2023)\n";
    print "Month: ", minusTwoMonths.month, " (expected: 11)\n";
    print "Day: ", minusTwoMonths.day, " (expected: 15)\n\n";

    // Test day clamping when moving from 31-day month to 30-day month
    var mar31 := LDT.LocalDateTime(2023, 3, 31, 10, 0, 0, 0);
    print "Original (Mar 31): ", LDT.ToString(mar31), "\n";
    var minusOneMonth := LDT.MinusMonths(mar31, 1);
    print "Minus 1 month: ", LDT.ToString(minusOneMonth), "\n";
    print "Expected: 2023-02-28T10:00:00.000\n";
    print "Year: ", minusOneMonth.year, " (expected: 2023)\n";
    print "Month: ", minusOneMonth.month, " (expected: 2)\n";
    print "Day: ", minusOneMonth.day, " (expected: 28 - clamped from 31)\n\n";
  }

  method TestMinusDaysPrint() {
    print "=== Testing MinusDays ===\n";
    // Test day underflow across month boundary
    var july2 := LDT.LocalDateTime(2023, 7, 2, 10, 0, 0, 0);
    print "Original (July 2): ", LDT.ToString(july2), "\n";
    var minusThreeDays := LDT.MinusDays(july2, 3);
    print "Minus 3 days: ", LDT.ToString(minusThreeDays), "\n";
    print "Expected: 2023-06-29T10:00:00.000\n";
    print "Year: ", minusThreeDays.year, " (expected: 2023)\n";
    print "Month: ", minusThreeDays.month, " (expected: 6)\n";
    print "Day: ", minusThreeDays.day, " (expected: 29)\n\n";

    // Test day underflow across year boundary
    var jan4 := LDT.LocalDateTime(2024, 1, 4, 10, 0, 0, 0);
    print "Original (Jan 4): ", LDT.ToString(jan4), "\n";
    var minusFiveDays := LDT.MinusDays(jan4, 5);
    print "Minus 5 days: ", LDT.ToString(minusFiveDays), "\n";
    print "Expected: 2023-12-30T10:00:00.000\n";
    print "Year: ", minusFiveDays.year, " (expected: 2023)\n";
    print "Month: ", minusFiveDays.month, " (expected: 12)\n";
    print "Day: ", minusFiveDays.day, " (expected: 30)\n\n";
  }

  method TestMinusHoursPrint() {
    print "=== Testing MinusHours ===\n";
    // Test hour underflow across day boundary
    var earlyMorning := LDT.LocalDateTime(2023, 6, 16, 3, 30, 45, 123);
    print "Original (early morning): ", LDT.ToString(earlyMorning), "\n";
    var minusFiveHours := LDT.MinusHours(earlyMorning, 5);
    print "Minus 5 hours: ", LDT.ToString(minusFiveHours), "\n";
    print "Expected: 2023-06-15T22:30:45.123\n";
    print "Year: ", minusFiveHours.year, " (expected: 2023)\n";
    print "Month: ", minusFiveHours.month, " (expected: 6)\n";
    print "Day: ", minusFiveHours.day, " (expected: 15)\n";
    print "Hour: ", minusFiveHours.hour, " (expected: 22)\n";
    print "Minute: ", minusFiveHours.minute, " (expected: 30)\n\n";
  }

  method TestMinusMinutesPrint() {
    print "=== Testing MinusMinutes ===\n";
    // Test minute underflow across hour boundary
    var dt := LDT.LocalDateTime(2023, 6, 15, 15, 5, 45, 123);
    print "Original: ", LDT.ToString(dt), "\n";
    var minusTenMinutes := LDT.MinusMinutes(dt, 10);
    print "Minus 10 minutes: ", LDT.ToString(minusTenMinutes), "\n";
    print "Expected: 2023-06-15T14:55:45.123\n";
    print "Hour: ", minusTenMinutes.hour, " (expected: 14)\n";
    print "Minute: ", minusTenMinutes.minute, " (expected: 55)\n";
    print "Second: ", minusTenMinutes.second, " (expected: 45)\n\n";
  }

  method TestMinusSecondsPrint() {
    print "=== Testing MinusSeconds ===\n";
    // Test second underflow across minute boundary
    var dt := LDT.LocalDateTime(2023, 6, 15, 14, 31, 5, 123);
    print "Original: ", LDT.ToString(dt), "\n";
    var minusTenSeconds := LDT.MinusSeconds(dt, 10);
    print "Minus 10 seconds: ", LDT.ToString(minusTenSeconds), "\n";
    print "Expected: 2023-06-15T14:30:55.123\n";
    print "Minute: ", minusTenSeconds.minute, " (expected: 30)\n";
    print "Second: ", minusTenSeconds.second, " (expected: 55)\n";
    print "Millisecond: ", minusTenSeconds.millisecond, " (expected: 123)\n\n";
  }

  method TestMinusMillisecondsPrint() {
    print "=== Testing MinusMilliseconds ===\n";
    // Test millisecond underflow across second boundary
    var dt := LDT.LocalDateTime(2023, 6, 15, 14, 30, 46, 50);
    print "Original: ", LDT.ToString(dt), "\n";
    var minus100Millis := LDT.MinusMilliseconds(dt, 100);
    print "Minus 100 millis: ", LDT.ToString(minus100Millis), "\n";
    print "Expected: 2023-06-15T14:30:45.950\n";
    print "Second: ", minus100Millis.second, " (expected: 45)\n";
    print "Millisecond: ", minus100Millis.millisecond, " (expected: 950)\n\n";
  }

  method Main() {
    TestNowFunctionPrint();
    TestArithmeticFunctionsPrint();
    TestPlusYearsPrint();
    TestPlusMonthsPrint();
    TestPlusDaysPrint();
    TestPlusHoursPrint();
    TestPlusMinutesPrint();
    TestPlusSecondsPrint();
    TestPlusMillisecondsPrint();
    TestMinusYearsPrint();
    TestMinusMonthsPrint();
    TestMinusDaysPrint();
    TestMinusHoursPrint();
    TestMinusMinutesPrint();
    TestMinusSecondsPrint();
    TestMinusMillisecondsPrint();
    print "All date calculation tests completed!\n";
  }
}