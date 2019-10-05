module card.util.parse.backtrack;

import card.util.parse : OutputType, Result;
import card.util.parse.all : all;
import card.util.parse.token : token;

import std.array : save;
import std.range : isForwardRange;
import std.typecons : tuple;

private
struct Backtrack(P)
{
    private
    P parser;

    template parse(I)
        if (isForwardRange!I)
    {
        private
        alias O = OutputType!(P, I);

        Result!O parse(ref I i) const
        {
            auto j = i.save;
            auto r = parser.parse(j);
            if (!r.isNull)
                i = j;
            return r;
        }
    }
}

/// Return a parser that backtracks if the given parser fails. The result of the
/// given parser is returned regardless.
auto backtrack(P)(P parser)
{
    return Backtrack!P(parser);
}

///
nothrow pure @nogc @safe
unittest
{
    const parser = backtrack(all(token, token, token));
    auto  input  = "fo"d;
    const result = parser.parse(input);

    assert (result.isNull);
    assert (input == "fo"d);
}

///
nothrow pure @nogc @safe
unittest
{
    const parser = backtrack(all(token, token, token));
    auto  input  = "foo"d;
    const result = parser.parse(input);

    assert (!result.isNull);
    assert (result.get == tuple('f', 'o', 'o'));
    assert (input == ""d);
}
