include "DateTimeConstant.dfy"

module Duration {
  import opened DateTimeConstant
  import opened Std.Strings
 // import DTUtils = DateTimeUtils
  datatype Duration = Duration(
    seconds: int,   // 0 <= seconds < 9999year * seconds per day
    millis: int     // 0 <= millis < 1000
  )

 function EpochDifference(epoch1: int, epoch2: int): Duration
      requires epoch1 >= 0 && epoch2 >= 0
 //     ensures IsValid(EpochDifference(epoch1, epoch2))
    {
      // absolute difference in milliseconds
      var diff := if epoch1 >= epoch2 then epoch1 - epoch2 else epoch2 - epoch1;

      // break into seconds and remaining millis
      var secs  := diff / MILLISECONDS_PER_SECOND;
      var remMs := diff % MILLISECONDS_PER_SECOND;

      Duration(secs, remMs)
    }
  predicate IsValid(d: Duration) {
    0 <= d.seconds < MAX_SECONDS_PER_YEAR &&
    0 <= d.millis < MILLISECONDS_PER_SECOND
  }

  // Total duration in milliseconds
  function ToTotalMilliseconds(d: Duration): int
  {
    d.seconds * MILLISECONDS_PER_SECOND +
    d.millis
  }

    // Build Duration from milliseconds
   function FromMilliseconds(ms: int): Duration
 //     ensures IsValid(FromMilliseconds(ms))
    {

      var seconds := ms / MILLISECONDS_PER_SECOND;
      var milliseconds := ms % MILLISECONDS_PER_SECOND;

      Duration(seconds, milliseconds)
    }
  // Equality
  function Equal(d1: Duration, d2: Duration): bool
 //   requires IsValid(d1) && IsValid(d2)
  {
    ToTotalMilliseconds(d1) == ToTotalMilliseconds(d2)
  }

  // Comparison (-1 if d1 < d2, 0 if equal, 1 if greater)
  function Compare(d1: Duration, d2: Duration): int
 //   requires IsValid(d1) && IsValid(d2)
  {
    if ToTotalMilliseconds(d1) < ToTotalMilliseconds(d2) then -1
    else if ToTotalMilliseconds(d1) > ToTotalMilliseconds(d2) then 1
    else 0
  }

  // Addition
  function Plus(d1: Duration, d2: Duration): Duration
 //   requires IsValid(d1) && IsValid(d2)
 //   ensures IsValid(Plus(d1, d2))
  {
    FromMilliseconds(ToTotalMilliseconds(d1) + ToTotalMilliseconds(d2))
  }

  // Subtraction
  function Minus(d1: Duration, d2: Duration): Duration
  //  requires IsValid(d1) && IsValid(d2)
  //  ensures IsValid(Minus(d1, d2))
  {
    FromMilliseconds(ToTotalMilliseconds(d1) - ToTotalMilliseconds(d2))
  }
  function GetSeconds(d: Duration): int { d.seconds }
  function GetMilliseconds(d: Duration): int { d.millis }

  // Check if one duration is strictly less than another
  function Less(d1: Duration, d2: Duration): bool
  //  requires IsValid(d1) && IsValid(d2)
  {
    ToTotalMilliseconds(d1) < ToTotalMilliseconds(d2)
  }

  // Maximum of two durations
  function Max(d1: Duration, d2: Duration): Duration
  //  requires IsValid(d1) && IsValid(d2)
  //  ensures IsValid(Max(d1, d2))
  {
    if Less(d1, d2) then d2 else d1
  }

  // Minimum of two durations
  function Min(d1: Duration, d2: Duration): Duration
  //  requires IsValid(d1) && IsValid(d2)
  //  ensures IsValid(Min(d1, d2))
  {
    if Less(d1, d2) then d1 else d2
  }

  // Maximum of a non-empty sequence of durations
  function MaxSeq(durs: seq<Duration>): Duration
    requires |durs| > 0
  //  requires forall d :: d in durs ==> IsValid(d)
  //  ensures IsValid(MaxSeq(durs))
  {
    if |durs| == 1 then
      durs[0]
    else
      var restMax := MaxSeq(durs[1..]);
      if Less(durs[0], restMax) then restMax else durs[0]
  }

  // Minimum of a non-empty sequence of durations
  function MinSeq(durs: seq<Duration>): Duration
    requires |durs| > 0
  //  requires forall d :: d in durs ==> IsValid(d)
    ensures IsValid(MinSeq(durs))
  {
    if |durs| == 1 then
      durs[0]
    else
      var restMin := MinSeq(durs[1..]);
      if Less(durs[0], restMin) then durs[0] else restMin
  }


function Scale(d: Duration, factor: int): Duration
 // requires IsValid(d)
  requires factor >= 0
 // ensures IsValid(Scale(d, factor))
{
  FromMilliseconds(ToTotalMilliseconds(d) * factor)
}

function Divide(d: Duration, divisor: int): Duration
 // requires IsValid(d)
  requires divisor > 0
 // ensures IsValid(Divide(d, divisor))
{
  FromMilliseconds(ToTotalMilliseconds(d) / divisor)
}


function Mod(d1: Duration, d2: Duration): Duration
  requires ToTotalMilliseconds(d2) > 0
 // ensures IsValid(Mod(d1, d2))
{
  FromMilliseconds(ToTotalMilliseconds(d1) % ToTotalMilliseconds(d2))
}

function ToTotalSeconds(d: Duration): int
//  requires IsValid(d)
{
  d.seconds + d.millis / MILLISECONDS_PER_SECOND
}

function ToTotalMinutes(d: Duration): int
//  requires IsValid(d)
{
  ToTotalMilliseconds(d) / MILLISECONDS_PER_MINUTE
}

function ToTotalHours(d: Duration): int
 // requires IsValid(d)
{
  ToTotalMilliseconds(d) / MILLISECONDS_PER_HOUR
}

function ToTotalDays(d: Duration): int
 // requires IsValid(d)
{
  ToTotalMilliseconds(d) / MILLISECONDS_PER_DAY
}



function FromSeconds(s: int): Duration
 // ensures IsValid(FromSeconds(s))
{
  FromMilliseconds(s * MILLISECONDS_PER_SECOND)
}

function FromMinutes(m: int): Duration
 // ensures IsValid(FromMinutes(m))
{
  FromMilliseconds(m *  MILLISECONDS_PER_MINUTE)
}

function FromHours(h: int): Duration
 // ensures IsValid(FromHours(h))
{
  FromMilliseconds(h * MILLISECONDS_PER_HOUR)
}

function FromDays(d: int): Duration
 // ensures IsValid(FromDays(d))
{
  FromMilliseconds(d * MILLISECONDS_PER_DAY)
}

//PT9605H30M Simplified Parsing to Hours and Minutes
function ToString(d: Duration): string
    requires d.seconds >= 0 && d.millis >= 0 && d.millis < 1000
  {
    var total_seconds := d.seconds;
    var hours := total_seconds / SECONDS_PER_HOUR;
    var minutes := (total_seconds % SECONDS_PER_HOUR) / SECONDS_PER_MINUTE;
    "PT" + OfInt(hours) + "H" + OfInt(minutes) + "M"
  }
//PT9650H30M45.123S
function SeqIndexOf(s: seq<char>, c: char): int
  ensures -1 <= SeqIndexOf(s, c) < |s|
{
  if |s| == 0 then -1
  else if s[0] == c then 0
  else
    var tail := SeqIndexOf(s[1..], c);
    if tail == -1 then -1 else tail + 1
}



function ParseString(text: string): Duration
  requires text[0..2] == "PT"  // must start with PT
  ensures 0 <= Parse(text).millis < 1000
{
  // Find positions of delimiters
  var hPos := SeqIndexOf(text, 'H');
  var mPos := SeqIndexOf(text, 'M');
  var dotPos := SeqIndexOf(text, '.');
  var sPos := SeqIndexOf(text, 'S');

  // Extract substrings between markers
  var hourStr := text[2..hPos];
  var minuteStr :=  text[hPos + 1 .. mPos];
  var secondStr := text[mPos + 1 .. dotPos];
  var millisecondStr := text[dotPos + 1 .. sPos];

  // Convert to integers
  var hour := ToInt(hourStr);
  var minute := ToInt(minuteStr);
  var second := ToInt(secondStr);
  var millisecond := ToInt(millisecondStr);

  // Compute total seconds and construct duration
  var totalSeconds := hour * SECONDS_PER_HOUR + minute * SECONDS_PER_MINUTE + second;
  Duration(totalSeconds, millisecond)
}

 function Parse(text: string): Duration
   requires |text| == 12 
 {
       var hourStr := text[0..2];
       var minuteStr := text[3..5];
       var secondStr := text[6..8];
       var millisecondStr := text[9..12];


       var hour := ToInt(hourStr);
       var minute := ToInt(minuteStr);
       var second := ToInt(secondStr);
       var millisecond := ToInt(millisecondStr);


       var totalSeconds := hour * SECONDS_PER_HOUR + minute * SECONDS_PER_MINUTE + second;
       Duration(totalSeconds, millisecond)

 }
//build command: dafny build TestDuration.dfy --standard-libraries
 }