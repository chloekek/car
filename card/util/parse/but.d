module card.util.parse.but;

import card.util.parse : OutputType, Result;
import card.util.parse.fail : fail;
import card.util.parse.token : token;

import std.functional : unaryFun;
import std.traits : rvalueOf;

import ascii = std.ascii;

private
struct But(alias F, P)
{
    private
    alias f = unaryFun!F;

    private
    P parser;

    template parse(I)
    {
        private
        alias O = typeof(f(rvalueOf!(OutputType!(P, I))));

        Result!O parse(ref I i) const
        {
            auto r = parser.parse(i);
            if (r.isNull)
                return Result!O();
            return Result!O(f(r.get));
        }
    }
}

/// Return a parser that applies the given function to the result of the given
/// parser.
auto but(alias F, P)(P parser)
{
    return But!(F, P)(parser);
}

///
nothrow pure @nogc @safe
unittest
{
    const parser = fail!int.but!(ascii.toUpper);
    auto  input  = "foo"d;
    const result = parser.parse(input);

    assert (result.isNull);
    assert (input == "foo"d);
}

///
nothrow pure @nogc @safe
unittest
{
    const parser = token.but!(ascii.toUpper);
    auto  input  = "foo"d;
    const result = parser.parse(input);

    assert (!result.isNull);
    assert (result.get == 'F');
    assert (input == "oo"d);
}

