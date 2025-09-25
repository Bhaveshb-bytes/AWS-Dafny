module Std.DateTime.Duration {
  const MILLISECONDS_PER_SECOND: int := 1000
  const SECONDS_PER_MINUTE: int := 60
  const MINUTES_PER_HOUR: int := 60
  const HOURS_PER_DAY: int := 24

  const MILLIS_PER_SECOND: int := 1000
  const MILLIS_PER_MINUTE: int := 60 * MILLIS_PER_SECOND
  const MILLIS_PER_HOUR: int := 60 * MILLIS_PER_MINUTE
  const MILLIS_PER_DAY: int := 24 * MILLIS_PER_HOUR


  datatype Duration = Duration(
    seconds: int,   // 0 <= seconds < 86400
    millis: int     // 0 <= millis < 1000
  )

  predicate IsValid(d: Duration) {
    0 <= d.seconds < MILLIS_PER_DAY &&  // seconds in a day
    0 <= d.millis < MILLISECONDS_PER_SECOND
  }
}