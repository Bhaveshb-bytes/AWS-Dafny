include "Duration.dfy"
include "DateTimeUtils.dfy"
include "DateTimeConstant.dfy"

module LocalDateTime {
  import opened Std.Strings
  import opened Std.Wrappers
  import opened Std.BoundedInts
  import opened DateTimeConstant
  import Duration
  import DTUtils = DateTimeUtils

  // Supported date format patterns
  datatype DateFormat = 
    | ISO8601                    // yyyy-MM-ddTHH:mm:ss.fff
    | DateOnly                   // yyyy-MM-dd
    | TimeOnly                   // HH:mm:ss
    | DateTimeSpace              // yyyy-MM-dd HH:mm:ss
    | DateSlashDDMMYYYY         // dd/MM/yyyy
    | DateSlashMMDDYYYY         // MM/dd/yyyy

  // LocalDateTime: represents date-time without time zone information
  datatype LocalDateTime = LocalDateTime(
    year: uint16,
    month: uint8,
    day: uint8,
    hour: uint8,
    minute: uint8,
    second: uint8,
    millisecond: uint16
  )

  // LocalDateTime validation predicate
  predicate IsValidLocalDateTime(dt: LocalDateTime)
  {
    DTUtils.IsValidDateTime(dt.year, dt.month, dt.day, dt.hour, dt.minute, dt.second, dt.millisecond)
  }

  // LocalDateTime getter functions (bounded integers for efficient storage)
  function GetYear(dt: LocalDateTime): uint16 { dt.year }
  function GetMonth(dt: LocalDateTime): uint8 { dt.month }
  function GetDay(dt: LocalDateTime): uint8 { dt.day }
  function GetHour(dt: LocalDateTime): uint8 { dt.hour }
  function GetMinute(dt: LocalDateTime): uint8 { dt.minute }
  function GetSecond(dt: LocalDateTime): uint8 { dt.second }
  function GetMillisecond(dt: LocalDateTime): uint16 { dt.millisecond }

  // Helper conversion functions for cleaner internal calculations
  function ToIntComponents(dt: LocalDateTime): (int, int, int, int, int, int, int)
  {
    (dt.year as int, dt.month as int, dt.day as int, dt.hour as int, dt.minute as int, dt.second as int, dt.millisecond as int)
  }

  function FromIntComponents(year: int, month: int, day: int, hour: int, minute: int, second: int, millisecond: int): LocalDateTime
    requires 0 <= year <= 65535 && 0 <= month <= 255 && 0 <= day <= 255 
    requires 0 <= hour <= 255 && 0 <= minute <= 255 && 0 <= second <= 255 && 0 <= millisecond <= 65535
  {
    LocalDateTime(year as uint16, month as uint8, day as uint8, hour as uint8, minute as uint8, second as uint8, millisecond as uint16)
  }

  // Direct construction from uint components (more type-safe)
  function FromUintComponents(year: uint16, month: uint8, day: uint8, hour: uint8, minute: uint8, second: uint8, millisecond: uint16): LocalDateTime
    requires DTUtils.IsValidDateTime(year, month, day, hour, minute, second, millisecond)
  {
    LocalDateTime(year, month, day, hour, minute, second, millisecond)
  }

  // Modification functions
  function WithYear(dt: LocalDateTime, newYear: int): LocalDateTime
    requires IsValidLocalDateTime(dt) && 0 <= newYear <= 65535
    ensures IsValidLocalDateTime(WithYear(dt, newYear))
  {
    var newDay := DTUtils.ClampDay(newYear as int, dt.month as int, dt.day as int);
    FromIntComponents(newYear, dt.month as int, newDay, dt.hour as int, dt.minute as int, dt.second as int, dt.millisecond as int)
  }

  function WithMonth(dt: LocalDateTime, newMonth: int): LocalDateTime
    requires IsValidLocalDateTime(dt) && 1 <= newMonth <= 12
    ensures IsValidLocalDateTime(WithMonth(dt, newMonth))
  {
    var newDay := DTUtils.ClampDay(dt.year as int, newMonth as int, dt.day as int);
    FromIntComponents(dt.year as int, newMonth, newDay, dt.hour as int, dt.minute as int, dt.second as int, dt.millisecond as int)
  }

  function WithDayOfMonth(dt: LocalDateTime, newDay: int): LocalDateTime
    requires IsValidLocalDateTime(dt) && 1 <= newDay <= DTUtils.DaysInMonth(dt.year as int, dt.month as int)
    ensures IsValidLocalDateTime(WithDayOfMonth(dt, newDay))
  {
    FromIntComponents(dt.year as int, dt.month as int, newDay, dt.hour as int, dt.minute as int, dt.second as int, dt.millisecond as int)
  }

  function WithHour(dt: LocalDateTime, newHour: int): LocalDateTime
    requires IsValidLocalDateTime(dt) && 0 <= newHour < (HOURS_PER_DAY as int)
    ensures IsValidLocalDateTime(WithHour(dt, newHour))
  {
    FromIntComponents(dt.year as int, dt.month as int, dt.day as int, newHour, dt.minute as int, dt.second as int, dt.millisecond as int)
  }

  function WithMinute(dt: LocalDateTime, newMinute: int): LocalDateTime
    requires IsValidLocalDateTime(dt) && 0 <= newMinute < (MINUTES_PER_HOUR as int)
    ensures IsValidLocalDateTime(WithMinute(dt, newMinute))
  {
    FromIntComponents(dt.year as int, dt.month as int, dt.day as int, dt.hour as int, newMinute, dt.second as int, dt.millisecond as int)
  }

  function WithSecond(dt: LocalDateTime, newSecond: int): LocalDateTime
    requires IsValidLocalDateTime(dt) && 0 <= newSecond < (SECONDS_PER_MINUTE as int)
    ensures IsValidLocalDateTime(WithSecond(dt, newSecond))
  {
    FromIntComponents(dt.year as int, dt.month as int, dt.day as int, dt.hour as int, dt.minute as int, newSecond, dt.millisecond as int)
  }

  function WithMillisecond(dt: LocalDateTime, newMillisecond: int): LocalDateTime
    requires IsValidLocalDateTime(dt) && 0 <= newMillisecond < (MILLISECONDS_PER_SECOND as int)
    ensures IsValidLocalDateTime(WithMillisecond(dt, newMillisecond))
  {
    FromIntComponents(dt.year as int, dt.month as int, dt.day as int, dt.hour as int, dt.minute as int, dt.second as int, newMillisecond)
  }

  // Plus methods
  // Epoch-based date time arithmetic
  function Plus(dt: LocalDateTime, millisToAdd: int): LocalDateTime
    requires IsValidLocalDateTime(dt)
    ensures IsValidLocalDateTime(Plus(dt, millisToAdd))
  {
    var (year, month, day, hour, minute, second, millisecond) := ToIntComponents(dt);
    var epochMillis := DTUtils.ToEpochTimeMillisecondsFunc(year, month, day, hour, minute, second, millisecond);
    var newEpochMillis := epochMillis + millisToAdd;
    var components := DTUtils.FromEpochTimeMillisecondsFunc(newEpochMillis);
    // FromEpochTimeMillisecondsFunc ensures components are in valid range
    assert DTUtils.IsValidDateTime(components[0] as uint16, components[1] as uint8, components[2] as uint8, components[3] as uint8, components[4] as uint8, components[5] as uint8, components[6] as uint16);
    FromUintComponents(components[0] as uint16, components[1] as uint8, components[2] as uint8, components[3] as uint8, components[4] as uint8, components[5] as uint8, components[6] as uint16)
  }

  function PlusYears(dt: LocalDateTime, years: int): LocalDateTime
    requires IsValidLocalDateTime(dt)
    requires var (year, _, _, _, _, _, _) := ToIntComponents(dt); 0 <= year + years <= 65535
    ensures IsValidLocalDateTime(PlusYears(dt, years))
  {
    var (year, month, day, hour, minute, second, millisecond) := ToIntComponents(dt);
    var newYear := year + years;
    var validDay := DTUtils.ClampDay(newYear, month, day);
    FromIntComponents(newYear, month, validDay, hour, minute, second, millisecond)
  }

  function PlusMonths(dt: LocalDateTime, months: int): LocalDateTime
    requires IsValidLocalDateTime(dt)
    requires var (year, month, _, _, _, _, _) := ToIntComponents(dt); 
             var totalMonths := month + months;
             var newYear := year + (totalMonths - 1) / 12;
             var newMonth := ((totalMonths - 1) % 12) + 1;
             0 <= newYear <= 65535 && 1 <= newMonth <= 12
    ensures IsValidLocalDateTime(PlusMonths(dt, months))
  {
    var (year, month, day, hour, minute, second, millisecond) := ToIntComponents(dt);
    var totalMonths := month + months;
    var newYear := year + (totalMonths - 1) / 12;
    var newMonth := ((totalMonths - 1) % 12) + 1;
    var validDay := DTUtils.ClampDay(newYear, newMonth, day);
    FromIntComponents(newYear, newMonth, validDay, hour, minute, second, millisecond)
  }

  function PlusDays(dt: LocalDateTime, days: int): LocalDateTime
    requires IsValidLocalDateTime(dt)
    ensures IsValidLocalDateTime(PlusDays(dt, days))
  {
    Plus(dt, days * (MILLISECONDS_PER_DAY as int))
  }

  function PlusHours(dt: LocalDateTime, hours: int): LocalDateTime
    requires IsValidLocalDateTime(dt)
    ensures IsValidLocalDateTime(PlusHours(dt, hours))
  {
    Plus(dt, hours * (MILLISECONDS_PER_HOUR as int))
  }

  function PlusMinutes(dt: LocalDateTime, minutes: int): LocalDateTime
    requires IsValidLocalDateTime(dt)
    ensures IsValidLocalDateTime(PlusMinutes(dt, minutes))
  {
    Plus(dt, minutes * (MILLISECONDS_PER_MINUTE as int))
  }

  function PlusSeconds(dt: LocalDateTime, seconds: int): LocalDateTime
    requires IsValidLocalDateTime(dt)
    ensures IsValidLocalDateTime(PlusSeconds(dt, seconds))
  {
    Plus(dt, seconds * (MILLISECONDS_PER_SECOND as int))
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
    var totalMillis := (duration.seconds as int) * (MILLISECONDS_PER_SECOND as int) + (duration.millis as int);
    Plus(dt, totalMillis)
  }

  function MinusDuration(dt: LocalDateTime, duration: Duration.Duration): LocalDateTime
    requires IsValidLocalDateTime(dt)
    ensures IsValidLocalDateTime(MinusDuration(dt, duration))
  {
    var totalMillis := (duration.seconds as int) * (MILLISECONDS_PER_SECOND as int) + (duration.millis as int);
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
      // Components are already uint32, safe to convert to specific uint types
      var year := components[0] as uint16;
      var month := components[1] as uint8;
      var day := components[2] as uint8;
      var hour := components[3] as uint8;
      var minute := components[4] as uint8;
      var second := components[5] as uint8;
      var millisecond := components[6] as uint16;
      
      if DTUtils.IsValidDateTime(year, month, day, hour, minute, second, millisecond) then
        Success(FromUintComponents(year, month, day, hour, minute, second, millisecond))
      else
        Failure("Current time components are invalid")
    else
      Failure("Failed to get current time components")
  }


  // Creation functions
  function Of(year: int, month: int, day: int, hour: int, minute: int, second: int, millisecond: int): Result<LocalDateTime, string>
  {
    if year >= 0 && year <= 65535 && month >= 0 && month <= 255 && day >= 0 && day <= 255 &&
       hour >= 0 && hour <= 255 && minute >= 0 && minute <= 255 && second >= 0 && second <= 255 &&
       millisecond >= 0 && millisecond <= 65535 then
      var dt := FromIntComponents(year, month, day, hour, minute, second, millisecond);
      if IsValidLocalDateTime(dt) then
        Success(dt)
      else
        var error := DTUtils.GetValidationError(year as uint16, month as uint8, day as uint8, hour as uint8, minute as uint8, second as uint8, millisecond as uint16);
        Failure(error)
    else
      Failure("Parameters out of range for bounded integers")
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
    var (year, month, day, hour, minute, second, millisecond) := ToIntComponents(dt);
    OfInt(year) + "-" +
    DTUtils.PadWithZeros(month, 2) + "-" +
    DTUtils.PadWithZeros(day, 2) + "T" +
    DTUtils.PadWithZeros(hour, 2) + ":" +
    DTUtils.PadWithZeros(minute, 2) + ":" +
    DTUtils.PadWithZeros(second, 2) + "." +
    DTUtils.PadWithZeros(millisecond, 3)
  }

  // Type-safe format function using DateFormat datatype
  function Format(dt: LocalDateTime, format: DateFormat): string
    requires IsValidLocalDateTime(dt)
  {
    var (year, month, day, hour, minute, second, millisecond) := ToIntComponents(dt);
    match format
      case ISO8601 => ToString(dt)
      case DateOnly => OfInt(year) + "-" + DTUtils.PadWithZeros(month, 2) + "-" + DTUtils.PadWithZeros(day, 2)
      case TimeOnly => DTUtils.PadWithZeros(hour, 2) + ":" + DTUtils.PadWithZeros(minute, 2) + ":" + DTUtils.PadWithZeros(second, 2)
      case DateTimeSpace => OfInt(year) + "-" + DTUtils.PadWithZeros(month, 2) + "-" + DTUtils.PadWithZeros(day, 2) + " " +
                           DTUtils.PadWithZeros(hour, 2) + ":" + DTUtils.PadWithZeros(minute, 2) + ":" + DTUtils.PadWithZeros(second, 2)
      case DateSlashDDMMYYYY => DTUtils.PadWithZeros(day, 2) + "/" + DTUtils.PadWithZeros(month, 2) + "/" + OfInt(year)
      case DateSlashMMDDYYYY => DTUtils.PadWithZeros(month, 2) + "/" + DTUtils.PadWithZeros(day, 2) + "/" + OfInt(year)
  }

  // String-based format function that returns Result for backwards compatibility
  function FormatString(dt: LocalDateTime, pattern: string): Result<string, string>
    requires IsValidLocalDateTime(dt)
  {
    if pattern == "yyyy-MM-ddTHH:mm:ss.fff" then
      Success(Format(dt, ISO8601))
    else if pattern == "yyyy-MM-dd" then
      Success(Format(dt, DateOnly))
    else if pattern == "HH:mm:ss" then
      Success(Format(dt, TimeOnly))
    else if pattern == "yyyy-MM-dd HH:mm:ss" then
      Success(Format(dt, DateTimeSpace))
    else if pattern == "dd/MM/yyyy" then
      Success(Format(dt, DateSlashDDMMYYYY))
    else if pattern == "MM/dd/yyyy" then
      Success(Format(dt, DateSlashMMDDYYYY))
    else
      Failure("Unsupported format pattern: " + pattern)
  }
}