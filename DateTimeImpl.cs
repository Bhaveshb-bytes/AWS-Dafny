using System;
using System.Linq;
using System.Numerics;
using Dafny;

public static class DateTimeImpl
{
    public static ISequence<uint> GetNowComponents()
    {
        var now = DateTime.Now;
        var components = new uint[]
        {
            (uint)now.Year,
            (uint)now.Month,
            (uint)now.Day,
            (uint)now.Hour,
            (uint)now.Minute,
            (uint)now.Second,
            (uint)now.Millisecond,
        };

        return Sequence<uint>.FromArray(components);
    }

    public static BigInteger ToEpochTimeMilliseconds(
        uint year,
        uint month,
        uint day,
        uint hour,
        uint minute,
        uint second,
        uint millisecond,
        TimeSpan? offset = null
    )
    {
        return new DateTimeOffset(
            (int)year,
            (int)month,
            (int)day,
            (int)hour,
            (int)minute,
            (int)second,
            (int)millisecond,
            offset ?? TimeSpan.Zero
        ).ToUnixTimeMilliseconds();
    }

    public static ISequence<uint> FromEpochTimeMilliseconds(
        BigInteger epochMilliseconds,
        TimeSpan? offset = null
    )
    {
        DateTimeOffset dateTimeOffset = DateTimeOffset
            .FromUnixTimeMilliseconds((long)epochMilliseconds)
            .ToOffset(offset ?? TimeSpan.Zero);
        var components = new uint[]
        {
            (uint)dateTimeOffset.Year,
            (uint)dateTimeOffset.Month,
            (uint)dateTimeOffset.Day,
            (uint)dateTimeOffset.Hour,
            (uint)dateTimeOffset.Minute,
            (uint)dateTimeOffset.Second,
            (uint)dateTimeOffset.Millisecond,
        };
        return Sequence<uint>.FromArray(components);
    }

    public static bool IsLeapYear(BigInteger year)
    {
        return DateTime.IsLeapYear((int)year);
    }
}
