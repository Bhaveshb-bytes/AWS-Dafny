# AWS-Dafny
Current Design of DateTime API

In the current version, the calculation logic has changed. The new logic first converts the LocalDateTime to an epoch time in milliseconds. It also converts the time to be added or subtracted into milliseconds. Then, it performs the addition or subtraction. Finally, it converts the resulting millisecond time back to a LocalDateTime.

Because converting LocalDateTime to epoch time and back requires external functions, we cannot be certain about the correctness of the post-conditions of these external dependencies. Therefore, we cannot use assert to test the code. For now, we are using a print-based method for testing.

## How to execute the test example

```
dafny build TestLocalDateTimePrint.dfy --target:cs TestLocalDateTimePrint.dfy DateTimeImpl.cs --standard-libraries

./TestLocalDateTimePrint
```