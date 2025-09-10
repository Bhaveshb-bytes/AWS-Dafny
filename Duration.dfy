

module Std.DateTime.Duration {

  // -------------------------
  // Duration s
  // -------------------------
  // Core constants
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
    0 <= d.seconds < SECONDS_PER_MINUTE &&
    0 <= d.milliseconds < MILLISECONDS_PER_SECOND
  }

  // Total duration in milliseconds
  function ToTotalMilliseconds(d: Duration): int
    requires IsValid(d)
  {
    d.seconds * MILLIS_PER_SECOND +
    d.milliseconds
  }

    // Build Duration from milliseconds
   function FromMilliseconds(ms: int): Duration
      ensures IsValid(FromMilliseconds(ms))
    {

      var seconds := ms / MILLIS_PER_SECOND;
      var milliseconds := ms % MILLIS_PER_SECOND;

      Duration(seconds, milliseconds)
    }
  // Equality
  function Equal(d1: Duration, d2: Duration): bool
    requires IsValid(d1) && IsValid(d2)
  {
    ToTotalMilliseconds(d1) == ToTotalMilliseconds(d2)
  }

  // Comparison (-1 if d1 < d2, 0 if equal, 1 if greater)
  function Compare(d1: Duration, d2: Duration): int
    requires IsValid(d1) && IsValid(d2)
  {
    if ToTotalMilliseconds(d1) < ToTotalMilliseconds(d2) then -1
    else if ToTotalMilliseconds(d1) > ToTotalMilliseconds(d2) then 1
    else 0
  }

  // Addition
  function Plus(d1: Duration, d2: Duration): Duration
    requires IsValid(d1) && IsValid(d2)
    ensures IsValid(Plus(d1, d2))
  {
    FromMilliseconds(ToTotalMilliseconds(d1) + ToTotalMilliseconds(d2))
  }

  // Subtraction
  function Minus(d1: Duration, d2: Duration): Duration
    requires IsValid(d1) && IsValid(d2)
    ensures IsValid(Minus(d1, d2))
  {
    FromMilliseconds(ToTotalMilliseconds(d1) - ToTotalMilliseconds(d2))
  }
  function GetSeconds(d: Duration): int { d.seconds }
  function GetMilliseconds(d: Duration): int { d.milliseconds }

  // Formatting
  function ToString(d: Duration): string
    requires IsValid(d)
  {
    var sign := if ToTotalMilliseconds(d) < 0 then "-" else "";
    sign +
    GetSeconds(d).ToString() + "s " +
    GetMilliseconds(d).ToString() + "ms"
  }
 }
