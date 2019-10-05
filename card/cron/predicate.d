module card.cron.predicate;

import std.datetime : DateTime;
import std.range : ElementType, isForwardRange;
import std.typecons : Nullable;

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
    bool opCall(DateTime d) const scope
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

/// Parse a predicate given a line in crontab-like syntax.
Nullable!Predicate parse(I)(I i)
    if (isForwardRange!I &&
        is(ElementType!I : dchar))
{
    return parser.parse(i);
}

///
pure @safe
unittest
{
    const input  = "15 * * * *"d;
    const result = parse(input);
    assert (!result(DateTime(2019, 10, 5, 20, 16)));
    assert (result(DateTime(2019, 10, 5, 20, 15)));
}

private
auto parser()
{
    import card.util.parse : all, any, but, eof, satisfy;
    import std.algorithm : map;
    import std.array : staticArray;
    import std.range : iota, repeat;
    import ascii = std.ascii;

    auto asterisk(size_t N)()
    {
        return satisfy!(a => a == '*')
               .but!(_ => staticArray!(repeat(true, N)));
    }

    auto exact(size_t N)()
    {
        // TODO: Handle integers that are too large.
        // TODO: Handle single-digit integers.
        const digit   = satisfy!(ascii.isDigit).but!(n => n - '0');
        alias integer = n => 10 * n[0] + n[1];
        alias subcent = (n) { bool[N] r; r[n] = true; return r; };
        return all(digit, digit).but!integer.but!subcent;
    }

    auto component(size_t N)()
    {
        return any(asterisk!N, exact!N);
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
