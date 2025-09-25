module DateTimeUtils {
  // Core constants used in validation and calculations
  const MILLISECONDS_PER_SECOND: int := 1000
  const SECONDS_PER_MINUTE: int := 60
  const MINUTES_PER_HOUR: int := 60
  const HOURS_PER_DAY: int := 24
  
  // Derived constants for performance
  const MILLISECONDS_PER_MINUTE: int := SECONDS_PER_MINUTE * MILLISECONDS_PER_SECOND
  const MILLISECONDS_PER_HOUR: int := MINUTES_PER_HOUR * MILLISECONDS_PER_MINUTE
  const MILLISECONDS_PER_DAY: int := HOURS_PER_DAY * MILLISECONDS_PER_HOUR
  
  // Month lookup table for cumulative days
  const DAYS_BEFORE_MONTH: seq<int> := [0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334]
  
  // Month names for better error messages
  const MONTH_NAMES: seq<string> := ["January", "February", "March", "April", "May", "June", 
                                    "July", "August", "September", "October", "November", "December"]

  // Leap year calculation
  predicate IsLeapYear(year: int)
  {
    (year % 4 == 0) && (year % 100 != 0 || year % 400 == 0)
  }

  // Days in month calculation
  function DaysInMonth(year: int, month: int): int
    requires 1 <= month <= 12
  {
    if month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12 then 31
    else if month == 4 || month == 6 || month == 9 || month == 11 then 30
    else if IsLeapYear(year) then 29
    else 28
  }

  // Days in year calculation
  function DaysInYear(year: int): int
  {
    if IsLeapYear(year) then 366 else 365
  }

  // Month name getter
  function GetMonthName(month: int): string
    requires 1 <= month <= 12
  {
    MONTH_NAMES[month - 1]
  }

  // Date-time validation predicate
  predicate IsValidDateTime(year: int, month: int, day: int, hour: int, minute: int, second: int, millisecond: int)
  {
    1 <= month <= 12 &&
    1 <= day <= DaysInMonth(year, month) &&
    0 <= hour < HOURS_PER_DAY &&
    0 <= minute < MINUTES_PER_HOUR &&
    0 <= second < SECONDS_PER_MINUTE &&
    0 <= millisecond < MILLISECONDS_PER_SECOND
  }

  // Day of week calculation using Sakamoto's algorithm
  function GetDayOfWeek(year: int, month: int, day: int): int
    requires 1 <= month <= 12 && 1 <= day <= DaysInMonth(year, month)
  {
    // Returns 0=Sunday, 1=Monday, ..., 6=Saturday
    var t := [0, 3, 2, 5, 0, 3, 5, 1, 4, 6, 2, 4];
    var y := if month < 3 then year - 1 else year;
    (y + y/4 - y/100 + y/400 + t[month-1] + day) % 7
  }

  // Day of year calculation using optimized lookup
  function GetDayOfYear(year: int, month: int, day: int): int
    requires 1 <= month <= 12 && 1 <= day <= DaysInMonth(year, month)
  {
    var daysFromPreviousMonths := DAYS_BEFORE_MONTH[month - 1];
    var leapDayAdjustment := if IsLeapYear(year) && month > 2 then 1 else 0;
    daysFromPreviousMonths + leapDayAdjustment + day
  }

  // Convert time portion to total milliseconds since midnight
  function TimeToMilliseconds(hour: int, minute: int, second: int, millisecond: int): int
    requires 0 <= hour < HOURS_PER_DAY && 0 <= minute < MINUTES_PER_HOUR
    requires 0 <= second < SECONDS_PER_MINUTE && 0 <= millisecond < MILLISECONDS_PER_SECOND
    ensures 0 <= TimeToMilliseconds(hour, minute, second, millisecond) < MILLISECONDS_PER_DAY
  {
    ((hour * MINUTES_PER_HOUR + minute) * SECONDS_PER_MINUTE + second) * MILLISECONDS_PER_SECOND + millisecond
  }

  // Convert total milliseconds back to time components
  function MillisecondsToTime(millis: int): (int, int, int, int)
    requires 0 <= millis < MILLISECONDS_PER_DAY
    ensures var (h, m, s, ms) := MillisecondsToTime(millis); 
            0 <= h < HOURS_PER_DAY && 0 <= m < MINUTES_PER_HOUR && 
            0 <= s < SECONDS_PER_MINUTE && 0 <= ms < MILLISECONDS_PER_SECOND
  {
    var totalSeconds := millis / MILLISECONDS_PER_SECOND;
    var ms := millis % MILLISECONDS_PER_SECOND;
    var totalMinutes := totalSeconds / SECONDS_PER_MINUTE;
    var s := totalSeconds % SECONDS_PER_MINUTE;
    var h := totalMinutes / MINUTES_PER_HOUR;
    var m := totalMinutes % MINUTES_PER_HOUR;
    (h, m, s, ms)
  }

  // String conversion utilities
  function IntToString(value: int): string
  {
    if value == 0 then "0"
    else if value > 0 then IntToStringPositive(value)
    else "-" + IntToStringPositive(-value)
  }

  function IntToStringPositive(value: int): string
    requires value > 0
    decreases value
  {
    if value < 10 then [value as char + '0']
    else IntToStringPositive(value / 10) + [(value % 10) as char + '0']
  }

  // Helper function for padding numbers with zeros
  function PadWithZeros(value: int, width: int): string
    requires value >= 0
  {
    if width <= 1 then
      if value < 10 then [value as char + '0']
      else IntToString(value)
    else if value < 10 then
      "0" + PadWithZeros(value, width - 1)
    else
      IntToString(value)
  }

  // Generate detailed error messages for validation failures
  function GetValidationError(year: int, month: int, day: int, hour: int, minute: int, second: int, millisecond: int): string
  {
    if month < 1 || month > 12 then "Invalid month: " + IntToString(month) + " (must be 1-12)"
    else if day < 1 || day > DaysInMonth(year, month) then "Invalid day: " + IntToString(day) + " for " + GetMonthName(month) + " " + IntToString(year) + " (max: " + IntToString(DaysInMonth(year, month)) + ")"
    else if hour < 0 || hour >= HOURS_PER_DAY then "Invalid hour: " + IntToString(hour) + " (must be 0-23)"
    else if minute < 0 || minute >= MINUTES_PER_HOUR then "Invalid minute: " + IntToString(minute) + " (must be 0-59)"
    else if second < 0 || second >= SECONDS_PER_MINUTE then "Invalid second: " + IntToString(second) + " (must be 0-59)"
    else if millisecond < 0 || millisecond >= MILLISECONDS_PER_SECOND then "Invalid millisecond: " + IntToString(millisecond) + " (must be 0-999)"
    else "Invalid date/time"
  }
}