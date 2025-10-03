using System;
using System.Globalization;
using System.Linq;
using Dafny;

static class Pack
{
    public static ISequence<Rune> Ints(params int[] xs) =>
        Sequence<Rune>.FromArray(xs.Select(i => new Rune(i)).ToArray());
    public static ISequence<char> Str(string s) =>
        Sequence<char>.FromString(s);
}


public static class ZonedDateTimeImpl
{
    static TimeZoneInfo GetTz(string zoneId)
    {
        // If zoneId is null or empty, use the local time zone
        if (string.IsNullOrEmpty(zoneId)) return TimeZoneInfo.Local;
        return TimeZoneInfo.FindSystemTimeZoneById(zoneId);
    }

    public static ISequence<Rune> ResolveLocal(
        ISequence<char> zoneIdSeq,
        int year, int month, int day, int hour, int minute, int second, int millisecond,
        int preference)
    {
        string zoneId = new string(zoneIdSeq.Elements);
        var tz = GetTz(zoneId);

        var local = new DateTime(year, month, day, hour, minute, second, millisecond, DateTimeKind.Unspecified);

        // Check if the time is INVALID (does not exist, e.g., during spring DST transition)
        if (tz.IsInvalidTime(local))
        {
            if (preference == 0 /* SHIFT_FORWARD */)
            {
                // Shift forward to the next valid time
                DateTime probe = local;
                while (tz.IsInvalidTime(probe))
                    probe = probe.AddMinutes(1);

                var offset = tz.GetUtcOffset(probe);
                return Pack.Ints(
                    2 /* GAP */,
                    (int)offset.TotalMinutes,
                    probe.Year, probe.Month, probe.Day,
                    probe.Hour, probe.Minute, probe.Second, probe.Millisecond
                );
            }
            {
                DateTime probe = local.AddMinutes(1);
                while (tz.IsInvalidTime(probe))
                    probe = probe.AddMinutes(1);

                var offset = tz.GetUtcOffset(probe);
                return Pack.Ints(
                    2 /* GAP */,
                    (int)offset.TotalMinutes,
                    probe.Year, probe.Month, probe.Day,
                    probe.Hour, probe.Minute, probe.Second, probe.Millisecond
                );
            }
        }

        // It's a valid time
        // Check if the time is OVERLAP 
        // (there are two possible times if clocks were set back during DST transition)
        if (tz.IsAmbiguousTime(local))
        {
            var offsets = tz.GetAmbiguousTimeOffsets(local);

            var chosen = preference < 0 ? offsets.MinBy(o => o)  // PreferEarlier: choose the earlier offset
                        : offsets.MaxBy(o => o); // PreferLater: choose the later offset

            // Return the chosen offset and the local time   
            var dto = new DateTimeOffset(local, chosen);
            var norm = dto.LocalDateTime;
            return Pack.Ints(
                1 /* OVERLAP */,
                (int)chosen.TotalMinutes,
                norm.Year, norm.Month, norm.Day,
                norm.Hour, norm.Minute, norm.Second, norm.Millisecond
            );
        }

        // Normal case (UNIQUE): just return the offset and the local time
        var offsetNormal = tz.GetUtcOffset(local);
        return Pack.Ints(
            0 /* NORMAL */,
            (int)offsetNormal.TotalMinutes,
            local.Year, local.Month, local.Day,
            local.Hour, local.Minute, local.Second, local.Millisecond
        );
    }

    public static (int,int,int,int,int,int,int,int,ISequence<char>) NowZoned()
    {
        var now = DateTimeOffset.Now; // includes offset
        var zid = TimeZoneInfo.Local.Id;
        return ( (int)now.Offset.TotalMinutes,
                 now.Year, now.Month, now.Day,
                 now.Hour, now.Minute, now.Second, now.Millisecond,
                 Pack.Str(zid) );
    }
}