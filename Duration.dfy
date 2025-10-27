
 /*
 include "DateTimeConstant.dfy"

module Duration {
  import opened DateTimeConstant
  import opened Std.Strings
  import opened Std.Collections.Seq
  import opened Std.BoundedInts
  datatype Duration = Duration(
    seconds: uint32, 
    millis: uint32     
  )

  function EpochDifference(epoch1: uint16, epoch2: uint16): Duration
      requires epoch1 >= 0 && epoch2 >= 0
    {
      // absolute difference in milliseconds
      var diff := if epoch1 >= epoch2 then epoch1 - epoch2 else epoch2 - epoch1;

      // break into seconds and remaining millis
      var secs  := (diff / MILLISECONDS_PER_SECOND) as uint32;
      var remMs := (diff % MILLISECONDS_PER_SECOND) as uint32;

      Duration(secs, remMs)
    }


  // Total duration in milliseconds
  function ToTotalMilliseconds(d: Duration): uint32
  {
    (d.seconds as uint32) * (MILLISECONDS_PER_SECOND as uint32) +
    d.millis
  }

  // Build Duration from milliseconds
  function FromMilliseconds(ms: uint32): Duration
    {
      var seconds := (ms / (MILLISECONDS_PER_SECOND as uint32)) as uint32;
      var milliseconds := (ms % (MILLISECONDS_PER_SECOND as uint32)) as uint32;

      Duration(seconds, milliseconds)
    }


  // Comparison (-1 if d1 < d2, 0 if equal, 1 if greater)
  function Compare(d1: Duration, d2: Duration): int
  {
    if ToTotalMilliseconds(d1) < ToTotalMilliseconds(d2) then -1
    else if ToTotalMilliseconds(d1) > ToTotalMilliseconds(d2) then 1
    else 0
  }

  // Addition
  function Plus(d1: Duration, d2: Duration): Duration
  {
    FromMilliseconds(ToTotalMilliseconds(d1) + ToTotalMilliseconds(d2))
  }

  // Subtraction
  function Minus(d1: Duration, d2: Duration): Duration
  {
    FromMilliseconds(ToTotalMilliseconds(d1) - ToTotalMilliseconds(d2))
  }

  function GetSeconds(d: Duration): uint32 { d.seconds }
  function GetMilliseconds(d: Duration): uint32 { d.millis }

  // Check if one duration is strictly less than another
  function Less(d1: Duration, d2: Duration): bool
  {
    ToTotalMilliseconds(d1) < ToTotalMilliseconds(d2)
  }

  // Maximum of two durations
  function Max(d1: Duration, d2: Duration): Duration
  {
    if Less(d1, d2) then d2 else d1
  }

  // Minimum of two durations
  function Min(d1: Duration, d2: Duration): Duration
  {
    if Less(d1, d2) then d1 else d2
  }

  // Maximum of a non-empty sequence of durations
  function MaxSeq(durs: seq<Duration>): Duration
    requires |durs| > 0
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
  {
    if |durs| == 1 then
      durs[0]
    else
      var restMin := MinSeq(durs[1..]);
      if Less(durs[0], restMin) then durs[0] else restMin
  }


  function Scale(d: Duration, factor: uint32): Duration
    requires factor >= 0
  {
    FromMilliseconds(ToTotalMilliseconds(d) * factor)
  }

  function Divide(d: Duration, divisor: uint32): Duration
    requires divisor > 0
  {
    FromMilliseconds(ToTotalMilliseconds(d) / divisor)
  }


  function Mod(d1: Duration, d2: Duration): Duration
    requires ToTotalMilliseconds(d2) > 0
  {
    FromMilliseconds(ToTotalMilliseconds(d1) % ToTotalMilliseconds(d2))
  }

  function ToTotalSeconds(d: Duration): uint32
  {
    d.seconds + (d.millis / (MILLISECONDS_PER_SECOND as uint32))
  }

  function ToTotalMinutes(d: Duration): uint32
  {
    ToTotalMilliseconds(d) / (MILLISECONDS_PER_MINUTE as uint32)
  }

  function ToTotalHours(d: Duration): uint32
  {
    ToTotalMilliseconds(d) / MILLISECONDS_PER_HOUR
  }

  function ToTotalDays(d: Duration): uint32
  {
    ToTotalMilliseconds(d) / MILLISECONDS_PER_DAY
  }



  function FromSeconds(s: uint32): Duration
  {
    FromMilliseconds(s * (MILLISECONDS_PER_SECOND as uint32))
  }

  function FromMinutes(m: uint32): Duration
  {
    FromMilliseconds(m * (MILLISECONDS_PER_MINUTE as uint32))
  }

  function FromHours(h: uint32): Duration
  {
    FromMilliseconds(h * MILLISECONDS_PER_HOUR)
  }

  function FromDays(d: uint32): Duration
  {
    FromMilliseconds(d * MILLISECONDS_PER_DAY)
  }

  //PT9605H30M Simplified Parsing to Hours and Minutes
  function ToString(d: Duration): string
      requires d.seconds >= 0 && d.millis >= 0 && d.millis < 1000
    {
      var total_seconds := d.seconds;
      var hours := (total_seconds / (SECONDS_PER_HOUR as uint32)) as int;
      var minutes := ((total_seconds % (SECONDS_PER_HOUR as uint32)) / (SECONDS_PER_MINUTE as uint32)) as int;
      "PT" + OfInt(hours) + "H" + OfInt(minutes) + "M"
    }
  //PT9650H30M45.123S s: seq<char>




  function ParseString(text: string): Duration
    requires text[0..2] == "PT"  // must start with PT
    ensures 0 <= ParseString(text).millis < 1000
  {

    var len := |text|;
    var hPos := match IndexOfOption(text, 'H') case Some(i) => i as int case None => -1;
    var mPos := match IndexOfOption(text, 'M') case Some(i) => i as int case None => -1;
    var dotPos := match IndexOfOption(text, '.') case Some(i) => i as int case None => -1;

    // Extract substrings between markers
    var hourStr := text[2..hPos];
    var minuteStr :=  text[hPos + 1 .. mPos];
    var secondStr := text[mPos + 1 .. dotPos];
    var millisecondStr := text[dotPos + 1 .. len];

    // Convert to integers
    var hour := (ToInt(hourStr)) as uint32;
    var minute := (ToInt(minuteStr)) as uint32;
    var second := (ToInt(secondStr)) as uint32;
    var millisecond := (ToInt(millisecondStr)) as uint32;

    // Compute total seconds and construct duration
    var totalSeconds := hour * (SECONDS_PER_HOUR as uint32) + minute * (SECONDS_PER_MINUTE as uint32) + second;
    Duration(totalSeconds, millisecond)
  }


  //build command: dafny build TestDuration.dfy --standard-libraries
}*/
include "DateTimeConstant.dfy"

module Duration {
  import opened DateTimeConstant
  import opened Std.Strings
  import opened Std.Collections.Seq
  import opened Std.BoundedInts
  datatype Duration = Duration(
    seconds: uint32, 
    millis: uint32     
  )

  function EpochDifference(epoch1: uint16, epoch2: uint16): Duration
      requires epoch1 >= 0 && epoch2 >= 0
    {
      // absolute difference in milliseconds
      var diff := if epoch1 >= epoch2 then epoch1 - epoch2 else epoch2 - epoch1;

      // break into seconds and remaining millis
      var secs  := (diff / MILLISECONDS_PER_SECOND) as uint32;
      var remMs := (diff % MILLISECONDS_PER_SECOND) as uint32;

      Duration(secs, remMs)
    }


  // Total duration in milliseconds
  function ToTotalMilliseconds(d: Duration): uint32
  {
    (d.seconds as uint32) * (MILLISECONDS_PER_SECOND as uint32) +
    d.millis
  }

  // Build Duration from milliseconds
  function FromMilliseconds(ms: uint32): Duration
    {
      var seconds := (ms / (MILLISECONDS_PER_SECOND as uint32)) as uint32;
      var milliseconds := (ms % (MILLISECONDS_PER_SECOND as uint32)) as uint32;

      Duration(seconds, milliseconds)
    }


  // Comparison (-1 if d1 < d2, 0 if equal, 1 if greater)
  function Compare(d1: Duration, d2: Duration): int
  {
    if ToTotalMilliseconds(d1) < ToTotalMilliseconds(d2) then -1
    else if ToTotalMilliseconds(d1) > ToTotalMilliseconds(d2) then 1
    else 0
  }

  // Addition
  function Plus(d1: Duration, d2: Duration): Duration
  {
    FromMilliseconds(ToTotalMilliseconds(d1) + ToTotalMilliseconds(d2))
  }

  // Subtraction
  function Minus(d1: Duration, d2: Duration): Duration
  {
    FromMilliseconds(ToTotalMilliseconds(d1) - ToTotalMilliseconds(d2))
  }

  function GetSeconds(d: Duration): uint32 { d.seconds }
  function GetMilliseconds(d: Duration): uint32 { d.millis }

  // Check if one duration is strictly less than another
  function Less(d1: Duration, d2: Duration): bool
  {
    ToTotalMilliseconds(d1) < ToTotalMilliseconds(d2)
  }

  // Maximum of two durations
  function Max(d1: Duration, d2: Duration): Duration
  {
    if Less(d1, d2) then d2 else d1
  }

  // Minimum of two durations
  function Min(d1: Duration, d2: Duration): Duration
  {
    if Less(d1, d2) then d1 else d2
  }

  // Maximum of a non-empty sequence of durations
  function MaxSeq(durs: seq<Duration>): Duration
    requires |durs| > 0
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
  {
    if |durs| == 1 then
      durs[0]
    else
      var restMin := MinSeq(durs[1..]);
      if Less(durs[0], restMin) then durs[0] else restMin
  }


  function Scale(d: Duration, factor: uint32): Duration
    requires factor >= 0
  {
    FromMilliseconds(ToTotalMilliseconds(d) * factor)
  }

  function Divide(d: Duration, divisor: uint32): Duration
    requires divisor > 0
  {
    FromMilliseconds(ToTotalMilliseconds(d) / divisor)
  }


  function Mod(d1: Duration, d2: Duration): Duration
    requires ToTotalMilliseconds(d2) > 0
  {
    FromMilliseconds(ToTotalMilliseconds(d1) % ToTotalMilliseconds(d2))
  }

  function ToTotalSeconds(d: Duration): uint32
  {
    d.seconds + (d.millis / (MILLISECONDS_PER_SECOND as uint32))
  }

  function ToTotalMinutes(d: Duration): uint32
  {
    ToTotalMilliseconds(d) / (MILLISECONDS_PER_MINUTE as uint32)
  }

  function ToTotalHours(d: Duration): uint32
  {
    ToTotalMilliseconds(d) / MILLISECONDS_PER_HOUR
  }

  function ToTotalDays(d: Duration): uint32
  {
    ToTotalMilliseconds(d) / MILLISECONDS_PER_DAY
  }



  function FromSeconds(s: uint32): Duration
  {
    FromMilliseconds(s * (MILLISECONDS_PER_SECOND as uint32))
  }

  function FromMinutes(m: uint32): Duration
  {
    FromMilliseconds(m * (MILLISECONDS_PER_MINUTE as uint32))
  }

  function FromHours(h: uint32): Duration
  {
    FromMilliseconds(h * MILLISECONDS_PER_HOUR)
  }

  function FromDays(d: uint32): Duration
  {
    FromMilliseconds(d * MILLISECONDS_PER_DAY)
  }

  //PT9605H30M Simplified Parsing to Hours and Minutes
  function ToString(d: Duration): string
      requires d.seconds >= 0 && d.millis >= 0 && d.millis < 1000
    {
      var total_seconds := d.seconds;
      var hours := (total_seconds / (SECONDS_PER_HOUR as uint32)) as int;
      var minutes := ((total_seconds % (SECONDS_PER_HOUR as uint32)) / (SECONDS_PER_MINUTE as uint32)) as int;
      "PT" + OfInt(hours) + "H" + OfInt(minutes) + "M"
    }
  //PT9650H30M45.123S s: seq<char>




  function ParseString(text: string): Duration
    requires text[0..2] == "PT"  // must start with PT
    ensures 0 <= ParseString(text).millis < 1000
  {
    var len := |text|;
    var hPos := match IndexOfOption(text, 'H') case Some(i) => i as int case None => -1;
    var mPos := match IndexOfOption(text, 'M') case Some(i) => i as int case None => -1;
    var sPos := match IndexOfOption(text, 'S') case Some(i) => i as int case None => -1;
    var dotPos := match IndexOfOption(text, '.') case Some(i) => i as int case None => -1;

    // Extract hour
    var hour : uint32 := if hPos > 2 then (ToInt(text[2..hPos])) as uint32 else 0;

    // Extract minute
    var minuteStart := if hPos >= 0 then hPos + 1 else 2;
    var minute : uint32 := if mPos > 0 then (ToInt(text[minuteStart..mPos])) as uint32 else 0;

    // Extract second and millisecond
    var secondStart := if mPos >= 0 then mPos + 1 else 2;
    
    var second : uint32 := if sPos > 0 && dotPos > 0 && dotPos > secondStart 
                           then (ToInt(text[secondStart..dotPos])) as uint32
                           else if sPos > 0 && sPos > secondStart 
                                then (ToInt(text[secondStart..sPos])) as uint32
                                else 0;
    
    var milliStr := if sPos > 0 && dotPos > 0 && dotPos > secondStart then text[dotPos + 1..sPos] else "";
    var millisecond : uint32 := if |milliStr| > 0 then (ToInt(milliStr)) as uint32 else 0;

    // Compute total seconds and construct duration
    var totalSeconds := hour * (SECONDS_PER_HOUR as uint32) + minute * (SECONDS_PER_MINUTE as uint32) + second;
    Duration(totalSeconds, millisecond)
  }


  //build command: dafny build TestDuration.dfy --standard-libraries
}