module card.util.parse.satisfies;

import card.util.parse : Result;

import std.algorithm : equal;
import std.array : empty, front, popFront, save;
import std.functional : unaryFun;
import std.range : isForwardRange, take;
import std.traits : lvalueOf;

import ascii = std.ascii;

private
struct Satisfies(alias F)
{
    private
    alias f = unaryFun!F;

    template parse(I)
        if (isForwardRange!I)
    {
        private
        alias O = typeof(lvalueOf!I.save.take(lvalueOf!size_t));

        Result!O parse(ref I i) const
        {
            auto j = i.save;
            size_t n = 0;
            while (!i.empty && f(i.front)) {
                i.popFront;
                ++n;
            }
            return Result!O(j.take(n));
        }
    }
}

/// Return a parser which succeeds, returning an input range that yields the
/// (possibly empty) prefix of the input for which each token satisfies the given
/// predicate.
auto satisfies(alias F)()
{
    return Satisfies!F();
}

///
nothrow pure @nogc @safe
unittest
{
    const parser = satisfies!(ascii.isAlpha);
    auto  input  = "foo bar"d;
    const result = parser.parse(input);

    assert (!result.isNull);
    assert (equal(result.get, "foo"d));
    assert (input == " bar"d);
}
