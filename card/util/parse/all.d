module card.util.parse.all;

import card.util.parse : OutputType, Result;
import card.util.parse.token : token;

import std.algorithm : map;
import std.array : join;
import std.format : format;
import std.meta : staticMap;
import std.range : iota;
import std.typecons : Tuple, tuple;

private
struct All(Ps...)
{
    private
    Tuple!Ps parsers;

    template parse(I)
    {
        private
        {
            alias O = Tuple!(staticMap!(OF, Ps));
            alias OF(P) = OutputType!(P, I);
        }

        Result!O parse(ref I i) const
        {
            static foreach (j; 0 .. Ps.length)
                mixin(
                    format!`
                        auto r%d = parsers[%d].parse(i);
                        if (r%d.isNull)
                            return Result!O();
                    `(j, j, j)
                );
            enum rs = iota(Ps.length).map!`format!"r%d.get"(a)`;
            return Result!O(mixin(`tuple(` ~ rs.join(`, `) ~ `)`));
        }
    }
}

/// Return a parser which succeeds iff all given parsers succeed, by applying
/// them in order and returning a tuple with the results.
auto all(Ps...)(Ps parsers)
{
    return All!Ps(tuple(parsers));
}

///
nothrow pure @nogc @safe
unittest
{
    const parser = all(token, token, token);
    auto  input  = "fo"d;
    const result = parser.parse(input);

    assert (result.isNull);
    assert (input == ""d);
}

///
nothrow pure @nogc @safe
unittest
{
    const parser = all(token, token, token);
    auto  input  = "foo"d;
    const result = parser.parse(input);

    assert (!result.isNull);
    assert (result.get == tuple('f', 'o', 'o'));
    assert (input == ""d);
}
