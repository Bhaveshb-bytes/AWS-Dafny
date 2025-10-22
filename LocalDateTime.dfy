include "Duration.dfy"
include "DateTimeUtils.dfy"
include "DateTimeConstant.dfy"

module LocalDateTime {
  import opened Std.Strings
  import opened Std.Wrappers
  import opened DateTimeConstant
  import Duration
  import DTUtils = DateTimeUtils

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
    requires IsValidLocalDateTime(dt) && 0 <= newHour < HOURS_PER_DAY
    ensures IsValidLocalDateTime(WithHour(dt, newHour))
  {
    LocalDateTime(dt.year, dt.month, dt.day, newHour, dt.minute, dt.second, dt.millisecond)
  }

  function WithMinute(dt: LocalDateTime, newMinute: int): LocalDateTime
    requires IsValidLocalDateTime(dt) && 0 <= newMinute < MINUTES_PER_HOUR
    ensures IsValidLocalDateTime(WithMinute(dt, newMinute))
  {
    LocalDateTime(dt.year, dt.month, dt.day, dt.hour, newMinute, dt.second, dt.millisecond)
  }

  function WithSecond(dt: LocalDateTime, newSecond: int): LocalDateTime
    requires IsValidLocalDateTime(dt) && 0 <= newSecond < SECONDS_PER_MINUTE
    ensures IsValidLocalDateTime(WithSecond(dt, newSecond))
  {
    LocalDateTime(dt.year, dt.month, dt.day, dt.hour, dt.minute, newSecond, dt.millisecond)
  }

  function WithMillisecond(dt: LocalDateTime, newMillisecond: int): LocalDateTime
    requires IsValidLocalDateTime(dt) && 0 <= newMillisecond < MILLISECONDS_PER_SECOND
    ensures IsValidLocalDateTime(WithMillisecond(dt, newMillisecond))
  {
    LocalDateTime(dt.year, dt.month, dt.day, dt.hour, dt.minute, dt.second, newMillisecond)
  }

  // Plus methods
  // Epoch-based date time arithmetic
  function Plus(dt: LocalDateTime, millisToAdd: int): LocalDateTime
    requires IsValidLocalDateTime(dt)
    ensures IsValidLocalDateTime(Plus(dt, millisToAdd))
  {
    var epochMillis := DTUtils.ToEpochTimeMillisecondsFunc(dt.year, dt.month, dt.day, dt.hour, dt.minute, dt.second, dt.millisecond);
    var newEpochMillis := epochMillis + millisToAdd;
    var components := DTUtils.FromEpochTimeMillisecondsFunc(newEpochMillis);
    LocalDateTime(components[0], components[1], components[2], components[3], components[4], components[5], components[6])
  }

  function PlusYears(dt: LocalDateTime, years: int): LocalDateTime
    requires IsValidLocalDateTime(dt)
    ensures IsValidLocalDateTime(PlusYears(dt, years))
  {
    var newYear := dt.year + years;
    var validDay := DTUtils.ClampDay(newYear, dt.month, dt.day);
    LocalDateTime(newYear, dt.month, validDay, dt.hour, dt.minute, dt.second, dt.millisecond)
  }

  function PlusMonths(dt: LocalDateTime, months: int): LocalDateTime
    requires IsValidLocalDateTime(dt)
    ensures IsValidLocalDateTime(PlusMonths(dt, months))
  {
    var totalMonths := dt.month + months;
    var newYear := dt.year + (totalMonths - 1) / 12;
    var newMonth := ((totalMonths - 1) % 12) + 1;
    var validDay := DTUtils.ClampDay(newYear, newMonth, dt.day);
    LocalDateTime(newYear, newMonth, validDay, dt.hour, dt.minute, dt.second, dt.millisecond)
  }

  function PlusDays(dt: LocalDateTime, days: int): LocalDateTime
    requires IsValidLocalDateTime(dt)
    ensures IsValidLocalDateTime(PlusDays(dt, days))
  {
    Plus(dt, days * MILLISECONDS_PER_DAY)
  }

  function PlusHours(dt: LocalDateTime, hours: int): LocalDateTime
    requires IsValidLocalDateTime(dt)
    ensures IsValidLocalDateTime(PlusHours(dt, hours))
  {
    Plus(dt, hours * MILLISECONDS_PER_HOUR)
  }

  function PlusMinutes(dt: LocalDateTime, minutes: int): LocalDateTime
    requires IsValidLocalDateTime(dt)
    ensures IsValidLocalDateTime(PlusMinutes(dt, minutes))
  {
    Plus(dt, minutes * MILLISECONDS_PER_MINUTE)
  }

  function PlusSeconds(dt: LocalDateTime, seconds: int): LocalDateTime
    requires IsValidLocalDateTime(dt)
    ensures IsValidLocalDateTime(PlusSeconds(dt, seconds))
  {
    Plus(dt, seconds * MILLISECONDS_PER_SECOND)
  }

  function PlusMilliseconds(dt: LocalDateTime, milliseconds: int): LocalDateTime
    requires IsValidLocalDateTime(dt)
    ensures IsValidLocalDateTime(PlusMilliseconds(dt, milliseconds))
  {
    Plus(dt, milliseconds)
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

  function MinusMilliseconds(dt: LocalDateTime, milliseconds: int): LocalDateTime
    requires IsValidLocalDateTime(dt)
    ensures IsValidLocalDateTime(MinusMilliseconds(dt, milliseconds))
  {
    PlusMilliseconds(dt, -milliseconds)
  }

  // Arithmetic functions with Duration
  function PlusDuration(dt: LocalDateTime, duration: Duration.Duration): LocalDateTime
    requires IsValidLocalDateTime(dt)
    ensures IsValidLocalDateTime(PlusDuration(dt, duration))
  {
    var totalMillis := duration.seconds * MILLISECONDS_PER_SECOND + duration.millis;
    Plus(dt, totalMillis)
  }

  function MinusDuration(dt: LocalDateTime, duration: Duration.Duration): LocalDateTime
    requires IsValidLocalDateTime(dt)
    ensures IsValidLocalDateTime(MinusDuration(dt, duration))
  {
    var totalMillis := duration.seconds * MILLISECONDS_PER_SECOND + duration.millis;
    Plus(dt, -totalMillis)
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

  // Convenience comparison methods
  predicate IsBefore(dt1: LocalDateTime, dt2: LocalDateTime)
    requires IsValidLocalDateTime(dt1) && IsValidLocalDateTime(dt2)
  {
    CompareLocal(dt1, dt2) < 0
  }

  predicate IsAfter(dt1: LocalDateTime, dt2: LocalDateTime)
    requires IsValidLocalDateTime(dt1) && IsValidLocalDateTime(dt2)
  {
    CompareLocal(dt1, dt2) > 0
  }

  predicate IsEqual(dt1: LocalDateTime, dt2: LocalDateTime)
    requires IsValidLocalDateTime(dt1) && IsValidLocalDateTime(dt2)
  {
    CompareLocal(dt1, dt2) == 0
  }

  // Now function which returns current local date time
  function Now(): Result<LocalDateTime, string>
    ensures Now().Success? ==> IsValidLocalDateTime(Now().value)
  {
    var components := DTUtils.GetNowComponentsFunc();
    if |components| == 7 then
      var year := components[0] as int;
      var month := components[1] as int;
      var day := components[2] as int;
      var hour := components[3] as int;
      var minute := components[4] as int;
      var second := components[5] as int;
      var millisecond := components[6] as int;

      var dt := LocalDateTime(year, month, day, hour, minute, second, millisecond);
      if IsValidLocalDateTime(dt) then
        Success(dt)
      else
        Failure("Current time components are invalid")
    else
      Failure("Failed to get current time components")
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

      if !DecimalConversion.IsNumberStr(yearStr, '-') ||
         !DecimalConversion.IsNumberStr(monthStr, '-') ||
         !DecimalConversion.IsNumberStr(dayStr, '-') ||
         !DecimalConversion.IsNumberStr(hourStr, '-') ||
         !DecimalConversion.IsNumberStr(minuteStr, '-') ||
         !DecimalConversion.IsNumberStr(secondStr, '-') ||
         !DecimalConversion.IsNumberStr(millisecondStr, '-') then
        Failure("Invalid format: extracted components are not valid numbers")
      else
        var year := ToInt(yearStr);
        var month := ToInt(monthStr);
        var day := ToInt(dayStr);
        var hour := ToInt(hourStr);
        var minute := ToInt(minuteStr);
        var second := ToInt(secondStr);
        var millisecond := ToInt(millisecondStr);

        Of(year, month, day, hour, minute, second, millisecond)
  }

  // Formatting functions
  // ISO 8601 format
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
      // Default to ISO 8601 format, yyyy-MM-ddTHH:mm:ss.fff
      ToString(dt)
  }
}