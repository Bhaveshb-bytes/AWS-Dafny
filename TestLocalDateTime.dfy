include "LocalDateTime.dfy"
include "Duration.dfy"
include "DateTimeUtils.dfy"

module TestLocalDateTime {
  import LDT = LocalDateTime
  import Duration = Duration
  import DTUtils = DateTimeUtils

  method TestOfFunction()
  {
    var result1 := LDT.Of(2023, 6, 15, 14, 30, 45, 123);
    if result1.Success? {
      var dt1 := result1.value;
      assert dt1.year == 2023 && dt1.month == 6 && dt1.day == 15;
      assert dt1.hour == 14 && dt1.minute == 30 && dt1.second == 45 && dt1.millisecond == 123;
      assert LDT.IsValidLocalDateTime(dt1);
    }

    var leapYearResult := LDT.Of(2020, 2, 29, 0, 0, 0, 0);
    if leapYearResult.Success? {
      var leapDt := leapYearResult.value;
      assert leapDt.year == 2020 && leapDt.month == 2 && leapDt.day == 29;
      assert LDT.IsValidLocalDateTime(leapDt);
    }

    // Test invalid cases
    var invalidMonth1 := LDT.Of(2023, 0, 15, 14, 30, 45, 123);   // Month too low
    var invalidMonth2 := LDT.Of(2023, 13, 15, 14, 30, 45, 123);  // Month too high
    var invalidDay1 := LDT.Of(2023, 6, 0, 14, 30, 45, 123);     // Day too low
    var invalidDay2 := LDT.Of(2023, 6, 32, 14, 30, 45, 123);    // Day too high for June
    var invalidDay3 := LDT.Of(2023, 2, 29, 14, 30, 45, 123);    // Feb 29 in non-leap year
    var invalidDay4 := LDT.Of(2023, 4, 31, 14, 30, 45, 123);    // April 31st doesn't exist
    var invalidHour1 := LDT.Of(2023, 6, 15, -1, 30, 45, 123);   // Hour too low
    var invalidHour2 := LDT.Of(2023, 6, 15, 24, 30, 45, 123);   // Hour too high
    var invalidMinute1 := LDT.Of(2023, 6, 15, 14, -1, 45, 123); // Minute too low
    var invalidMinute2 := LDT.Of(2023, 6, 15, 14, 60, 45, 123); // Minute too high
    var invalidSecond1 := LDT.Of(2023, 6, 15, 14, 30, -1, 123); // Second too low
    var invalidSecond2 := LDT.Of(2023, 6, 15, 14, 30, 60, 123); // Second too high
    var invalidMs1 := LDT.Of(2023, 6, 15, 14, 30, 45, -1);      // Millisecond too low
    var invalidMs2 := LDT.Of(2023, 6, 15, 14, 30, 45, 1000);    // Millisecond too high

    assert invalidMonth1.Failure?;
    assert invalidMonth2.Failure?;
    assert invalidDay1.Failure?;
    assert invalidDay2.Failure?;
    assert invalidDay3.Failure?;
    assert invalidDay4.Failure?;
    assert invalidHour1.Failure?;
    assert invalidHour2.Failure?;
    assert invalidMinute1.Failure?;
    assert invalidMinute2.Failure?;
    assert invalidSecond1.Failure?;
    assert invalidSecond2.Failure?;
    assert invalidMs1.Failure?;
    assert invalidMs2.Failure?;
  }

  method TestParseFunction()
  {
    var validResult1 := LDT.Parse("2023-06-15T14:30:45.123");
    if validResult1.Success? {
      var dt1 := validResult1.value;
      assert LDT.IsValidLocalDateTime(dt1);
    }

    // Test invalid format cases - these should return Failure
    var invalidFormat1 := LDT.Parse("2023/06/15 14:30:45");     // Wrong separators
    var invalidFormat2 := LDT.Parse("2023-06-15");              // Too short
    var invalidFormat3 := LDT.Parse("2023-06-15T14:30:45");     // Missing milliseconds
    var invalidFormat4 := LDT.Parse("15-06-2023T14:30:45.123"); // Wrong date order
    var invalidFormat5 := LDT.Parse("2023-6-15T14:30:45.123");  // Single digit month
    var invalidFormat6 := LDT.Parse("2023-06-5T14:30:45.123");  // Single digit day
    var invalidFormat7 := LDT.Parse("2023-06-15T4:30:45.123");  // Single digit hour
    var invalidFormat8 := LDT.Parse("2023-06-15T14:3:45.123");  // Single digit minute
    var invalidFormat9 := LDT.Parse("2023-06-15T14:30:5.123");  // Single digit second
    var invalidFormat10 := LDT.Parse("2023-06-15T14:30:45.12"); // Wrong millisecond length
    var invalidFormat11 := LDT.Parse("");                       // Empty string
    var invalidFormat12 := LDT.Parse("not-a-date");             // Completely invalid

    // Verify format failures
    assert invalidFormat1.Failure?;
    assert invalidFormat2.Failure?;
    assert invalidFormat3.Failure?;
    assert invalidFormat4.Failure?;
    assert invalidFormat5.Failure?;
    assert invalidFormat6.Failure?;
    assert invalidFormat7.Failure?;
    assert invalidFormat8.Failure?;
    assert invalidFormat9.Failure?;
    assert invalidFormat10.Failure?;
    assert invalidFormat11.Failure?;
    assert invalidFormat12.Failure?;
  }

  method TestCompareFunction()
  {
    var dt1 := LDT.LocalDateTime(2023, 6, 15, 14, 30, 45, 123);
    var dt2 := LDT.LocalDateTime(2023, 6, 15, 14, 30, 45, 124);
    var dt3 := LDT.LocalDateTime(2023, 6, 15, 14, 30, 45, 123);

    var cmp1 := LDT.CompareLocal(dt1, dt2);
    var cmp2 := LDT.CompareLocal(dt2, dt1);
    var cmp3 := LDT.CompareLocal(dt1, dt3);

    assert cmp1 == -1;  // dt1 < dt2
    assert cmp2 == 1;   // dt2 > dt1
    assert cmp3 == 0;   // dt1 == dt3
  }

  method TestArithmeticFunctions()
  {
    var dt := LDT.LocalDateTime(2023, 6, 15, 14, 30, 45, 123);
    var duration := Duration.Duration(3661, 500); // 1 hour, 1 minute, 1 second, 500ms

    var plusResult := LDT.PlusDuration(dt, duration);
    print("Plus Result: " + LDT.ToString(plusResult));
    assert LDT.GetHour(plusResult) == 15;  // Should be one hour later
    assert LDT.GetMinute(plusResult) == 31; // Should be one minute later
    assert LDT.GetSecond(plusResult) == 46; // Should be one second later
    assert LDT.GetMillisecond(plusResult) == 623; // Should be 500ms later

    var minusResult := LDT.MinusDuration(dt, duration);
    assert LDT.GetHour(minusResult) == 13;  // Should be one hour earlier
    assert LDT.GetMinute(minusResult) == 29; // Should be one minute earlier
    assert LDT.GetSecond(minusResult) == 43;
    assert LDT.GetMillisecond(minusResult) == 623; // 123 - 500 + 1000 = 623

    // Test cross-day boundary
    var lateNight := LDT.LocalDateTime(2023, 6, 15, 23, 30, 45, 123);
    var longDuration := Duration.Duration(7200, 0); // 2 hours
    var nextDay := LDT.PlusDuration(lateNight, longDuration);
    assert LDT.GetDay(nextDay) == 16;  // Should be next day
    assert LDT.GetHour(nextDay) == 1;  // Should be 1:30 AM
    assert LDT.GetMinute(nextDay) == 30;
  }

  method TestFormatFunction()
  {
    var dt := LDT.LocalDateTime(2023, 6, 15, 14, 30, 45, 123);

    // Test ISO format
    var isoStr := LDT.ToString(dt);
    assert isoStr == "2023-06-15T14:30:45.123";

    // Test different format patterns
    var dateOnly := LDT.Format(dt, "yyyy-MM-dd");
    assert dateOnly == "2023-06-15";

    var timeOnly := LDT.Format(dt, "HH:mm:ss");
    assert timeOnly == "14:30:45";

    // Test that unknown patterns default to ISO format
    var unknownPattern := LDT.Format(dt, "custom");
    assert unknownPattern == isoStr;
  }


  method TestWithNormalCase() {
    var dt1 := LDT.LocalDateTime(2023, 3, 14, 15, 9, 26, 535);
    assert LDT.IsValidLocalDateTime(dt1);

    var dt1_with_new_year := LDT.WithYear(dt1, 2024);
    assert dt1_with_new_year.year == 2024;

    var dt1_with_new_month := LDT.WithMonth(dt1, 2);
    assert dt1_with_new_month.month == 2;

    var dt1_with_new_day := LDT.WithDayOfMonth(dt1, 28);
    assert dt1_with_new_day.day == 28;

    var dt1_with_new_hour := LDT.WithHour(dt1, 10);
    assert dt1_with_new_hour.hour == 10;

    var dt1_with_new_minute := LDT.WithMinute(dt1, 30);
    assert dt1_with_new_minute.minute == 30;

    var dt1_with_new_second := LDT.WithSecond(dt1, 45);
    assert dt1_with_new_second.second == 45;

    var dt1_with_new_millisecond := LDT.WithMillisecond(dt1, 999);
    assert dt1_with_new_millisecond.millisecond == 999;
  }

  method TestWithNotNormalCase() {
    var dt1 := LDT.LocalDateTime(2020, 2, 29, 15, 9, 26, 535);
    assert LDT.IsValidLocalDateTime(dt1);

    var dt1_with_new_year := LDT.WithYear(dt1, 2021);
    assert dt1_with_new_year.year == 2021;
    assert dt1_with_new_year.day == 28; // Clamped to 28 since 2021 is not a leap year

    var dt2 := LDT.LocalDateTime(2020, 3, 31, 15, 9, 26, 535);
    assert LDT.IsValidLocalDateTime(dt2);

    var dt2_with_new_month := LDT.WithMonth(dt2, 4);
    assert dt2_with_new_month.month == 4;
    assert dt2_with_new_month.day == 30; // Clamped to 30 since April has 30 days
  }

  method TestGetters() {
    var dt := LDT.LocalDateTime(2023, 3, 14, 15, 9, 26, 535);
    assert LDT.IsValidLocalDateTime(dt);
    assert LDT.GetYear(dt) == 2023;
    assert LDT.GetMonth(dt) == 3;
    assert LDT.GetDay(dt) == 14;
    assert LDT.GetHour(dt) == 15;
    assert LDT.GetMinute(dt) == 9;
    assert LDT.GetSecond(dt) == 26;
    assert LDT.GetMillisecond(dt) == 535;
  }

  method TestIsLeapYear() {
    assert DTUtils.IsLeapYear(2020); // Divisible by 4 and not by 100
    assert !DTUtils.IsLeapYear(2021); // Not divisible by 4
    assert !DTUtils.IsLeapYear(1900); // Divisible by 100 but not by 400
    assert DTUtils.IsLeapYear(2000); // Divisible by 400
  }

  method TestIsValidLocalDateTime() {
    var valid_dt := LDT.LocalDateTime(2023, 3, 14, 15, 9, 26, 535);
    assert LDT.IsValidLocalDateTime(valid_dt);

    var invalid_month_dt := LDT.LocalDateTime(2023, 13, 14, 15, 9, 26, 535);
    assert !LDT.IsValidLocalDateTime(invalid_month_dt);

    var invalid_day_dt := LDT.LocalDateTime(2023, 2, 30, 15, 9, 26, 535);
    assert !LDT.IsValidLocalDateTime(invalid_day_dt);

    var invalid_hour_dt := LDT.LocalDateTime(2023, 3, 14, 24, 9, 26, 535);
    assert !LDT.IsValidLocalDateTime(invalid_hour_dt);

    var invalid_minute_dt := LDT.LocalDateTime(2023, 3, 14, 15, 60, 26, 535);
    assert !LDT.IsValidLocalDateTime(invalid_minute_dt);

    var invalid_second_dt := LDT.LocalDateTime(2023, 3, 14, 15, 9, 60, 535);
    assert !LDT.IsValidLocalDateTime(invalid_second_dt);

    var invalid_millisecond_dt := LDT.LocalDateTime(2023, 3, 14, 15, 9, 26, 1000);
    assert !LDT.IsValidLocalDateTime(invalid_millisecond_dt);
  }

  method TestDaysInMonth() {
    assert DTUtils.DaysInMonth(2023, 1) == 31;
    assert DTUtils.DaysInMonth(2023, 2) == 28;
    assert DTUtils.DaysInMonth(2020, 2) == 29; // Leap year
    assert DTUtils.DaysInMonth(2023, 4) == 30;
    assert DTUtils.DaysInMonth(2023, 12) == 31;
  }

  method TestDaysInYear() {
    assert DTUtils.DaysInYear(2023) == 365;
    assert DTUtils.DaysInYear(2020) == 366; // Leap year
  }

  method TestPlusYears() {
    // Test leap year to non-leap year (Feb 29 -> Feb 28)
    var leapDay := LDT.LocalDateTime(2020, 2, 29, 10, 0, 0, 0);
    assert LDT.IsValidLocalDateTime(leapDay);
    var nextYear := LDT.PlusYears(leapDay, 1);
    assert LDT.IsValidLocalDateTime(nextYear);
    assert nextYear.year == 2021;
    assert nextYear.month == 2;
    assert nextYear.day == 28; // Clamped from Feb 29 to Feb 28
  }

  method TestPlusMonths() {
    // Test month overflow across year boundary
    var novemberDt := LDT.LocalDateTime(2023, 11, 15, 10, 0, 0, 0);
    assert LDT.IsValidLocalDateTime(novemberDt);
    var plusTwoMonths := LDT.PlusMonths(novemberDt, 2);
    assert LDT.IsValidLocalDateTime(plusTwoMonths);
    assert plusTwoMonths.year == 2024;
    assert plusTwoMonths.month == 1;
    assert plusTwoMonths.day == 15;

    // Test day clamping when moving from 31-day month to 30-day month
    var jan31 := LDT.LocalDateTime(2023, 1, 31, 10, 0, 0, 0);
    assert LDT.IsValidLocalDateTime(jan31);
    var plusOneMonth := LDT.PlusMonths(jan31, 1);
    assert LDT.IsValidLocalDateTime(plusOneMonth);
    assert plusOneMonth.year == 2023;
    assert plusOneMonth.month == 2;
    assert plusOneMonth.day == 28; // Clamped from 31 to 28 (Feb)
  }

  method TestPlusDays() {
    // Test day overflow across month boundary
    var june29 := LDT.LocalDateTime(2023, 6, 29, 10, 0, 0, 0);
    assert LDT.IsValidLocalDateTime(june29);
    var plusThreeDays := LDT.PlusDays(june29, 3);
    assert LDT.IsValidLocalDateTime(plusThreeDays);
    assert plusThreeDays.year == 2023;
    assert plusThreeDays.month == 7;
    assert plusThreeDays.day == 2;

    // Test day overflow across year boundary
    var dec30 := LDT.LocalDateTime(2023, 12, 30, 10, 0, 0, 0);
    assert LDT.IsValidLocalDateTime(dec30);
    var plusFiveDays := LDT.PlusDays(dec30, 5);
    assert LDT.IsValidLocalDateTime(plusFiveDays);
    assert plusFiveDays.year == 2024;
    assert plusFiveDays.month == 1;
    assert plusFiveDays.day == 4;
  }

  method TestPlusHours() {
    // Test hour overflow across day boundary
    var lateNight := LDT.LocalDateTime(2023, 6, 15, 22, 30, 45, 123);
    assert LDT.IsValidLocalDateTime(lateNight);
    var plusFiveHours := LDT.PlusHours(lateNight, 5);
    assert LDT.IsValidLocalDateTime(plusFiveHours);
    assert plusFiveHours.year == 2023;
    assert plusFiveHours.month == 6;
    assert plusFiveHours.day == 16;
    assert plusFiveHours.hour == 3;
    assert plusFiveHours.minute == 30;
  }

  method TestPlusMinutes() {
    // Test minute overflow across hour boundary
    var dt := LDT.LocalDateTime(2023, 6, 15, 14, 55, 45, 123);
    assert LDT.IsValidLocalDateTime(dt);
    var plusTenMinutes := LDT.PlusMinutes(dt, 10);
    assert LDT.IsValidLocalDateTime(plusTenMinutes);
    assert plusTenMinutes.hour == 15;
    assert plusTenMinutes.minute == 5;
    assert plusTenMinutes.second == 45;
  }

  method TestPlusSeconds() {
    // Test second overflow across minute boundary
    var dt := LDT.LocalDateTime(2023, 6, 15, 14, 30, 55, 123);
    assert LDT.IsValidLocalDateTime(dt);
    var plusTenSeconds := LDT.PlusSeconds(dt, 10);
    assert LDT.IsValidLocalDateTime(plusTenSeconds);
    assert plusTenSeconds.minute == 31;
    assert plusTenSeconds.second == 5;
    assert plusTenSeconds.millisecond == 123;
  }

  method TestPlusMilliseconds() {
    // Test millisecond overflow across second boundary
    var dt := LDT.LocalDateTime(2023, 6, 15, 14, 30, 45, 950);
    assert LDT.IsValidLocalDateTime(dt);
    var plus100Millis := LDT.PlusMilliseconds(dt, 100);
    assert LDT.IsValidLocalDateTime(plus100Millis);
    assert plus100Millis.second == 46;
    assert plus100Millis.millisecond == 50;
  }

  method TestMinusYears() {
    // Test leap year to non-leap year (Feb 29 -> Feb 28)
    var leapDay := LDT.LocalDateTime(2020, 2, 29, 10, 0, 0, 0);
    assert LDT.IsValidLocalDateTime(leapDay);
    var prevYear := LDT.MinusYears(leapDay, 4);
    assert LDT.IsValidLocalDateTime(prevYear);
    assert prevYear.year == 2016;
    assert prevYear.month == 2;
    assert prevYear.day == 29; // 2016 is also a leap year

    var anoLeapDay := LDT.LocalDateTime(2020, 2, 29, 10, 0, 0, 0);
    assert LDT.IsValidLocalDateTime(leapDay);
    var anoPrevYear := LDT.MinusYears(leapDay, 1);
    assert LDT.IsValidLocalDateTime(anoPrevYear);
    assert anoPrevYear.year == 2019;
    assert anoPrevYear.month == 2;
    assert anoPrevYear.day == 28; // 2019 is not a leap year

    // Test non-leap to leap year with day clamping
    var nonLeapFeb29 := LDT.LocalDateTime(2021, 2, 28, 10, 0, 0, 0);
    assert LDT.IsValidLocalDateTime(nonLeapFeb29);
    var minusOneYear := LDT.MinusYears(nonLeapFeb29, 1);
    assert LDT.IsValidLocalDateTime(minusOneYear);
    assert minusOneYear.year == 2020;
    assert minusOneYear.month == 2;
    assert minusOneYear.day == 28;
  }

  method TestMinusMonths() {
    // Test month underflow across year boundary
    var januaryDt := LDT.LocalDateTime(2024, 1, 15, 10, 0, 0, 0);
    assert LDT.IsValidLocalDateTime(januaryDt);
    var minusTwoMonths := LDT.MinusMonths(januaryDt, 2);
    assert LDT.IsValidLocalDateTime(minusTwoMonths);
    assert minusTwoMonths.year == 2023;
    assert minusTwoMonths.month == 11;
    assert minusTwoMonths.day == 15;

    // Test day clamping when moving from 31-day month to 30-day month
    var mar31 := LDT.LocalDateTime(2023, 3, 31, 10, 0, 0, 0);
    assert LDT.IsValidLocalDateTime(mar31);
    var minusOneMonth := LDT.MinusMonths(mar31, 1);
    assert LDT.IsValidLocalDateTime(minusOneMonth);
    assert minusOneMonth.year == 2023;
    assert minusOneMonth.month == 2;
    assert minusOneMonth.day == 28; // Clamped from 31 to 28 (Feb)
  }

  method TestMinusDays() {
    // Test day underflow across month boundary
    var july2 := LDT.LocalDateTime(2023, 7, 2, 10, 0, 0, 0);
    assert LDT.IsValidLocalDateTime(july2);
    var minusThreeDays := LDT.MinusDays(july2, 3);
    assert LDT.IsValidLocalDateTime(minusThreeDays);
    assert minusThreeDays.year == 2023;
    assert minusThreeDays.month == 6;
    assert minusThreeDays.day == 29;

    // Test day underflow across year boundary
    var jan4 := LDT.LocalDateTime(2024, 1, 4, 10, 0, 0, 0);
    assert LDT.IsValidLocalDateTime(jan4);
    var minusFiveDays := LDT.MinusDays(jan4, 5);
    assert LDT.IsValidLocalDateTime(minusFiveDays);
    assert minusFiveDays.year == 2023;
    assert minusFiveDays.month == 12;
    assert minusFiveDays.day == 30;
  }

  method TestMinusHours() {
    // Test hour underflow across day boundary
    var earlyMorning := LDT.LocalDateTime(2023, 6, 16, 3, 30, 45, 123);
    assert LDT.IsValidLocalDateTime(earlyMorning);
    var minusFiveHours := LDT.MinusHours(earlyMorning, 5);
    assert LDT.IsValidLocalDateTime(minusFiveHours);
    assert minusFiveHours.year == 2023;
    assert minusFiveHours.month == 6;
    assert minusFiveHours.day == 15;
    assert minusFiveHours.hour == 22;
    assert minusFiveHours.minute == 30;
  }

  method TestMinusMinutes() {
    // Test minute underflow across hour boundary
    var dt := LDT.LocalDateTime(2023, 6, 15, 15, 5, 45, 123);
    assert LDT.IsValidLocalDateTime(dt);
    var minusTenMinutes := LDT.MinusMinutes(dt, 10);
    assert LDT.IsValidLocalDateTime(minusTenMinutes);
    assert minusTenMinutes.hour == 14;
    assert minusTenMinutes.minute == 55;
    assert minusTenMinutes.second == 45;
  }

  method TestMinusSeconds() {
    // Test second underflow across minute boundary
    var dt := LDT.LocalDateTime(2023, 6, 15, 14, 31, 5, 123);
    assert LDT.IsValidLocalDateTime(dt);
    var minusTenSeconds := LDT.MinusSeconds(dt, 10);
    assert LDT.IsValidLocalDateTime(minusTenSeconds);
    assert minusTenSeconds.minute == 30;
    assert minusTenSeconds.second == 55;
    assert minusTenSeconds.millisecond == 123;
  }

  method TestMinusMilliseconds() {
    // Test millisecond underflow across second boundary
    var dt := LDT.LocalDateTime(2023, 6, 15, 14, 30, 46, 50);
    assert LDT.IsValidLocalDateTime(dt);
    var minus100Millis := LDT.MinusMilliseconds(dt, 100);
    assert LDT.IsValidLocalDateTime(minus100Millis);
    assert minus100Millis.second == 45;
    assert minus100Millis.millisecond == 950;
  }
}

method Main()
{
  TestLocalDateTime.TestOfFunction();
  TestLocalDateTime.TestParseFunction();
  TestLocalDateTime.TestCompareFunction();
  TestLocalDateTime.TestArithmeticFunctions();
  TestLocalDateTime.TestFormatFunction();
  TestLocalDateTime.TestWithNormalCase();
  TestLocalDateTime.TestWithNotNormalCase();
  TestLocalDateTime.TestGetters();
  TestLocalDateTime.TestIsLeapYear();
  TestLocalDateTime.TestIsValidLocalDateTime();
  TestLocalDateTime.TestDaysInMonth();
  TestLocalDateTime.TestDaysInYear();
  TestLocalDateTime.TestPlusYears();
  TestLocalDateTime.TestPlusMonths();
  TestLocalDateTime.TestPlusDays();
  TestLocalDateTime.TestPlusHours();
  TestLocalDateTime.TestPlusMinutes();
  TestLocalDateTime.TestPlusSeconds();
  TestLocalDateTime.TestPlusMilliseconds();
  TestLocalDateTime.TestMinusYears();
  TestLocalDateTime.TestMinusMonths();
  TestLocalDateTime.TestMinusDays();
  TestLocalDateTime.TestMinusHours();
  TestLocalDateTime.TestMinusMinutes();
  TestLocalDateTime.TestMinusSeconds();
  TestLocalDateTime.TestMinusMilliseconds();
  print "All tests passed\n";
}