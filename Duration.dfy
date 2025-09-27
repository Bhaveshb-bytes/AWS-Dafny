

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



 function EpochDifference(epoch1: int, epoch2: int): Duration
      requires epoch1 >= 0 && epoch2 >= 0
      ensures IsValid(EpochDifference(epoch1, epoch2))
    {
      // absolute difference in milliseconds
      var diff := if epoch1 >= epoch2 then epoch1 - epoch2 else epoch2 - epoch1;

      // break into seconds and remaining millis
      var secs  := diff / MILLIS_PER_SECOND;
      var remMs := diff % MILLIS_PER_SECOND;

      Duration(secs, remMs)
    }
  predicate IsValid(d: Duration) {
    0 <= d.seconds < SECONDS_PER_MINUTE &&
    0 <= d.millis < MILLISECONDS_PER_SECOND
  }

  // Total duration in milliseconds
  function ToTotalMilliseconds(d: Duration): int
    requires IsValid(d)
  {
    d.seconds * MILLIS_PER_SECOND +
    d.millis
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
  function GetMilliseconds(d: Duration): int { d.millis }

  // Check if one duration is strictly less than another
  function Less(d1: Duration, d2: Duration): bool
    requires IsValid(d1) && IsValid(d2)
  {
    ToTotalMilliseconds(d1) < ToTotalMilliseconds(d2)
  }

  // Maximum of two durations
  function Max(d1: Duration, d2: Duration): Duration
    requires IsValid(d1) && IsValid(d2)
    ensures IsValid(Max(d1, d2))
  {
    if Less(d1, d2) then d2 else d1
  }

  // Minimum of two durations
  function Min(d1: Duration, d2: Duration): Duration
    requires IsValid(d1) && IsValid(d2)
    ensures IsValid(Min(d1, d2))
  {
    if Less(d1, d2) then d1 else d2
  }

  // Maximum of a non-empty sequence of durations
  function Max(durs: seq<Duration>): Duration
    requires |durs| > 0
    requires forall d :: d in durs ==> IsValid(d)
    ensures IsValid(Max(durs))
  {
    if |durs| == 1 then
      durs[0]
    else
      var restMax := Max(durs[1..]);
      if Less(durs[0], restMax) then restMax else durs[0]
  }

  // Minimum of a non-empty sequence of durations
  function Min(durs: seq<Duration>): Duration
    requires |durs| > 0
    requires forall d :: d in durs ==> IsValid(d)
    ensures IsValid(Min(durs))
  {
    if |durs| == 1 then
      durs[0]
    else
      var restMin := Min(durs[1..]);
      if Less(durs[0], restMin) then durs[0] else restMin
  }

 }
