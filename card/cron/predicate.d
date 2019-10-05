module card.cron.predicate;

import std.datetime : DateTime;
import std.range : ElementType, isForwardRange;

struct Predicate
{
    bool[60] minute;
    bool[24] hour;
    bool[31] day;
    bool[12] month;
    bool[ 7] dayOfWeek;

    nothrow pure @nogc @safe
    this(bool[60] minute,
         bool[24] hour,
         bool[31] day,
         bool[12] month,
         bool[ 7] dayOfWeek) inout scope
    {
        this.minute    = minute;
        this.hour      = hour;
        this.day       = day;
        this.month     = month;
        this.dayOfWeek = dayOfWeek;
    }

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

/// Parser that produces a predicate given a line in crontab-like syntax.
auto parser()
{
    import card.util.parse : all, but, eof, satisfy;
    import std.array : staticArray;
    import std.range : repeat;
    import ascii = std.ascii;

    auto asterisk(size_t N)()
    {
        return satisfy!(a => a == '*')
               .but!(_ => staticArray!(repeat(true, N)));
    }

    auto component(size_t N)()
    {
        return asterisk!N;
    }

    const space = satisfy!`a == ' '`;

    const components = all(
        component!60, space,
        component!24, space,
        component!31, space,
        component!12, space,
        component! 7, eof  ,
    );

    return components.but!(t => Predicate(t[0], t[2], t[4], t[6], t[8]));
}

///
nothrow pure @nogc @safe
unittest
{
    auto  input  = "* * * * *"d;
    const result = parser.parse(input);
}
