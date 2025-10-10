# AWS-Dafny
Current Design of DateTime API

Regarding the "absence of leap years every 4000 years," I checked how major programming languages determine leap years and found that none of them use the 4000-year rule. I think we can ignore this very rare rule.

The date calculation logic is now based on epoch time, so we have already avoided a lot of unnecessarily complex date-handling logic.

The new logic first converts the LocalDateTime to an epoch time in milliseconds. It also converts the time to be added or subtracted into milliseconds. Then, it performs the addition or subtraction. Finally, it converts the resulting millisecond time back to a LocalDateTime.

## How to execute the test example

```
dafny build TestLocalDateTime.dfy --target:cs TestLocalDateTime.dfy DateTimeImpl.cs --standard-libraries

./TestLocalDateTime
```

Current Design of Duration API

The file defines a Duration module that implements a robust set of time duration utilities in Dafny.
It models durations data structure and provides:
Arithmetic operations (add, subtract, scale, divide)
Comparisons (less than, max, min)
Conversions between time units (milliseconds, seconds, minutes, hours, days)
String formatting and parsing for simplified ISO-8601–like time strings (e.g. "PT9650H30M")
Helper functions for sequence scanning (like StringIndexOf)
## How to execute Duration Test Sample

```
dafny build TestDuration.dfy --standard-libraries
./TestLocalDateTime
```
