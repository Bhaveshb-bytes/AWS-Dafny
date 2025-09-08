include "Duration.dfy"
include "Timezone.dfy"

module Std.DateTime.LocalDateTime {
  import Duration
  import Timezone

  // Result type for operations that can fail
  datatype Result<T, E> = Success(value: T) | Failure(error: E)

  // Core constants used in validation
  const MILLISECONDS_PER_SECOND: int := 1000
  const SECONDS_PER_MINUTE: int := 60
  const MINUTES_PER_HOUR: int := 60
  const HOURS_PER_DAY: int := 24

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

  // Helper functions for date calculations
  function GetDayOfWeek(dt: LocalDateTime): int
    requires IsValidLocalDateTime(dt)

  function GetDayOfYear(dt: LocalDateTime): int
    requires IsValidLocalDateTime(dt)

  predicate IsLeapYear(year: int)

  function DaysInMonth(year: int, month: int): int
    requires 1 <= month <= 12

  function DaysInYear(year: int): int

  // LocalDateTime getter functions
  function GetYear(dt: LocalDateTime): int { dt.year }
  function GetMonth(dt: LocalDateTime): int { dt.month }  
  function GetDay(dt: LocalDateTime): int { dt.day }
  function GetHour(dt: LocalDateTime): int { dt.hour }
  function GetMinute(dt: LocalDateTime): int { dt.minute }
  function GetSecond(dt: LocalDateTime): int { dt.second }
  function GetMillisecond(dt: LocalDateTime): int { dt.millisecond }

  // DateTime comparison functions
  function CompareLocal(dt1: LocalDateTime, dt2: LocalDateTime): int
    requires IsValidLocalDateTime(dt1) && IsValidLocalDateTime(dt2)
  
  // Creation functions
  function Now(): LocalDateTime

  function Of(year: int, month: int, day: int, hour: int, minute: int, second: int, millisecond: int): Result<LocalDateTime, string>

  function Parse(text: string): Result<LocalDateTime, string>

  // Arithmetic functions
  function Plus(dt: LocalDateTime, duration: Duration.Duration): LocalDateTime
    requires IsValidLocalDateTime(dt) && Duration.IsValid(duration)
    ensures IsValidLocalDateTime(Plus(dt, duration))

  function Minus(dt: LocalDateTime, duration: Duration.Duration): LocalDateTime
    requires IsValidLocalDateTime(dt) && Duration.IsValid(duration)
    ensures IsValidLocalDateTime(Minus(dt, duration))

  // Modification functions
  function WithYear(dt: LocalDateTime, newYear: int): LocalDateTime
    requires IsValidLocalDateTime(dt)
    ensures IsValidLocalDateTime(WithYear(dt, newYear))

  function WithMonth(dt: LocalDateTime, newMonth: int): LocalDateTime
    requires IsValidLocalDateTime(dt) && 1 <= newMonth <= 12
    ensures IsValidLocalDateTime(WithMonth(dt, newMonth))

  function WithDayOfMonth(dt: LocalDateTime, newDay: int): LocalDateTime
    requires IsValidLocalDateTime(dt) && 1 <= newDay <= DaysInMonth(dt.year, dt.month)
    ensures IsValidLocalDateTime(WithDayOfMonth(dt, newDay))

  function WithHour(dt: LocalDateTime, newHour: int): LocalDateTime
    requires IsValidLocalDateTime(dt) && 0 <= newHour < HOURS_PER_DAY
    ensures IsValidLocalDateTime(WithHour(dt, newHour))

  function WithMinute(dt: LocalDateTime, newMinute: int): LocalDateTime
    requires IsValidLocalDateTime(dt) && 0 <= newMinute < MINUTES_PER_HOUR
    ensures IsValidLocalDateTime(WithMinute(dt, newMinute))

  function WithSecond(dt: LocalDateTime, newSecond: int): LocalDateTime
    requires IsValidLocalDateTime(dt) && 0 <= newSecond < SECONDS_PER_MINUTE
    ensures IsValidLocalDateTime(WithSecond(dt, newSecond))

  function WithMillisecond(dt: LocalDateTime, newMillisecond: int): LocalDateTime
    requires IsValidLocalDateTime(dt) && 0 <= newMillisecond < MILLISECONDS_PER_SECOND
    ensures IsValidLocalDateTime(WithMillisecond(dt, newMillisecond))

  // Formatting functions
  function ToString(dt: LocalDateTime): string
    requires IsValidLocalDateTime(dt)

  function Format(dt: LocalDateTime, pattern: string): string
    requires IsValidLocalDateTime(dt)

  // External dependencies (to be implemented per target language)
  function {:extern} NowImpl(): LocalDateTime
    ensures IsValidLocalDateTime(NowImpl())
}