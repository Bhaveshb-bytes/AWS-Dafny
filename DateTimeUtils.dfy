include "DateTimeConstant.dfy"

module DateTimeUtils {
  import opened Std.Strings
  import opened DateTimeConstant

  // Month names for better error messages
  const MONTH_NAMES: seq<string> := ["January", "February", "March", "April", "May", "June",
                                     "July", "August", "September", "October", "November", "December"]

  // Function versions for use in function contexts
  function {:extern "DateTimeImpl", "ToEpochTimeMilliseconds"}
    {:axiom} ToEpochTimeMillisecondsFunc(year: int, month: int, day: int, hour: int, minute: int, second: int, millisecond: int): int

  function {:extern "DateTimeImpl", "FromEpochTimeMilliseconds"}
    {:axiom} FromEpochTimeMillisecondsFunc(epochMillis: int): seq<int>
    ensures |FromEpochTimeMillisecondsFunc(epochMillis)| == 7
    ensures var components := FromEpochTimeMillisecondsFunc(epochMillis);
            IsValidDateTime(components[0], components[1], components[2], components[3], components[4], components[5], components[6])

  // External function for getting current time components
  function {:extern "DateTimeImpl", "GetNowComponents"}
    {:axiom} GetNowComponentsFunc(): seq<char>
    ensures |GetNowComponentsFunc()| == 7

  // Leap year calculation
  predicate IsLeapYear(year: int)
  {
    (year % 4 == 0) && (year % 100 != 0 || year % 400 == 0)
  }

  // Days in month calculation
  function DaysInMonth(year: int, month: int): int
    requires 1 <= month <= 12
  {
    if month == 2 then
      if IsLeapYear(year) then 29 else 28
    else if month == 4 || month == 6 || month == 9 || month == 11 then 30
    else 31
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

  // Helper function for padding numbers with zeros
  function PadWithZeros(value: int, width: int): string
    requires value >= 0
  {
    var valueStr := OfInt(value);
    if |valueStr| >= width then valueStr
    else
      var zerosNeeded := width - |valueStr|;
      var zeros := seq(zerosNeeded, i => '0');
      zeros + valueStr
  }

  // Generate detailed error messages for validation failures
  function GetValidationError(year: int, month: int, day: int, hour: int, minute: int, second: int, millisecond: int): string
  {
    if month < 1 || month > 12 then "Invalid month: " + OfInt(month) + " (must be 1-12)"
    else if day < 1 || day > DaysInMonth(year, month) then "Invalid day: " + OfInt(day) + " for " + GetMonthName(month) + " " + OfInt(year) + " (max: " + OfInt(DaysInMonth(year, month)) + ")"
    else if hour < 0 || hour >= HOURS_PER_DAY then "Invalid hour: " + OfInt(hour) + " (must be 0-23)"
    else if minute < 0 || minute >= MINUTES_PER_HOUR then "Invalid minute: " + OfInt(minute) + " (must be 0-59)"
    else if second < 0 || second >= SECONDS_PER_MINUTE then "Invalid second: " + OfInt(second) + " (must be 0-59)"
    else if millisecond < 0 || millisecond >= MILLISECONDS_PER_SECOND then "Invalid millisecond: " + OfInt(millisecond) + " (must be 0-999)"
    else "Invalid date/time"
  }

  // Clamp day to valid range when changing year or month
  function ClampDay(year: int, month: int, desiredDay: int): int
    requires 1 <= month <= 12
    requires desiredDay >= 1
    ensures 1 <= ClampDay(year, month, desiredDay) <= DaysInMonth(year, month)
    ensures desiredDay <= DaysInMonth(year, month) ==> ClampDay(year, month, desiredDay) == desiredDay
    ensures desiredDay >  DaysInMonth(year, month) ==> ClampDay(year, month, desiredDay) == DaysInMonth(year, month)
  {
    if desiredDay <= DaysInMonth(year, month) then desiredDay else DaysInMonth(year, month)
  }
}