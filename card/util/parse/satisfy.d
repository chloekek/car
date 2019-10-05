module card.util.parse.satisfy;

import card.util.parse : Result;

import std.array : empty, front, popFront;
import std.functional : unaryFun;
import std.range : ElementType, isInputRange;

private
struct Satisfy(alias F)
{
    private
    alias f = unaryFun!F;

    template parse(I)
        if (isInputRange!I)
    {
        private
        alias O = ElementType!I;

        inout(Result!O) parse(ref I i) inout
        {
            if (i.empty)
                return Result!O();

            auto r = i.front;

            if (!f(r))
                return Result!O();

            i.popFront;

            return Result!O(r);
        }
    }
}

/// Return a parser which succeeds iff the input is non-empty and the first token
/// passes the given predicate. If it succeeds, it does so with the first token,
/// consuming it.
auto satisfy(alias F)()
{
    return Satisfy!F();
}

///
nothrow pure @nogc @safe
unittest
{
    const parser = satisfy!`a != ' '`;
    auto  input  = ""d;
    const result = parser.parse(input);

    assert (result.isNull);
    assert (input == ""d);
}

///
nothrow pure @nogc @safe
unittest
{
    const parser = satisfy!`a != ' '`;
    auto  input  = " foo"d;
    const result = parser.parse(input);

    assert (result.isNull);
    assert (input == " foo"d);
}

///
nothrow pure @nogc @safe
unittest
{
    const parser = satisfy!`a != ' '`;
    auto  input  = "foo"d;
    const result = parser.parse(input);

    assert (!result.isNull);
    assert (result.get == 'f');
    assert (input == "oo"d);
}
