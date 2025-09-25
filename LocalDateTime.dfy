include "Duration.dfy"
include "DateTimeUtils.dfy"

module Std.DateTime.LocalDateTime {
  import Duration
  import DTUtils = DateTimeUtils

  // Result type for operations that can fail
  datatype Result<T, E> = Success(value: T) | Failure(error: E)

  // LocalDateTime: represents date-time without time zone information
  datatype LocalDateTime = LocalDateTime(
    year: int,
    month: int,        // 1-12
    day: int,          // 1-31
    hour: int,         // 0-23
    minute: int,       // 0-59
    second: int,       // 0-59
    millisecond: int   // 0-999
  )

  // LocalDateTime validation predicate
  predicate IsValidLocalDateTime(dt: LocalDateTime)
  {
    DTUtils.IsValidDateTime(dt.year, dt.month, dt.day, dt.hour, dt.minute, dt.second, dt.millisecond)
  }

  // Helper functions for date calculations (delegating to DateTimeUtils)
  function GetDayOfWeek(dt: LocalDateTime): int
    requires IsValidLocalDateTime(dt)
  {
    DTUtils.GetDayOfWeek(dt.year, dt.month, dt.day)
  }

  function GetDayOfYear(dt: LocalDateTime): int
    requires IsValidLocalDateTime(dt)
  {
    DTUtils.GetDayOfYear(dt.year, dt.month, dt.day)
  }

  predicate IsLeapYear(year: int)
  {
    DTUtils.IsLeapYear(year)
  }

  function DaysInMonth(year: int, month: int): int
    requires 1 <= month <= 12
  {
    DTUtils.DaysInMonth(year, month)
  }

  function DaysInYear(year: int): int
  {
    DTUtils.DaysInYear(year)
  }

  function GetMonthName(month: int): string
    requires 1 <= month <= 12
  {
    DTUtils.GetMonthName(month)
  }

  // Convert time portion to total milliseconds since midnight
  function TimeToMilliseconds(dt: LocalDateTime): int
    requires IsValidLocalDateTime(dt)
    ensures 0 <= TimeToMilliseconds(dt) < DTUtils.MILLISECONDS_PER_DAY
  {
    DTUtils.TimeToMilliseconds(dt.hour, dt.minute, dt.second, dt.millisecond)
  }

  // Convert total milliseconds back to time components
  function MillisecondsToTime(millis: int): (int, int, int, int)
    requires 0 <= millis < DTUtils.MILLISECONDS_PER_DAY
    ensures var (h, m, s, ms) := MillisecondsToTime(millis); 
            0 <= h < DTUtils.HOURS_PER_DAY && 0 <= m < DTUtils.MINUTES_PER_HOUR && 
            0 <= s < DTUtils.SECONDS_PER_MINUTE && 0 <= ms < DTUtils.MILLISECONDS_PER_SECOND
  {
    DTUtils.MillisecondsToTime(millis)
  }

  // DateTime comparison functions
  function CompareLocal(dt1: LocalDateTime, dt2: LocalDateTime): int
    requires IsValidLocalDateTime(dt1) && IsValidLocalDateTime(dt2)
  {
    if dt1.year != dt2.year then
      if dt1.year < dt2.year then -1 else 1
    else if dt1.month != dt2.month then
      if dt1.month < dt2.month then -1 else 1
    else if dt1.day != dt2.day then
      if dt1.day < dt2.day then -1 else 1
    else if dt1.hour != dt2.hour then
      if dt1.hour < dt2.hour then -1 else 1
    else if dt1.minute != dt2.minute then
      if dt1.minute < dt2.minute then -1 else 1
    else if dt1.second != dt2.second then
      if dt1.second < dt2.second then -1 else 1
    else if dt1.millisecond != dt2.millisecond then
      if dt1.millisecond < dt2.millisecond then -1 else 1
    else
      0
  }

  // External method for getting current time components
  method {:extern "LocalDateTimeImpl", "NowComponents"} 
         {:axiom} NowComponentsImpl() returns (components: seq<char>)
    ensures |components| == 7

  // Now method - returns current local date time
  method Now() returns (result: Result<LocalDateTime, string>)
    ensures result.Success? ==> IsValidLocalDateTime(result.value)
  {
    var components := NowComponentsImpl();
    if |components| == 7 {
      var year := components[0] as int;
      var month := components[1] as int;
      var day := components[2] as int;
      var hour := components[3] as int;
      var minute := components[4] as int;
      var second := components[5] as int;
      var millisecond := components[6] as int;
      
      var dt := LocalDateTime(year, month, day, hour, minute, second, millisecond);
      if IsValidLocalDateTime(dt) {
        result := Success(dt);
      } else {
        result := Failure("Current time components are invalid");
      }
    } else {
      result := Failure("Failed to get current time components");
    }
  }

  // Creation functions
  function Of(year: int, month: int, day: int, hour: int, minute: int, second: int, millisecond: int): Result<LocalDateTime, string>
  {
    var dt := LocalDateTime(year, month, day, hour, minute, second, millisecond);
    if IsValidLocalDateTime(dt) then
      Success(dt)
    else
      var error := DTUtils.GetValidationError(year, month, day, hour, minute, second, millisecond);
      Failure(error)
  }

  function Parse(text: string): Result<LocalDateTime, string>
  {
    // Simple ISO 8601 format parser: YYYY-MM-DDTHH:mm:ss.fff
    if |text| < 23 then
      Failure("Invalid format: string too short")
    else if text[4] != '-' || text[7] != '-' || text[10] != 'T' ||
            text[13] != ':' || text[16] != ':' || text[19] != '.' then
      Failure("Invalid format: expected YYYY-MM-DDTHH:mm:ss.fff")
    else
      var yearStr := text[0..4];
      var monthStr := text[5..7];
      var dayStr := text[8..10];
      var hourStr := text[11..13];
      var minuteStr := text[14..16];
      var secondStr := text[17..19];
      var millisecondStr := text[20..23];

      var year := StringToInt(yearStr);
      var month := StringToInt(monthStr);
      var day := StringToInt(dayStr);
      var hour := StringToInt(hourStr);
      var minute := StringToInt(minuteStr);
      var second := StringToInt(secondStr);
      var millisecond := StringToInt(millisecondStr);

      Of(year, month, day, hour, minute, second, millisecond)
  }

  function StringToInt(s: string): int
  {
    if |s| == 0 then 0
    else if |s| == 1 then CharToInt(s[0])
    else StringToInt(s[0..|s|-1]) * 10 + CharToInt(s[|s|-1])
  }

  function CharToInt(c: char): int
  {
    if '0' <= c <= '9' then (c as int) - ('0' as int) else 0
  }

  // Arithmetic functions
  function Plus(dt: LocalDateTime, duration: Duration.Duration): LocalDateTime
    requires IsValidLocalDateTime(dt) && Duration.IsValid(duration)
    ensures IsValidLocalDateTime(Plus(dt, duration))
  {
    var durationTotalMillis := duration.seconds * DTUtils.MILLISECONDS_PER_SECOND + duration.millis;
    var currentTimeMillis := TimeToMilliseconds(dt);
    var newTimeMillis := currentTimeMillis + durationTotalMillis;
    
    var dayOffset := newTimeMillis / DTUtils.MILLISECONDS_PER_DAY;
    var adjustedTimeMillis := newTimeMillis % DTUtils.MILLISECONDS_PER_DAY;
    
    // Handle negative remainder for modulo  
    var (finalDayOffset, finalTimeMillis) := 
      if adjustedTimeMillis < 0 then
        (dayOffset - 1, adjustedTimeMillis + DTUtils.MILLISECONDS_PER_DAY)
      else
        (dayOffset, adjustedTimeMillis);
    
    var (newHour, newMinute, newSecond, newMillisecond) := MillisecondsToTime(finalTimeMillis);
    AddDaysToDate(dt.year, dt.month, dt.day, finalDayOffset, newHour, newMinute, newSecond, newMillisecond)
  }

  function AddDaysToDate(year: int, month: int, day: int, daysToAdd: int, hour: int, minute: int, second: int, millisecond: int): LocalDateTime
    requires 1 <= month <= 12 && 1 <= day <= DaysInMonth(year, month)
    requires 0 <= hour < DTUtils.HOURS_PER_DAY && 0 <= minute < DTUtils.MINUTES_PER_HOUR
    requires 0 <= second < DTUtils.SECONDS_PER_MINUTE && 0 <= millisecond < DTUtils.MILLISECONDS_PER_SECOND
    ensures IsValidLocalDateTime(AddDaysToDate(year, month, day, daysToAdd, hour, minute, second, millisecond))
  {
    if daysToAdd == 0 then
      LocalDateTime(year, month, day, hour, minute, second, millisecond)
    else if daysToAdd > 0 then
      AddPositiveDays(year, month, day, daysToAdd, hour, minute, second, millisecond)
    else
      SubtractPositiveDays(year, month, day, -daysToAdd, hour, minute, second, millisecond)
  }

  function AddPositiveDays(year: int, month: int, day: int, daysToAdd: int, hour: int, minute: int, second: int, millisecond: int): LocalDateTime
    requires daysToAdd > 0 && 1 <= month <= 12 && 1 <= day <= DaysInMonth(year, month)
    requires 0 <= hour < DTUtils.HOURS_PER_DAY && 0 <= minute < DTUtils.MINUTES_PER_HOUR
    requires 0 <= second < DTUtils.SECONDS_PER_MINUTE && 0 <= millisecond < DTUtils.MILLISECONDS_PER_SECOND
    ensures IsValidLocalDateTime(AddPositiveDays(year, month, day, daysToAdd, hour, minute, second, millisecond))
    decreases daysToAdd
  {
    var daysInCurrentMonth := DaysInMonth(year, month);
    if day + daysToAdd <= daysInCurrentMonth then
      LocalDateTime(year, month, day + daysToAdd, hour, minute, second, millisecond)
    else
      var remainingDays := daysToAdd - (daysInCurrentMonth - day + 1);
      var nextMonth := if month == 12 then 1 else month + 1;
      var nextYear := if month == 12 then year + 1 else year;
      if remainingDays > 0 then
        AddPositiveDays(nextYear, nextMonth, 1, remainingDays, hour, minute, second, millisecond)
      else
        LocalDateTime(nextYear, nextMonth, 1, hour, minute, second, millisecond)
  }

  function SubtractPositiveDays(year: int, month: int, day: int, daysToSubtract: int, hour: int, minute: int, second: int, millisecond: int): LocalDateTime
    requires daysToSubtract > 0 && 1 <= month <= 12 && 1 <= day <= DaysInMonth(year, month)
    requires 0 <= hour < DTUtils.HOURS_PER_DAY && 0 <= minute < DTUtils.MINUTES_PER_HOUR
    requires 0 <= second < DTUtils.SECONDS_PER_MINUTE && 0 <= millisecond < DTUtils.MILLISECONDS_PER_SECOND
    ensures IsValidLocalDateTime(SubtractPositiveDays(year, month, day, daysToSubtract, hour, minute, second, millisecond))
    decreases daysToSubtract
  {
    if day > daysToSubtract then
      LocalDateTime(year, month, day - daysToSubtract, hour, minute, second, millisecond)
    else
      var remainingDays := daysToSubtract - day;
      var prevMonth := if month == 1 then 12 else month - 1;
      var prevYear := if month == 1 then year - 1 else year;
      var daysInPrevMonth := DaysInMonth(prevYear, prevMonth);
      if remainingDays > 0 then
        SubtractPositiveDays(prevYear, prevMonth, daysInPrevMonth, remainingDays, hour, minute, second, millisecond)
      else
        LocalDateTime(prevYear, prevMonth, daysInPrevMonth, hour, minute, second, millisecond)
  }

  function Minus(dt: LocalDateTime, duration: Duration.Duration): LocalDateTime
    requires IsValidLocalDateTime(dt) && Duration.IsValid(duration)
    ensures IsValidLocalDateTime(Minus(dt, duration))
  {
    var durationTotalMillis := duration.seconds * DTUtils.MILLISECONDS_PER_SECOND + duration.millis;
    var currentTimeMillis := TimeToMilliseconds(dt);
    var newTimeMillis := currentTimeMillis - durationTotalMillis;
    
    var dayOffset := newTimeMillis / DTUtils.MILLISECONDS_PER_DAY;
    var adjustedTimeMillis := newTimeMillis % DTUtils.MILLISECONDS_PER_DAY;
    
    // Handle negative remainder for modulo  
    var (finalDayOffset, finalTimeMillis) := 
      if adjustedTimeMillis < 0 then
        (dayOffset - 1, adjustedTimeMillis + DTUtils.MILLISECONDS_PER_DAY)
      else
        (dayOffset, adjustedTimeMillis);
    
    var (newHour, newMinute, newSecond, newMillisecond) := MillisecondsToTime(finalTimeMillis);
    AddDaysToDate(dt.year, dt.month, dt.day, finalDayOffset, newHour, newMinute, newSecond, newMillisecond)
  }

  // Formatting functions
  function ToString(dt: LocalDateTime): string
    requires IsValidLocalDateTime(dt)
  {
    DTUtils.IntToString(dt.year) + "-" +
    DTUtils.PadWithZeros(dt.month, 2) + "-" +
    DTUtils.PadWithZeros(dt.day, 2) + "T" +
    DTUtils.PadWithZeros(dt.hour, 2) + ":" +
    DTUtils.PadWithZeros(dt.minute, 2) + ":" +
    DTUtils.PadWithZeros(dt.second, 2) + "." +
    DTUtils.PadWithZeros(dt.millisecond, 3)
  }

  function Format(dt: LocalDateTime, pattern: string): string
    requires IsValidLocalDateTime(dt)
  {
    // Simple pattern matching for common formats
    if pattern == "yyyy-MM-dd" then
      DTUtils.IntToString(dt.year) + "-" + DTUtils.PadWithZeros(dt.month, 2) + "-" + DTUtils.PadWithZeros(dt.day, 2)
    else if pattern == "HH:mm:ss" then
      DTUtils.PadWithZeros(dt.hour, 2) + ":" + DTUtils.PadWithZeros(dt.minute, 2) + ":" + DTUtils.PadWithZeros(dt.second, 2)
    else if pattern == "yyyy-MM-dd HH:mm:ss" then
      DTUtils.IntToString(dt.year) + "-" + DTUtils.PadWithZeros(dt.month, 2) + "-" + DTUtils.PadWithZeros(dt.day, 2) + " " +
      DTUtils.PadWithZeros(dt.hour, 2) + ":" + DTUtils.PadWithZeros(dt.minute, 2) + ":" + DTUtils.PadWithZeros(dt.second, 2)
    else if pattern == "dd/MM/yyyy" then
      DTUtils.PadWithZeros(dt.day, 2) + "/" + DTUtils.PadWithZeros(dt.month, 2) + "/" + DTUtils.IntToString(dt.year)
    else if pattern == "MM/dd/yyyy" then
      DTUtils.PadWithZeros(dt.month, 2) + "/" + DTUtils.PadWithZeros(dt.day, 2) + "/" + DTUtils.IntToString(dt.year)
    else
      // Default to ISO format
      ToString(dt)
  }
}