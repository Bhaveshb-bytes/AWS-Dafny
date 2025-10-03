include "LocalDateTime.dfy"
include "Duration.dfy"
include "DateTimeUtils.dfy"

module Std.DateTime.ZonedDateTime {
    import LDT = Std.DateTime.LocalDateTime
    import Duration
    import DTUtils = DateTimeUtils

    // DST status
    // 0 - unique: only one valid offset
    // 1 - overlap: two valid offsets
    // 2 - gap: no valid offset, need to shift forward
    type Status = int
    const STATUS_UNIQUE: Status := 0
    const STATUS_OVERLAP: Status := 1
    const STATUS_GAP: Status := 2

    // Preference for resolving local date-time in overlap or gap
    // -1: prefer earlier offset in overlap
    //  1: prefer later offset in overlap
    //  0: shift forward in gap
    type Preference = int
    const PREFER_EARLIER: Preference := -1
    const PREFER_LATER:   Preference :=  1
    const SHIFT_FORWARD:  Preference :=  0

    // Core structure of ZonedDateTime
    datatype ZonedDateTime = ZonedDateTime(
        local: LDT.LocalDateTime,
        zoneId: string,
        offsetMinutes: int  // offset in minutes from UTC
    )

    // Invariant: valid local date-time, valid offset (-18h to +18h), non-empty zone ID
    predicate IsValidZonedDateTime(zd: ZonedDateTime)
    {
        LDT.IsValidLocalDateTime(zd.local) &&
        -18*60 <= zd.offsetMinutes <= 18*60 &&
        |zd.zoneId| > 0
    }

    // Create a ZonedDateTime from components, resolving local date-time with preference
    method {:extern "ZonedDateTimeImpl", "ResolveLocal"} {:axiom} ResolveLocalImpl(zoneId: string,
                    year: int, month: int, day: int, hour: int, minute: int, second: int, millisecond: int,
                    preference: int)
            returns (payload: seq<char>)
            ensures |payload| == 9

    // Helper method to create ZonedDateTime from components
    method {:extern "ZonedDateTimeImpl", "NowZoned"} {:axiom} NowZonedImpl() 
        returns (offsetMinutes: int, 
                year: int, month: int, day: int, hour: int, minute: int, second: int, ms: int, 
                zoneId: string)

    // Create ZonedDateTime from components
    method NowZoned() returns (result: ZonedDateTime)
        ensures IsValidZonedDateTime(result)
    {
        var (off, y, m, d, hh, mm, ss, ms, zid) := NowZonedImpl();
        var local := LDT.LocalDateTime(y, m, d, hh, mm, ss, ms);
        result := ZonedDateTime(local, zid, off);
    }

    // Creation function with preference for resolving local date-time
    method OfLocal(zoneId: string, local: LDT.LocalDateTime, preference: Preference) 
        returns (result: LDT.Result<ZonedDateTime, string>, status: Status)
        requires LDT.IsValidLocalDateTime(local)
        ensures result.Success? ==> IsValid(result.value)
}