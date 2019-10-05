module card.cron.predicate;

import std.datetime : DateTime;

struct Predicate
{
    bool[60] minute;
    bool[24] hour;
    bool[31] day;
    bool[12] month;
    bool[ 7] dayOfWeek;

    /// Apply the predicate to a local date and time. Return true iff the date
    /// and time satisfy the predicate.
    nothrow pure @nogc @safe
    bool opCall(ref scope const(DateTime) d) const scope
    {
        return minute    [d.minute    ] &&
               hour      [d.hour      ] &&
               day       [d.day       ] &&
               month     [d.month     ] &&
               dayOfWeek [d.dayOfWeek ] ;
    }

    ///
    nothrow pure @nogc @safe
    unittest
    {
    }
}
