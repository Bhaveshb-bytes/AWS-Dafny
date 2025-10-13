using System;
using System.Globalization;
using System.Linq;
using System.Numerics;
using Dafny;

static class Pack
{
    public static ISequence<BigInteger> Ints(params BigInteger[] xs) =>
        Sequence<BigInteger>.FromArray(xs);
    public static ISequence<Rune> Str(string s) =>
        Sequence<Rune>.FromArray(s.EnumerateRunes().Select(r => new Rune(r.Value)).ToArray());
}


public static class ZonedDateTimeImpl
{
    static TimeZoneInfo GetTz(string zoneId)
    {
        // If zoneId is null or empty, use the local time zone
        if (string.IsNullOrEmpty(zoneId)) return TimeZoneInfo.Local;
        return TimeZoneInfo.FindSystemTimeZoneById(zoneId);
    }

    public static ISequence<BigInteger> ResolveLocal(
        ISequence<Rune> zoneIdSeq,
        BigInteger year, BigInteger month, BigInteger day,
        BigInteger hour, BigInteger minute, BigInteger second, BigInteger millisecond,
        BigInteger preference)
    {
        string zoneId = new string(zoneIdSeq.Elements.Select(r => (char)r.Value).ToArray());
        var tz = GetTz(zoneId);

        var local = new DateTime((int)year, (int)month, (int)day,
                                 (int)hour, (int)minute, (int)second, (int)millisecond,
                                 (int)DateTimeKind.Unspecified);

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
                var components = new BigInteger[]
                {
                    2 /* GAP */,
                    (int)offset.TotalMinutes,
                    probe.Year, probe.Month, probe.Day,
                    probe.Hour, probe.Minute, probe.Second, probe.Millisecond
                };
                return Pack.Ints(components);
            }
            {
                DateTime probe = local.AddMinutes(1);
                while (tz.IsInvalidTime(probe))
                    probe = probe.AddMinutes(1);

                var offset = tz.GetUtcOffset(probe);
                var components = new BigInteger[]
                {
                    2 /* GAP */,
                    (int)offset.TotalMinutes,
                    probe.Year, probe.Month, probe.Day,
                    probe.Hour, probe.Minute, probe.Second, probe.Millisecond
                };
                return Pack.Ints(components);
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
            var components = new BigInteger[]
            {
                1 /* OVERLAP */,
                (int)chosen.TotalMinutes,
                norm.Year, norm.Month, norm.Day,
                norm.Hour, norm.Minute, norm.Second, norm.Millisecond
            };
            return Pack.Ints(components);
        }

        // Normal case (UNIQUE): just return the offset and the local time
        var offsetNormal = tz.GetUtcOffset(local);
        var componentsNormal = new BigInteger[]
        {
            0 /* NORMAL */,
            (int)offsetNormal.TotalMinutes,
            local.Year, local.Month, local.Day,
            local.Hour, local.Minute, local.Second, local.Millisecond
        };
        return Pack.Ints(componentsNormal);
    }

    public static ISequence<BigInteger> NowZoned()
    {
        var now = DateTimeOffset.Now; // includes offset
        var components = new BigInteger[] {
            (int)now.Offset.TotalMinutes,
            now.Year,
            now.Month,
            now.Day,
            now.Hour,
            now.Minute,
            now.Second,
            now.Millisecond
        };
        // var runes = components.Select(i => new Rune(i)).ToArray();
        return Sequence<BigInteger>.FromArray(components);
    }
    
    public static ISequence<Rune> GetNowZoneId()
    {
        var zid = TimeZoneInfo.Local.Id;
        return Pack.Str(zid);
    }
}
