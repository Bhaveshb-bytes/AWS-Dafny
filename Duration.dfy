

module Duration {

  // -------------------------
  // Duration s
  // -------------------------
  datatype Duration = Duration(
    days: int,
    seconds: int,   // 0 <= seconds < 86400
    millis: int     // 0 <= millis < 1000
  )

  function NormalizeDuration(d: int, s: int, m: int): Duration {
      ensures 0 <= NormalizeDuration(d, s, m).seconds < 86400
      ensures 0 <= NormalizeDuration(d, s, m).millis < 1000
    var extraSec := m / 1000;
    var newMillis := m % 1000;
    if newMillis < 0 then
      newMillis := newMillis + 1000;
      extraSec := extraSec - 1;

    var totalSec := s + extraSec;
    var extraDays := totalSec / 86400;
    var newSec := totalSec % 86400;
    if newSec < 0 then
      newSec := newSec + 86400;
      extraDays := extraDays - 1;

    Duration(d + extraDays, newSec, newMillis)
  }

  function DurationBetween(dt1: DateTime, dt2: DateTime): Duration {
    // naive: no timezone, direct difference in fields (simplified!)
    // For now, assume valid normalized datetimes
    // TODO: implement real calendar math
    Duration(0, 0, 0) // placeholder
  }

  // -------------------------
  // TimeZone
  // -------------------------
  datatype TimeZone =
    | UTC()
    | FixedOffset(minutes: int)
    // future extension: rules for DST, named zones, etc.

  // -------------------------
  // DateTime
  // -------------------------
  datatype DateTime = DateTime(
    year: int,
    month: int,   // 1-12
    day: int,     // 1-31
    hour: int,    // 0-23
    minute: int,  // 0-59
    second: int,  // 0-59
    millis: int,  // 0-999
    tz: option<TimeZone> // None = LocalDateTime, Some = ZonedDateTime
  )

  // -------------------------
  // Factories
  // -------------------------
  function DateTimeOf(y: int, mo: int, d: int,
                      h: int, mi: int, s: int, ms: int): DateTime {
    DateTime(y, mo, d, h, mi, s, ms, None)
  }

  function ZonedDateTimeOf(y: int, mo: int, d: int,
                           h: int, mi: int, s: int, ms: int,
                           tz: TimeZone): DateTime {
    DateTime(y, mo, d, h, mi, s, ms, Some(tz))
  }

  // -------------------------
  // Operations
  // -------------------------
  function AddDuration(dt: DateTime, dur: Duration): DateTime {
      ensures AddDuration(dt, dur).year == dt.year  // placeholder
      ensures AddDuration(dt, dur).tz == dt.tz
    DateTime(dt.year, dt.month, dt.day, dt.hour, dt.minute, dt.second, dt.millis + dur.millis, dt.tz)
  }

  function SubtractDuration(dt: DateTime, dur: Duration): DateTime {
    ensures SubtractDuration(dt, dur).tz == dt.tz
    AddDuration(dt, NormalizeDuration(-dur.days, -dur.seconds, -dur.millis))
  }

  function Between(dt1: DateTime, dt2: DateTime): Duration {
    DurationBetween(dt1, dt2)
  }

  // -------------------------
  // Conversion
  // -------------------------
  function ToTimestamp(dt: DateTime): int
   requires dt.tz.Some?
       ensures ToTimestamp(dt) >= 0
     {
       // TODO: implement conversion
       0
     }

  // -------------------------
  // String Formatting
  // -------------------------
  function ToString(dt: DateTime): string {
    ensures |ToString(dt)| > 0
    dt.year.ToString() + "-" +
    dt.month.ToString() + "-" +
    dt.day.ToString() + "T" +
    dt.hour.ToString() + ":" +
    dt.minute.ToString() + ":" +
    dt.second.ToString() + "." +
    dt.millis.ToString() +
    (if dt.tz.None? then "" else "Z") // placeholder for timezone
  }
}
//////////////////////////////////////////////////////////


