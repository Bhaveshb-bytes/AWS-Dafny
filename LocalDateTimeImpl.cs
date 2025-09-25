using System;
using System.Linq;
using Dafny;

public static class LocalDateTimeImpl
{
    public static ISequence<Rune> NowComponents()
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
}