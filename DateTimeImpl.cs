using System;
using System.Linq;
using System.Numerics;
using Dafny;

public static class DateTimeImpl
{
    public static ISequence<Rune> GetNowComponents()
    {
        var now = DateTime.Now;
        var components = new[] {
            now.Year,
            now.Month,
            now.Day,
            now.Hour,
            now.Minute,
            now.Second,
            now.Millisecond
        };

        // Convert to sequence of integers as runes
        var runes = components.Select(i => new Rune(i)).ToArray();
        return Sequence<Rune>.FromArray(runes);
    }

    public static BigInteger ToEpochTimeMilliseconds(BigInteger year, BigInteger month, BigInteger day, BigInteger hour, BigInteger minute, BigInteger second, BigInteger millisecond, TimeSpan? offset = null)
    {
        return new DateTimeOffset((int)year, (int)month, (int)day, (int)hour, (int)minute, (int)second, (int)millisecond, offset ?? TimeSpan.Zero)
            .ToUnixTimeMilliseconds();
    }

    public static ISequence<BigInteger> FromEpochTimeMilliseconds(BigInteger epochMilliseconds, TimeSpan? offset = null)
    {
        DateTimeOffset dateTimeOffset = DateTimeOffset.FromUnixTimeMilliseconds((long)epochMilliseconds)
            .ToOffset(offset ?? TimeSpan.Zero);
        var components = new BigInteger[]
        {
            dateTimeOffset.Year,
            dateTimeOffset.Month,
            dateTimeOffset.Day,
            dateTimeOffset.Hour,
            dateTimeOffset.Minute,
            dateTimeOffset.Second,
            dateTimeOffset.Millisecond
        };
        return Sequence<BigInteger>.FromArray(components);
    }

    public static bool IsLeapYear(BigInteger year)
    {
        return DateTime.IsLeapYear((int)year);
    }
}