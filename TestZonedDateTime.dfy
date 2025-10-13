include "LocalDateTime.dfy"
include "Duration.dfy"
include "DateTimeUtils.dfy"
include "DateTimeConstant.dfy"
include "ZonedDateTime.dfy"

module TestZonedDateTime {
    import LDT = LocalDateTime
    import Duration = Duration
    import DTUtils = DateTimeUtils
    import ZDT = ZonedDateTime

    method TestNowZoned() {
        print "=== TestNowZoned ===\n";
        var result := ZDT.NowZoned();
        var zdt := ZDT.NowZoned();
        PrintResult(zdt);
        print "\n";
        assert result.Success? ==> ZDT.IsValidZonedDateTime(result.value);
    }

    method PrintStatus(s: ZDT.Status)
    {
        if s == ZDT.STATUS_UNIQUE   { print "Status=UNIQUE (0)\n"; }
        else if s == ZDT.STATUS_OVERLAP { print "Status=OVERLAP (1)\n"; }
        else if s == ZDT.STATUS_GAP { print "Status=GAP (2)\n"; }
        else { print "Status=UNKNOWN\n"; }
    }

    method PrintResult(r: ZDT.Result<ZDT.ZonedDateTime, string>)
    {
        if r.Success? {
            var z := r.value;
            print "Result=Success\n";
            print "  zoneId=", z.zoneId, "\n";
            print "  offsetMinutes=", z.offsetMinutes, "\n";
            print "  local=",
            z.local.year, "-", z.local.month, "-", z.local.day, " ",
            z.local.hour, ":", z.local.minute, ":", z.local.second, ".", z.local.millisecond, "\n";
        } else {
            print "Result=Failure\n";
            print "  error=", r.error, "\n";
        }
    }

    method TestOfLocal() {
        print "=== TestOfLocal ===\n";
        // 1) Input: zoneId
        var zoneId: string := "PST8PDT";

        // Case A: GAP example (spring forward)
        var localA := LDT.LocalDateTime(2025, 3, 9, 2, 15, 0, 0);
        var pairA := ZDT.OfLocal(zoneId, localA, ZDT.SHIFT_FORWARD); // SHIFT_FORWARD for GAP
        print "=== Case A: GAP example (SHIFT_FORWARD) ===\n";
        PrintStatus(pairA.1);
        PrintResult(pairA.0);
        print "\n";

        // Case B: UNIQUE example
        var localB := LDT.LocalDateTime(2025, 5, 1, 10, 30, 0, 0);
        var pairB := ZDT.OfLocal(zoneId, localB, ZDT.PREFER_LATER);
        print "=== Case B: UNIQUE example ===\n";
        PrintStatus(pairB.1);
        PrintResult(pairB.0);
        print "\n";

        // Case C: OVERLAP example (fall back)
        var localC := LDT.LocalDateTime(2025, 11, 2, 1, 30, 0, 0);
        var pairC := ZDT.OfLocal(zoneId, localC, ZDT.PREFER_LATER);
        print "=== Case C: OVERLAP example (PREFER_LATER) ===\n";
        PrintStatus(pairC.1);
        PrintResult(pairC.0);
        print "\n";
    }

    method {:main} Main()
    {
        TestNowZoned();
        TestOfLocal();
    }
}