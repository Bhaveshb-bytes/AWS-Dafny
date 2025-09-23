include "LocalDateTime.dfy"

module TestWithAndGet {
  import Std.DateTime.LocalDateTime

  method TestWithNormalCase() {
    var dt1 := LocalDateTime.LocalDateTime(2023, 3, 14, 15, 9, 26, 535);
    assert LocalDateTime.IsValidLocalDateTime(dt1);

    var dt1_with_new_year := LocalDateTime.WithYear(dt1, 2024);
    assert dt1_with_new_year.year == 2024;

    var dt1_with_new_month := LocalDateTime.WithMonth(dt1, 2);
    assert dt1_with_new_month.month == 2;

    var dt1_with_new_day := LocalDateTime.WithDayOfMonth(dt1, 28);
    assert dt1_with_new_day.day == 28;

    var dt1_with_new_hour := LocalDateTime.WithHour(dt1, 10);
    assert dt1_with_new_hour.hour == 10;

    var dt1_with_new_minute := LocalDateTime.WithMinute(dt1, 30);
    assert dt1_with_new_minute.minute == 30;

    var dt1_with_new_second := LocalDateTime.WithSecond(dt1, 45);
    assert dt1_with_new_second.second == 45;

    var dt1_with_new_millisecond := LocalDateTime.WithMillisecond(dt1, 999);
    assert dt1_with_new_millisecond.millisecond == 999;
  }

  method TestWithNotNormalCase() {
    var dt1 := LocalDateTime.LocalDateTime(2020, 2, 29, 15, 9, 26, 535);
    assert LocalDateTime.IsValidLocalDateTime(dt1);

    var dt1_with_new_year := LocalDateTime.WithYear(dt1, 2021);
    assert dt1_with_new_year.year == 2021;
    assert dt1_with_new_year.day == 28; // Clamped to 28 since 2021 is not a leap year

    var dt2 := LocalDateTime.LocalDateTime(2020, 3, 31, 15, 9, 26, 535);
    assert LocalDateTime.IsValidLocalDateTime(dt2); 

    var dt2_with_new_month := LocalDateTime.WithMonth(dt2, 4);
    assert dt2_with_new_month.month == 4;
    assert dt2_with_new_month.day == 30; // Clamped to 30 since April has 30 days
  }

  method TestGetters() {
    var dt := LocalDateTime.LocalDateTime(2023, 3, 14, 15, 9, 26, 535);
    assert LocalDateTime.IsValidLocalDateTime(dt);

    assert LocalDateTime.GetYear(dt) == 2023;
    assert LocalDateTime.GetMonth(dt) == 3;
    assert LocalDateTime.GetDay(dt) == 14;
    assert LocalDateTime.GetHour(dt) == 15;
    assert LocalDateTime.GetMinute(dt) == 9;
    assert LocalDateTime.GetSecond(dt) == 26;
    assert LocalDateTime.GetMillisecond(dt) == 535;
  }

  method TestIsLeapYear() {
    assert LocalDateTime.IsLeapYear(2020); // Divisible by 4 and not by 100
    assert !LocalDateTime.IsLeapYear(2021); // Not divisible by 4
    assert !LocalDateTime.IsLeapYear(1900); // Divisible by 100 but not by 400
    assert LocalDateTime.IsLeapYear(2000); // Divisible by 400
  }

  method TestIsValidLocalDateTime() {
    var valid_dt := LocalDateTime.LocalDateTime(2023, 3, 14, 15, 9, 26, 535);
    assert LocalDateTime.IsValidLocalDateTime(valid_dt);

    var invalid_month_dt := LocalDateTime.LocalDateTime(2023, 13, 14, 15, 9, 26, 535);
    assert !LocalDateTime.IsValidLocalDateTime(invalid_month_dt);

    var invalid_day_dt := LocalDateTime.LocalDateTime(2023, 2, 30, 15, 9, 26, 535);
    assert !LocalDateTime.IsValidLocalDateTime(invalid_day_dt);

    var invalid_hour_dt := LocalDateTime.LocalDateTime(2023, 3, 14, 24, 9, 26, 535);
    assert !LocalDateTime.IsValidLocalDateTime(invalid_hour_dt);

    var invalid_minute_dt := LocalDateTime.LocalDateTime(2023, 3, 14, 15, 60, 26, 535);
    assert !LocalDateTime.IsValidLocalDateTime(invalid_minute_dt);

    var invalid_second_dt := LocalDateTime.LocalDateTime(2023, 3, 14, 15, 9, 60, 535);
    assert !LocalDateTime.IsValidLocalDateTime(invalid_second_dt);

    var invalid_millisecond_dt := LocalDateTime.LocalDateTime(2023, 3, 14, 15, 9, 26, 1000);
    assert !LocalDateTime.IsValidLocalDateTime(invalid_millisecond_dt);
  }

  method TestDaysInMonth() {
    assert LocalDateTime.DaysInMonth(2023, 1) == 31;
    assert LocalDateTime.DaysInMonth(2023, 2) == 28;
    assert LocalDateTime.DaysInMonth(2020, 2) == 29; // Leap year
    assert LocalDateTime.DaysInMonth(2023, 4) == 30;
    assert LocalDateTime.DaysInMonth(2023, 12) == 31;
  }

  method TestDaysInYear() {
    assert LocalDateTime.DaysInYear(2023) == 365;
    assert LocalDateTime.DaysInYear(2020) == 366; // Leap year
  }
}