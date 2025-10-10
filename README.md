# AWS-Dafny
Initial Design for Zoned Date Time. (Skeleton)

Using Dafny's {:extern} hook to interface with C#, enable C# to utilize .NET's TimeZoneInfo and DateTimeOffset to handle time zone rules + DST (Unique/Overlap/GAP), and return the "parsed/normalized" results back to Dafny.

The Zoned Date Time will have a datatype that stores the LocalDateTime datatype, a zoneId obtained from .NET's TimeZoneInfo, and an offsetMinutes obtained from .NET's DateTimeOffset. 

To resolve the local date time, we will first use the timezone from zoneId to determine the local date time is valid or not. If the local date time is not valid, it could be during spring DST transition. Therefore, we have to shift forward to the next valid time. If the local date time is ambiguous, we will choose either the earlier time or the later time based on the preference defined by the zoned date time.

Current Questions:

1.	Is ShiftForward the desired policy for Gap times, or rejection or a different normalization?
2.  For Overlap times, what should be our default preference (PreferEarlier vs PreferLater) if the caller doesn’t specify?
