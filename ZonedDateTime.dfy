include "LocalDateTime.dfy"
include "Duration.dfy"
include "Timezone.dfy"

module Std.DateTime.ZonedDateTime {
  import opened LocalDateTime
  import Duration  
  import Timezone

  // ZonedDateTime: represents date-time with time zone information
  datatype ZonedDateTime = ZonedDateTime(
    localDateTime: LocalDateTime,
    timezone: Timezone.Timezone
  )

  // ZonedDateTime validation predicate
  predicate IsValidZonedDateTime(zdt: ZonedDateTime)

  // ZonedDateTime getter functions
  function GetYear(zdt: ZonedDateTime): int { zdt.localDateTime.year }
  function GetMonth(zdt: ZonedDateTime): int { zdt.localDateTime.month }
  function GetDay(zdt: ZonedDateTime): int { zdt.localDateTime.day }
  function GetHour(zdt: ZonedDateTime): int { zdt.localDateTime.hour }
  function GetMinute(zdt: ZonedDateTime): int { zdt.localDateTime.minute }
  function GetSecond(zdt: ZonedDateTime): int { zdt.localDateTime.second }
  function GetMillisecond(zdt: ZonedDateTime): int { zdt.localDateTime.millisecond }
  function GetTimezone(zdt: ZonedDateTime): Timezone.Timezone { zdt.timezone }

  // ZonedDateTime comparison functions
  function CompareZoned(zdt1: ZonedDateTime, zdt2: ZonedDateTime): int
    requires IsValidZonedDateTime(zdt1) && IsValidZonedDateTime(zdt2)
  
  // Creation functions
  function Now(): ZonedDateTime
    ensures IsValidZonedDateTime(Now())

  function Of(localDateTime: LocalDateTime, zone: Timezone.Timezone): ZonedDateTime
    requires IsValidLocalDateTime(localDateTime) && Timezone.IsValidTimezone(zone)
    ensures IsValidZonedDateTime(Of(localDateTime, zone))

  function OfInstant(timestamp: int, zone: Timezone.Timezone): ZonedDateTime
    requires Timezone.IsValidTimezone(zone)
    ensures IsValidZonedDateTime(OfInstant(timestamp, zone))

  function Parse(text: string): Result<ZonedDateTime, string>

  // Arithmetic functions
  function Plus(zdt: ZonedDateTime, duration: Duration.Duration): ZonedDateTime
    requires IsValidZonedDateTime(zdt) && Duration.IsValid(duration)
    ensures IsValidZonedDateTime(Plus(zdt, duration))

  function Minus(zdt: ZonedDateTime, duration: Duration.Duration): ZonedDateTime
    requires IsValidZonedDateTime(zdt) && Duration.IsValid(duration)
    ensures IsValidZonedDateTime(Minus(zdt, duration))

  // Modification functions
  function WithYear(zdt: ZonedDateTime, newYear: int): ZonedDateTime
    requires IsValidZonedDateTime(zdt)
    ensures IsValidZonedDateTime(WithYear(zdt, newYear))

  function WithMonth(zdt: ZonedDateTime, newMonth: int): ZonedDateTime
    requires IsValidZonedDateTime(zdt) && 1 <= newMonth <= 12
    ensures IsValidZonedDateTime(WithMonth(zdt, newMonth))

  function WithDayOfMonth(zdt: ZonedDateTime, newDay: int): ZonedDateTime
    requires IsValidZonedDateTime(zdt)
    ensures IsValidZonedDateTime(WithDayOfMonth(zdt, newDay))

  function WithHour(zdt: ZonedDateTime, newHour: int): ZonedDateTime
    requires IsValidZonedDateTime(zdt) && 0 <= newHour < HOURS_PER_DAY
    ensures IsValidZonedDateTime(WithHour(zdt, newHour))

  function WithMinute(zdt: ZonedDateTime, newMinute: int): ZonedDateTime
    requires IsValidZonedDateTime(zdt) && 0 <= newMinute < MINUTES_PER_HOUR
    ensures IsValidZonedDateTime(WithMinute(zdt, newMinute))

  function WithSecond(zdt: ZonedDateTime, newSecond: int): ZonedDateTime
    requires IsValidZonedDateTime(zdt) && 0 <= newSecond < SECONDS_PER_MINUTE
    ensures IsValidZonedDateTime(WithSecond(zdt, newSecond))

  function WithMillisecond(zdt: ZonedDateTime, newMillisecond: int): ZonedDateTime
    requires IsValidZonedDateTime(zdt) && 0 <= newMillisecond < MILLISECONDS_PER_SECOND
    ensures IsValidZonedDateTime(WithMillisecond(zdt, newMillisecond))

  // Zone-specific operations
  function ToUnixTimestamp(zdt: ZonedDateTime): int
    requires IsValidZonedDateTime(zdt)

  function GetOffset(zdt: ZonedDateTime): int
    requires IsValidZonedDateTime(zdt)

  function WithZone(zdt: ZonedDateTime, newZone: Timezone.Timezone): ZonedDateTime
    requires IsValidZonedDateTime(zdt) && Timezone.IsValidTimezone(newZone)
    ensures IsValidZonedDateTime(WithZone(zdt, newZone))

  // Formatting functions
  function ToString(zdt: ZonedDateTime): string
    requires IsValidZonedDateTime(zdt)

  function Format(zdt: ZonedDateTime, pattern: string): string
    requires IsValidZonedDateTime(zdt)

  // External dependencies (to be implemented per target language)
  function {:extern} NowImpl(): ZonedDateTime
    ensures IsValidZonedDateTime(NowImpl())

  function {:extern} GetSystemTimezoneImpl(): Timezone.Timezone
    ensures Timezone.IsValidTimezone(GetSystemTimezoneImpl())
}