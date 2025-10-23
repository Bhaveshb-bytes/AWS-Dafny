include "LocalDateTime.dfy"
include "Duration.dfy"
include "DateTimeUtils.dfy"

module ZonedDateTime {
    import opened Std.Wrappers
    import LDT = LocalDateTime
    import Duration

    // DST status
    // StatusUnique: only one valid offset
    // StatusOverlap: two valid offsets
    // StatusGap: no valid offset, need to shift forward
    datatype Status = StatusUnique | StatusOverlap | StatusGap

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
        0 < |zd.zoneId|
    }

    // Create a ZonedDateTime from components, resolving local date-time with preference
    function {:extern "ZonedDateTimeImpl", "ResolveLocal"} {:axiom} ResolveLocalImpl(zoneId: string,
                    year: int, month: int, day: int, hour: int, minute: int, second: int, millisecond: int,
                    preference: int) :seq<int>
        ensures |ResolveLocalImpl(zoneId, year, month, day, hour, minute, second, millisecond, preference)| == 9

    // Helper method to create ZonedDateTime from components
    function {:extern "ZonedDateTimeImpl", "NowZoned"} {:axiom} NowZonedImpl(): seq<int>
        ensures |NowZonedImpl()| == 8

    function {:extern "ZonedDateTimeImpl", "GetNowZoneId"} {:axiom} GetNowZoneIdImpl(): seq<char>
        ensures |GetNowZoneIdImpl()| > 0

    // Create ZonedDateTime from components
    function NowZoned(): Result<ZonedDateTime, string>
        ensures NowZoned().Success? ==> IsValidZonedDateTime(NowZoned().value)
    {
        var components := NowZonedImpl();
        if |components| == 8 then
            var off := components[0] as int;
            var year := components[1] as int;
            var month := components[2] as int;
            var day := components[3] as int;
            var hour := components[4] as int;
            var minute := components[5] as int;
            var second := components[6] as int;
            var millisecond := components[7] as int;
            var local := LDT.LocalDateTime(year, month, day, hour, minute, second, millisecond);
        
            var zid := GetNowZoneIdImpl();
            var zdt := ZonedDateTime(local, zid, off);
            if IsValidZonedDateTime(zdt) then
                Success(zdt)
            else
                Failure("Invalid ZonedDateTime created")
        else
            Failure("Failed to get current ZonedDateTime components")
    }

    // Creation function with preference for resolving local date-time
    function OfLocal(zoneId: string, local: LDT.LocalDateTime, preference: Preference): (Result<ZonedDateTime, string>, Status)
    {
        var p := ResolveLocalImpl(zoneId, local.year, local.month, local.day, local.hour, local.minute, local.second, local.millisecond, preference);
        
        var status' := 
            if p[0] as int == 0 then StatusUnique
            else if p[0] as int == 1 then StatusOverlap
            else StatusGap;
        var off     := p[1] as int;

        var ny := p[2] as int; var nm := p[3] as int; var nd := p[4] as int;
        var hh := p[5] as int; var mm := p[6] as int; var ss := p[7] as int; var ms := p[8] as int;

        var normLocal := LDT.LocalDateTime(ny, nm, nd, hh, mm, ss, ms);
        if !LDT.IsValidLocalDateTime(normLocal) then
            (Failure("Normalized local is invalid"), status')
        else
            (Success(ZonedDateTime(normLocal, zoneId, off)), status')
    }

}