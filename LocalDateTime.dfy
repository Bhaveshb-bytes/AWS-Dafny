include "Duration.dfy"
include "DateTimeUtils.dfy"

module LocalDateTime {
  import opened Std.Strings
  import Duration
  import DTUtils = DateTimeUtils

  // Result type for operations that can fail
  datatype Result<T, E> = Success(value: T) | Failure(error: E)

  // LocalDateTime: represents date-time without time zone information
  datatype LocalDateTime = LocalDateTime(
    year: int,
    month: int,
    day: int,
    hour: int,
    minute: int,
    second: int,
    millisecond: int
  )

  // LocalDateTime validation predicate
  predicate IsValidLocalDateTime(dt: LocalDateTime)
  {
    DTUtils.IsValidDateTime(dt.year, dt.month, dt.day, dt.hour, dt.minute, dt.second, dt.millisecond)
  }

  // LocalDateTime getter functions
  function GetYear(dt: LocalDateTime): int { dt.year }
  function GetMonth(dt: LocalDateTime): int { dt.month }
  function GetDay(dt: LocalDateTime): int { dt.day }
  function GetHour(dt: LocalDateTime): int { dt.hour }
  function GetMinute(dt: LocalDateTime): int { dt.minute }
  function GetSecond(dt: LocalDateTime): int { dt.second }
  function GetMillisecond(dt: LocalDateTime): int { dt.millisecond }

  // Modification functions
  function WithYear(dt: LocalDateTime, newYear: int): LocalDateTime
    requires IsValidLocalDateTime(dt)
    ensures IsValidLocalDateTime(WithYear(dt, newYear))
  {
    var newDay := DTUtils.ClampDay(newYear, dt.month, dt.day);
    LocalDateTime(newYear, dt.month, newDay, dt.hour, dt.minute, dt.second, dt.millisecond)
  }

  function WithMonth(dt: LocalDateTime, newMonth: int): LocalDateTime
    requires IsValidLocalDateTime(dt) && 1 <= newMonth <= 12
    ensures IsValidLocalDateTime(WithMonth(dt, newMonth))
  {
    var newDay := DTUtils.ClampDay(dt.year, newMonth, dt.day);
    LocalDateTime(dt.year, newMonth, newDay, dt.hour, dt.minute, dt.second, dt.millisecond)
  }

  function WithDayOfMonth(dt: LocalDateTime, newDay: int): LocalDateTime
    requires IsValidLocalDateTime(dt) && 1 <= newDay <= DTUtils.DaysInMonth(dt.year, dt.month)
    ensures IsValidLocalDateTime(WithDayOfMonth(dt, newDay))
  {
    LocalDateTime(dt.year, dt.month, newDay, dt.hour, dt.minute, dt.second, dt.millisecond)
  }

  function WithHour(dt: LocalDateTime, newHour: int): LocalDateTime
    requires IsValidLocalDateTime(dt) && 0 <= newHour < DTUtils.HOURS_PER_DAY
    ensures IsValidLocalDateTime(WithHour(dt, newHour))
  {
    LocalDateTime(dt.year, dt.month, dt.day, newHour, dt.minute, dt.second, dt.millisecond)
  }

  function WithMinute(dt: LocalDateTime, newMinute: int): LocalDateTime
    requires IsValidLocalDateTime(dt) && 0 <= newMinute < DTUtils.MINUTES_PER_HOUR
    ensures IsValidLocalDateTime(WithMinute(dt, newMinute))
  {
    LocalDateTime(dt.year, dt.month, dt.day, dt.hour, newMinute, dt.second, dt.millisecond)
  }

  function WithSecond(dt: LocalDateTime, newSecond: int): LocalDateTime
    requires IsValidLocalDateTime(dt) && 0 <= newSecond < DTUtils.SECONDS_PER_MINUTE
    ensures IsValidLocalDateTime(WithSecond(dt, newSecond))
  {
    LocalDateTime(dt.year, dt.month, dt.day, dt.hour, dt.minute, newSecond, dt.millisecond)
  }

  function WithMillisecond(dt: LocalDateTime, newMillisecond: int): LocalDateTime
    requires IsValidLocalDateTime(dt) && 0 <= newMillisecond < DTUtils.MILLISECONDS_PER_SECOND
    ensures IsValidLocalDateTime(WithMillisecond(dt, newMillisecond))
  {
    LocalDateTime(dt.year, dt.month, dt.day, dt.hour, dt.minute, dt.second, newMillisecond)
  }

  // Plus methods
  function PlusYears(dt: LocalDateTime, years: int): LocalDateTime
    requires IsValidLocalDateTime(dt)
    ensures IsValidLocalDateTime(PlusYears(dt, years))
  {
    WithYear(dt, dt.year + years)
  }

  function PlusMonths(dt: LocalDateTime, months: int): LocalDateTime
    requires IsValidLocalDateTime(dt)
    ensures IsValidLocalDateTime(PlusMonths(dt, months))
  {
    var totalMonths := dt.month + months;
    var newYear := dt.year + (totalMonths - 1) / 12;
    var newMonth := ((totalMonths - 1) % 12) + 1;
    var clampedDay := DTUtils.ClampDay(newYear, newMonth, dt.day);
    LocalDateTime(newYear, newMonth, clampedDay, dt.hour, dt.minute, dt.second, dt.millisecond)
  }

  function PlusDays(dt: LocalDateTime, days: int): LocalDateTime
    requires IsValidLocalDateTime(dt)
    ensures IsValidLocalDateTime(PlusDays(dt, days))
  {
    if days == 0 then dt
    else if days > 0 then
      AddPositiveDays(dt.year, dt.month, dt.day, days, dt.hour, dt.minute, dt.second, dt.millisecond)
    else
      SubtractPositiveDays(dt.year, dt.month, dt.day, -days, dt.hour, dt.minute, dt.second, dt.millisecond)
  }

  function PlusHours(dt: LocalDateTime, hours: int): LocalDateTime
    requires IsValidLocalDateTime(dt)
    ensures IsValidLocalDateTime(PlusHours(dt, hours))
  {
    var duration := Duration.Duration(hours * DTUtils.SECONDS_PER_MINUTE * DTUtils.MINUTES_PER_HOUR, 0);
    Plus(dt, duration)
  }

  function PlusMinutes(dt: LocalDateTime, minutes: int): LocalDateTime
    requires IsValidLocalDateTime(dt)
    ensures IsValidLocalDateTime(PlusMinutes(dt, minutes))
  {
    var duration := Duration.Duration(minutes * DTUtils.SECONDS_PER_MINUTE, 0);
    Plus(dt, duration)
  }

  function PlusSeconds(dt: LocalDateTime, seconds: int): LocalDateTime
    requires IsValidLocalDateTime(dt)
    ensures IsValidLocalDateTime(PlusSeconds(dt, seconds))
  {
    var duration := Duration.Duration(seconds, 0);
    Plus(dt, duration)
  }

  function PlusMilliseconds(dt: LocalDateTime, millis: int): LocalDateTime
    requires IsValidLocalDateTime(dt)
    ensures IsValidLocalDateTime(PlusMilliseconds(dt, millis))
  {
    var duration := Duration.Duration(0, millis);
    Plus(dt, duration)
  }

  // Minus methods
  function MinusYears(dt: LocalDateTime, years: int): LocalDateTime
    requires IsValidLocalDateTime(dt)
    ensures IsValidLocalDateTime(MinusYears(dt, years))
  {
    PlusYears(dt, -years)
  }

  function MinusMonths(dt: LocalDateTime, months: int): LocalDateTime
    requires IsValidLocalDateTime(dt)
    ensures IsValidLocalDateTime(MinusMonths(dt, months))
  {
    PlusMonths(dt, -months)
  }

  function MinusDays(dt: LocalDateTime, days: int): LocalDateTime
    requires IsValidLocalDateTime(dt)
    ensures IsValidLocalDateTime(MinusDays(dt, days))
  {
    PlusDays(dt, -days)
  }

  function MinusHours(dt: LocalDateTime, hours: int): LocalDateTime
    requires IsValidLocalDateTime(dt)
    ensures IsValidLocalDateTime(MinusHours(dt, hours))
  {
    PlusHours(dt, -hours)
  }

  function MinusMinutes(dt: LocalDateTime, minutes: int): LocalDateTime
    requires IsValidLocalDateTime(dt)
    ensures IsValidLocalDateTime(MinusMinutes(dt, minutes))
  {
    PlusMinutes(dt, -minutes)
  }

  function MinusSeconds(dt: LocalDateTime, seconds: int): LocalDateTime
    requires IsValidLocalDateTime(dt)
    ensures IsValidLocalDateTime(MinusSeconds(dt, seconds))
  {
    PlusSeconds(dt, -seconds)
  }

  function MinusMilliseconds(dt: LocalDateTime, millis: int): LocalDateTime
    requires IsValidLocalDateTime(dt)
    ensures IsValidLocalDateTime(MinusMilliseconds(dt, millis))
  {
    PlusMilliseconds(dt, -millis)
  }

  // LocalDateTime comparison function
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

  // Now method which returns current local date time
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
    // Currently only supports ISO 8601 format parser: YYYY-MM-DDTHH:mm:ss.fff
    if |text| < 23 then
      Failure("Invalid format: Only supports ISO 8601 format YYYY-MM-DDTHH:mm:ss.fff for now")
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

      var year := ToInt(yearStr);
      var month := ToInt(monthStr);
      var day := ToInt(dayStr);
      var hour := ToInt(hourStr);
      var minute := ToInt(minuteStr);
      var second := ToInt(secondStr);
      var millisecond := ToInt(millisecondStr);

      Of(year, month, day, hour, minute, second, millisecond)
  }


  // Arithmetic functions
  function Plus(dt: LocalDateTime, duration: Duration.Duration): LocalDateTime
    requires IsValidLocalDateTime(dt) && Duration.IsValid(duration)
    ensures IsValidLocalDateTime(Plus(dt, duration))
  {
    AddDuration(dt, duration.seconds, duration.millis)
  }

  function Minus(dt: LocalDateTime, duration: Duration.Duration): LocalDateTime
    requires IsValidLocalDateTime(dt) && Duration.IsValid(duration)
    ensures IsValidLocalDateTime(Minus(dt, duration))
  {
    AddDuration(dt, -duration.seconds, -duration.millis)
  }

  function AddDuration(dt: LocalDateTime, seconds: int, millis: int): LocalDateTime
    requires IsValidLocalDateTime(dt)
    ensures IsValidLocalDateTime(AddDuration(dt, seconds, millis))
  {
    var totalMillis := seconds * DTUtils.MILLISECONDS_PER_SECOND + millis;
    var currentTimeMillis := DTUtils.TimeToMilliseconds(dt.hour, dt.minute, dt.second, dt.millisecond);
    var newTotalMillis := currentTimeMillis + totalMillis;
    
    var dayOffset := newTotalMillis / DTUtils.MILLISECONDS_PER_DAY;
    var timeMillis := newTotalMillis % DTUtils.MILLISECONDS_PER_DAY;
    
    var (finalDayOffset, finalTimeMillis) := 
      if timeMillis < 0 then (dayOffset - 1, timeMillis + DTUtils.MILLISECONDS_PER_DAY)
      else (dayOffset, timeMillis);
    
    var (hour, minute, second, millisecond) := DTUtils.MillisecondsToTime(finalTimeMillis);
    AddDays(dt, finalDayOffset, hour, minute, second, millisecond)
  }

  function AddDays(dt: LocalDateTime, days: int, hour: int, minute: int, second: int, millisecond: int): LocalDateTime
    requires IsValidLocalDateTime(dt)
    requires 0 <= hour < DTUtils.HOURS_PER_DAY && 0 <= minute < DTUtils.MINUTES_PER_HOUR
    requires 0 <= second < DTUtils.SECONDS_PER_MINUTE && 0 <= millisecond < DTUtils.MILLISECONDS_PER_SECOND
    ensures IsValidLocalDateTime(AddDays(dt, days, hour, minute, second, millisecond))
  {
    if days == 0 then 
      LocalDateTime(dt.year, dt.month, dt.day, hour, minute, second, millisecond)
    else if days > 0 then
      AddPositiveDays(dt.year, dt.month, dt.day, days, hour, minute, second, millisecond)
    else
      SubtractPositiveDays(dt.year, dt.month, dt.day, -days, hour, minute, second, millisecond)
  }

  function AddPositiveDays(year: int, month: int, day: int, days: int, hour: int, minute: int, second: int, millisecond: int): LocalDateTime
    requires days > 0 && 1 <= month <= 12 && 1 <= day <= DTUtils.DaysInMonth(year, month)
    requires 0 <= hour < DTUtils.HOURS_PER_DAY && 0 <= minute < DTUtils.MINUTES_PER_HOUR
    requires 0 <= second < DTUtils.SECONDS_PER_MINUTE && 0 <= millisecond < DTUtils.MILLISECONDS_PER_SECOND
    ensures IsValidLocalDateTime(AddPositiveDays(year, month, day, days, hour, minute, second, millisecond))
    decreases days
  {
    var daysInMonth := DTUtils.DaysInMonth(year, month);
    if day + days <= daysInMonth then
      LocalDateTime(year, month, day + days, hour, minute, second, millisecond)
    else
      // Calculate days to reach end of current month
      var daysToEndOfMonth := daysInMonth - day + 1;
      var remainingDays := days - daysToEndOfMonth;
      
      // Move to first day of next month
      var (nextYear, nextMonth) := if month == 12 then (year + 1, 1) else (year, month + 1);
      
      if remainingDays == 0 then
        LocalDateTime(nextYear, nextMonth, 1, hour, minute, second, millisecond)
      else
        AddPositiveDays(nextYear, nextMonth, 1, remainingDays, hour, minute, second, millisecond)
  }

  function SubtractPositiveDays(year: int, month: int, day: int, days: int, hour: int, minute: int, second: int, millisecond: int): LocalDateTime
    requires days > 0 && 1 <= month <= 12 && 1 <= day <= DTUtils.DaysInMonth(year, month)
    requires 0 <= hour < DTUtils.HOURS_PER_DAY && 0 <= minute < DTUtils.MINUTES_PER_HOUR
    requires 0 <= second < DTUtils.SECONDS_PER_MINUTE && 0 <= millisecond < DTUtils.MILLISECONDS_PER_SECOND
    ensures IsValidLocalDateTime(SubtractPositiveDays(year, month, day, days, hour, minute, second, millisecond))
    decreases days
  {
    if day > days then
      LocalDateTime(year, month, day - days, hour, minute, second, millisecond)
    else
      // Calculate remaining days after going to previous month
      var remainingDays := days - day;
      
      // Move to previous month
      var (prevYear, prevMonth) := if month == 1 then (year - 1, 12) else (year, month - 1);
      var daysInPrevMonth := DTUtils.DaysInMonth(prevYear, prevMonth);
      
      if remainingDays == 0 then
        LocalDateTime(prevYear, prevMonth, daysInPrevMonth, hour, minute, second, millisecond)
      else
        SubtractPositiveDays(prevYear, prevMonth, daysInPrevMonth, remainingDays, hour, minute, second, millisecond)
  }


  // Formatting functions
  function ToString(dt: LocalDateTime): string
    requires IsValidLocalDateTime(dt)
  {
    OfInt(dt.year) + "-" +
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
    if pattern == "yyyy-MM-dd" then
      OfInt(dt.year) + "-" + DTUtils.PadWithZeros(dt.month, 2) + "-" + DTUtils.PadWithZeros(dt.day, 2)
    else if pattern == "HH:mm:ss" then
      DTUtils.PadWithZeros(dt.hour, 2) + ":" + DTUtils.PadWithZeros(dt.minute, 2) + ":" + DTUtils.PadWithZeros(dt.second, 2)
    else if pattern == "yyyy-MM-dd HH:mm:ss" then
      OfInt(dt.year) + "-" + DTUtils.PadWithZeros(dt.month, 2) + "-" + DTUtils.PadWithZeros(dt.day, 2) + " " +
      DTUtils.PadWithZeros(dt.hour, 2) + ":" + DTUtils.PadWithZeros(dt.minute, 2) + ":" + DTUtils.PadWithZeros(dt.second, 2)
    else if pattern == "dd/MM/yyyy" then
      DTUtils.PadWithZeros(dt.day, 2) + "/" + DTUtils.PadWithZeros(dt.month, 2) + "/" + OfInt(dt.year)
    else if pattern == "MM/dd/yyyy" then
      DTUtils.PadWithZeros(dt.month, 2) + "/" + DTUtils.PadWithZeros(dt.day, 2) + "/" + OfInt(dt.year)
    else
      ToString(dt)
  }
}