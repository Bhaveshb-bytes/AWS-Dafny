# AWS-Dafny
Initial Design for Zoned Date Time. (Skeleton)

Using Dafny's {:extern} hook to interface with C#, enable C# to utilize .NET's TimeZoneInfo and DateTimeOffset to handle time zone rules + DST (Unique/Overlap/GAP), and return the "parsed/normalized" results back to Dafny.
