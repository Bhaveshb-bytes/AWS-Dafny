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

    var plusResult := LDT.PlusDuration(dt, duration);
    if LDT.GetHour(plusResult) != 15 {
      print "FAIL: Plus hour mismatch. Got: ", LDT.GetHour(plusResult), " Expected: 15\n";
    }
    if LDT.GetMinute(plusResult) != 31 {
      print "FAIL: Plus minute mismatch. Got: ", LDT.GetMinute(plusResult), " Expected: 31\n";
    }
    if LDT.GetSecond(plusResult) != 46 {
      print "FAIL: Plus second mismatch. Got: ", LDT.GetSecond(plusResult), " Expected: 46\n";
    }
    if LDT.GetMillisecond(plusResult) != 623 {
      print "FAIL: Plus millisecond mismatch. Got: ", LDT.GetMillisecond(plusResult), " Expected: 623\n";
    }

    var minusResult := LDT.MinusDuration(dt, duration);
    if LDT.GetHour(minusResult) != 13 {
      print "FAIL: Minus hour mismatch. Got: ", LDT.GetHour(minusResult), " Expected: 13\n";
    }
    if LDT.GetMinute(minusResult) != 29 {
      print "FAIL: Minus minute mismatch. Got: ", LDT.GetMinute(minusResult), " Expected: 29\n";
    }
    if LDT.GetSecond(minusResult) != 43 {
      print "FAIL: Minus second mismatch. Got: ", LDT.GetSecond(minusResult), " Expected: 43\n";
    }
    if LDT.GetMillisecond(minusResult) != 623 {
      print "FAIL: Minus millisecond mismatch. Got: ", LDT.GetMillisecond(minusResult), " Expected: 623\n";
    }

    // Test cross-day boundary
    var lateNight := LDT.LocalDateTime(2023, 6, 15, 23, 30, 45, 123);
    var longDuration := Duration.Duration(7200, 0); // 2 hours
    var nextDay := LDT.PlusDuration(lateNight, longDuration);
    if LDT.GetDay(nextDay) != 16 {
      print "FAIL: Cross-day boundary day mismatch. Got: ", LDT.GetDay(nextDay), " Expected: 16\n";
    }
    if LDT.GetHour(nextDay) != 1 {
      print "FAIL: Cross-day boundary hour mismatch. Got: ", LDT.GetHour(nextDay), " Expected: 1\n";
    }
    if LDT.GetMinute(nextDay) != 30 {
      print "FAIL: Cross-day boundary minute mismatch. Got: ", LDT.GetMinute(nextDay), " Expected: 30\n";
    }
  }

  method TestPlusYearsPrint() {
    print "=== Testing PlusYears ===\n";
    // Test leap year to non-leap year (Feb 29 -> Feb 28)
    var leapDay := LDT.LocalDateTime(2020, 2, 29, 10, 0, 0, 0);
    var nextYear := LDT.PlusYears(leapDay, 1);
    if nextYear.year != 2021 {
      print "FAIL: PlusYears year mismatch. Got: ", nextYear.year, " Expected: 2021\n";
    }
    if nextYear.month != 2 {
      print "FAIL: PlusYears month mismatch. Got: ", nextYear.month, " Expected: 2\n";
    }
    if nextYear.day != 28 {
      print "FAIL: PlusYears day mismatch. Got: ", nextYear.day, " Expected: 28 (clamped from 29)\n";
    }
  }

  method TestPlusMonthsPrint() {
    print "=== Testing PlusMonths ===\n";
    // Test month overflow across year boundary
    var novemberDt := LDT.LocalDateTime(2023, 11, 15, 10, 0, 0, 0);
    var plusTwoMonths := LDT.PlusMonths(novemberDt, 2);
    if plusTwoMonths.year != 2024 {
      print "FAIL: PlusMonths year overflow mismatch. Got: ", plusTwoMonths.year, " Expected: 2024\n";
    }
    if plusTwoMonths.month != 1 {
      print "FAIL: PlusMonths month overflow mismatch. Got: ", plusTwoMonths.month, " Expected: 1\n";
    }
    if plusTwoMonths.day != 15 {
      print "FAIL: PlusMonths day overflow mismatch. Got: ", plusTwoMonths.day, " Expected: 15\n";
    }

    // Test day clamping when moving from 31-day month to 30-day month
    var jan31 := LDT.LocalDateTime(2023, 1, 31, 10, 0, 0, 0);
    var plusOneMonth := LDT.PlusMonths(jan31, 1);
    if plusOneMonth.year != 2023 {
      print "FAIL: PlusMonths day clamp year mismatch. Got: ", plusOneMonth.year, " Expected: 2023\n";
    }
    if plusOneMonth.month != 2 {
      print "FAIL: PlusMonths day clamp month mismatch. Got: ", plusOneMonth.month, " Expected: 2\n";
    }
    if plusOneMonth.day != 28 {
      print "FAIL: PlusMonths day clamp day mismatch. Got: ", plusOneMonth.day, " Expected: 28 (clamped from 31)\n";
    }

    // Test leap year Feb 29 plus one month
    var feb29 := LDT.LocalDateTime(2020, 2, 29, 10, 0, 0, 0);
    var feb29PlusOne := LDT.PlusMonths(feb29, 1);
    if feb29PlusOne.year != 2020 {
      print "FAIL: PlusMonths Feb29 year mismatch. Got: ", feb29PlusOne.year, " Expected: 2020\n";
    }
    if feb29PlusOne.month != 3 {
      print "FAIL: PlusMonths Feb29 month mismatch. Got: ", feb29PlusOne.month, " Expected: 3\n";
    }
    if feb29PlusOne.day != 29 {
      print "FAIL: PlusMonths Feb29 day mismatch. Got: ", feb29PlusOne.day, " Expected: 29\n";
    }

    // Test Jan 31 plus one month in non-leap year
    var jan31NonLeap := LDT.LocalDateTime(2023, 1, 31, 10, 0, 0, 0);
    var jan31PlusOne := LDT.PlusMonths(jan31NonLeap, 1);
    if jan31PlusOne.year != 2023 {
      print "FAIL: PlusMonths Jan31 year mismatch. Got: ", jan31PlusOne.year, " Expected: 2023\n";
    }
    if jan31PlusOne.month != 2 {
      print "FAIL: PlusMonths Jan31 month mismatch. Got: ", jan31PlusOne.month, " Expected: 2\n";
    }
    if jan31PlusOne.day != 28 {
      print "FAIL: PlusMonths Jan31 day mismatch. Got: ", jan31PlusOne.day, " Expected: 28 (clamped from 31)\n";
    }
  }

  method TestPlusDaysPrint() {
    print "=== Testing PlusDays ===\n";
    // Test day overflow across month boundary
    var june29 := LDT.LocalDateTime(2023, 6, 29, 10, 0, 0, 0);
    var plusThreeDays := LDT.PlusDays(june29, 3);
    if plusThreeDays.year != 2023 {
      print "FAIL: PlusDays month boundary year mismatch. Got: ", plusThreeDays.year, " Expected: 2023\n";
    }
    if plusThreeDays.month != 7 {
      print "FAIL: PlusDays month boundary month mismatch. Got: ", plusThreeDays.month, " Expected: 7\n";
    }
    if plusThreeDays.day != 2 {
      print "FAIL: PlusDays month boundary day mismatch. Got: ", plusThreeDays.day, " Expected: 2\n";
    }

    // Test day overflow across year boundary
    var dec30 := LDT.LocalDateTime(2023, 12, 30, 10, 0, 0, 0);
    var plusFiveDays := LDT.PlusDays(dec30, 5);
    if plusFiveDays.year != 2024 {
      print "FAIL: PlusDays year boundary year mismatch. Got: ", plusFiveDays.year, " Expected: 2024\n";
    }
    if plusFiveDays.month != 1 {
      print "FAIL: PlusDays year boundary month mismatch. Got: ", plusFiveDays.month, " Expected: 1\n";
    }
    if plusFiveDays.day != 4 {
      print "FAIL: PlusDays year boundary day mismatch. Got: ", plusFiveDays.day, " Expected: 4\n";
    }
  }

  method TestPlusHoursPrint() {
    print "=== Testing PlusHours ===\n";
    // Test hour overflow across day boundary
    var lateNight := LDT.LocalDateTime(2023, 6, 15, 22, 30, 45, 123);
    var plusFiveHours := LDT.PlusHours(lateNight, 5);
    if plusFiveHours.year != 2023 {
      print "FAIL: PlusHours year mismatch. Got: ", plusFiveHours.year, " Expected: 2023\n";
    }
    if plusFiveHours.month != 6 {
      print "FAIL: PlusHours month mismatch. Got: ", plusFiveHours.month, " Expected: 6\n";
    }
    if plusFiveHours.day != 16 {
      print "FAIL: PlusHours day mismatch. Got: ", plusFiveHours.day, " Expected: 16\n";
    }
    if plusFiveHours.hour != 3 {
      print "FAIL: PlusHours hour mismatch. Got: ", plusFiveHours.hour, " Expected: 3\n";
    }
    if plusFiveHours.minute != 30 {
      print "FAIL: PlusHours minute mismatch. Got: ", plusFiveHours.minute, " Expected: 30\n";
    }
  }

  method TestPlusMinutesPrint() {
    print "=== Testing PlusMinutes ===\n";
    // Test minute overflow across hour boundary
    var dt := LDT.LocalDateTime(2023, 6, 15, 14, 55, 45, 123);
    var plusTenMinutes := LDT.PlusMinutes(dt, 10);
    if plusTenMinutes.hour != 15 {
      print "FAIL: PlusMinutes hour mismatch. Got: ", plusTenMinutes.hour, " Expected: 15\n";
    }
    if plusTenMinutes.minute != 5 {
      print "FAIL: PlusMinutes minute mismatch. Got: ", plusTenMinutes.minute, " Expected: 5\n";
    }
    if plusTenMinutes.second != 45 {
      print "FAIL: PlusMinutes second mismatch. Got: ", plusTenMinutes.second, " Expected: 45\n";
    }
  }

  method TestPlusSecondsPrint() {
    print "=== Testing PlusSeconds ===\n";
    // Test second overflow across minute boundary
    var dt := LDT.LocalDateTime(2023, 6, 15, 14, 30, 55, 123);
    var plusTenSeconds := LDT.PlusSeconds(dt, 10);
    if plusTenSeconds.minute != 31 {
      print "FAIL: PlusSeconds minute mismatch. Got: ", plusTenSeconds.minute, " Expected: 31\n";
    }
    if plusTenSeconds.second != 5 {
      print "FAIL: PlusSeconds second mismatch. Got: ", plusTenSeconds.second, " Expected: 5\n";
    }
    if plusTenSeconds.millisecond != 123 {
      print "FAIL: PlusSeconds millisecond mismatch. Got: ", plusTenSeconds.millisecond, " Expected: 123\n";
    }
  }

  method TestPlusMillisecondsPrint() {
    print "=== Testing PlusMilliseconds ===\n";
    // Test millisecond overflow across second boundary
    var dt := LDT.LocalDateTime(2023, 6, 15, 14, 30, 45, 950);
    var plus100Millis := LDT.PlusMilliseconds(dt, 100);
    if plus100Millis.second != 46 {
      print "FAIL: PlusMilliseconds second mismatch. Got: ", plus100Millis.second, " Expected: 46\n";
    }
    if plus100Millis.millisecond != 50 {
      print "FAIL: PlusMilliseconds millisecond mismatch. Got: ", plus100Millis.millisecond, " Expected: 50\n";
    }
  }

  method TestMinusYearsPrint() {
    print "=== Testing MinusYears ===\n";
    // Test leap year to non-leap year (Feb 29 -> Feb 28)
    var leapDay := LDT.LocalDateTime(2020, 2, 29, 10, 0, 0, 0);
    var prevYear := LDT.MinusYears(leapDay, 4);
    if prevYear.year != 2016 {
      print "FAIL: MinusYears 4 year mismatch. Got: ", prevYear.year, " Expected: 2016\n";
    }
    if prevYear.month != 2 {
      print "FAIL: MinusYears 4 month mismatch. Got: ", prevYear.month, " Expected: 2\n";
    }
    if prevYear.day != 29 {
      print "FAIL: MinusYears 4 day mismatch. Got: ", prevYear.day, " Expected: 29\n";
    }

    var anoPrevYear := LDT.MinusYears(leapDay, 1);
    if anoPrevYear.year != 2019 {
      print "FAIL: MinusYears 1 year mismatch. Got: ", anoPrevYear.year, " Expected: 2019\n";
    }
    if anoPrevYear.month != 2 {
      print "FAIL: MinusYears 1 month mismatch. Got: ", anoPrevYear.month, " Expected: 2\n";
    }
    if anoPrevYear.day != 28 {
      print "FAIL: MinusYears 1 day mismatch. Got: ", anoPrevYear.day, " Expected: 28 (clamped from 29)\n";
    }
  }

  method TestMinusMonthsPrint() {
    print "=== Testing MinusMonths ===\n";
    // Test month underflow across year boundary
    var januaryDt := LDT.LocalDateTime(2024, 1, 15, 10, 0, 0, 0);
    var minusTwoMonths := LDT.MinusMonths(januaryDt, 2);
    if minusTwoMonths.year != 2023 {
      print "FAIL: MinusMonths year underflow mismatch. Got: ", minusTwoMonths.year, " Expected: 2023\n";
    }
    if minusTwoMonths.month != 11 {
      print "FAIL: MinusMonths month underflow mismatch. Got: ", minusTwoMonths.month, " Expected: 11\n";
    }
    if minusTwoMonths.day != 15 {
      print "FAIL: MinusMonths day underflow mismatch. Got: ", minusTwoMonths.day, " Expected: 15\n";
    }

    // Test day clamping when moving from 31-day month to 30-day month
    var mar31 := LDT.LocalDateTime(2023, 3, 31, 10, 0, 0, 0);
    var minusOneMonth := LDT.MinusMonths(mar31, 1);
    if minusOneMonth.year != 2023 {
      print "FAIL: MinusMonths day clamp year mismatch. Got: ", minusOneMonth.year, " Expected: 2023\n";
    }
    if minusOneMonth.month != 2 {
      print "FAIL: MinusMonths day clamp month mismatch. Got: ", minusOneMonth.month, " Expected: 2\n";
    }
    if minusOneMonth.day != 28 {
      print "FAIL: MinusMonths day clamp day mismatch. Got: ", minusOneMonth.day, " Expected: 28 (clamped from 31)\n";
    }
  }

  method TestMinusDaysPrint() {
    print "=== Testing MinusDays ===\n";
    // Test day underflow across month boundary
    var july2 := LDT.LocalDateTime(2023, 7, 2, 10, 0, 0, 0);
    var minusThreeDays := LDT.MinusDays(july2, 3);
    if minusThreeDays.year != 2023 {
      print "FAIL: MinusDays month boundary year mismatch. Got: ", minusThreeDays.year, " Expected: 2023\n";
    }
    if minusThreeDays.month != 6 {
      print "FAIL: MinusDays month boundary month mismatch. Got: ", minusThreeDays.month, " Expected: 6\n";
    }
    if minusThreeDays.day != 29 {
      print "FAIL: MinusDays month boundary day mismatch. Got: ", minusThreeDays.day, " Expected: 29\n";
    }

    // Test day underflow across year boundary
    var jan4 := LDT.LocalDateTime(2024, 1, 4, 10, 0, 0, 0);
    var minusFiveDays := LDT.MinusDays(jan4, 5);
    if minusFiveDays.year != 2023 {
      print "FAIL: MinusDays year boundary year mismatch. Got: ", minusFiveDays.year, " Expected: 2023\n";
    }
    if minusFiveDays.month != 12 {
      print "FAIL: MinusDays year boundary month mismatch. Got: ", minusFiveDays.month, " Expected: 12\n";
    }
    if minusFiveDays.day != 30 {
      print "FAIL: MinusDays year boundary day mismatch. Got: ", minusFiveDays.day, " Expected: 30\n";
    }
  }

  method TestMinusHoursPrint() {
    print "=== Testing MinusHours ===\n";
    // Test hour underflow across day boundary
    var earlyMorning := LDT.LocalDateTime(2023, 6, 16, 3, 30, 45, 123);
    var minusFiveHours := LDT.MinusHours(earlyMorning, 5);
    if minusFiveHours.year != 2023 {
      print "FAIL: MinusHours year mismatch. Got: ", minusFiveHours.year, " Expected: 2023\n";
    }
    if minusFiveHours.month != 6 {
      print "FAIL: MinusHours month mismatch. Got: ", minusFiveHours.month, " Expected: 6\n";
    }
    if minusFiveHours.day != 15 {
      print "FAIL: MinusHours day mismatch. Got: ", minusFiveHours.day, " Expected: 15\n";
    }
    if minusFiveHours.hour != 22 {
      print "FAIL: MinusHours hour mismatch. Got: ", minusFiveHours.hour, " Expected: 22\n";
    }
    if minusFiveHours.minute != 30 {
      print "FAIL: MinusHours minute mismatch. Got: ", minusFiveHours.minute, " Expected: 30\n";
    }
  }

  method TestMinusMinutesPrint() {
    print "=== Testing MinusMinutes ===\n";
    // Test minute underflow across hour boundary
    var dt := LDT.LocalDateTime(2023, 6, 15, 15, 5, 45, 123);
    var minusTenMinutes := LDT.MinusMinutes(dt, 10);
    if minusTenMinutes.hour != 14 {
      print "FAIL: MinusMinutes hour mismatch. Got: ", minusTenMinutes.hour, " Expected: 14\n";
    }
    if minusTenMinutes.minute != 55 {
      print "FAIL: MinusMinutes minute mismatch. Got: ", minusTenMinutes.minute, " Expected: 55\n";
    }
    if minusTenMinutes.second != 45 {
      print "FAIL: MinusMinutes second mismatch. Got: ", minusTenMinutes.second, " Expected: 45\n";
    }
  }

  method TestMinusSecondsPrint() {
    print "=== Testing MinusSeconds ===\n";
    // Test second underflow across minute boundary
    var dt := LDT.LocalDateTime(2023, 6, 15, 14, 31, 5, 123);
    var minusTenSeconds := LDT.MinusSeconds(dt, 10);
    if minusTenSeconds.minute != 30 {
      print "FAIL: MinusSeconds minute mismatch. Got: ", minusTenSeconds.minute, " Expected: 30\n";
    }
    if minusTenSeconds.second != 55 {
      print "FAIL: MinusSeconds second mismatch. Got: ", minusTenSeconds.second, " Expected: 55\n";
    }
    if minusTenSeconds.millisecond != 123 {
      print "FAIL: MinusSeconds millisecond mismatch. Got: ", minusTenSeconds.millisecond, " Expected: 123\n";
    }
  }

  method TestMinusMillisecondsPrint() {
    print "=== Testing MinusMilliseconds ===\n";
    // Test millisecond underflow across second boundary
    var dt := LDT.LocalDateTime(2023, 6, 15, 14, 30, 46, 50);
    var minus100Millis := LDT.MinusMilliseconds(dt, 100);
    if minus100Millis.second != 45 {
      print "FAIL: MinusMilliseconds second mismatch. Got: ", minus100Millis.second, " Expected: 45\n";
    }
    if minus100Millis.millisecond != 950 {
      print "FAIL: MinusMilliseconds millisecond mismatch. Got: ", minus100Millis.millisecond, " Expected: 950\n";
    }
  }

  method Main() {
    print "Starting LocalDateTime tests.\n";
    print "Only failures will be reported.\n\n";
    
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
    
    print "\nAll date calculation tests completed!\n";
    print "If no FAIL messages appeared above, all tests passed.\n";
  }
}