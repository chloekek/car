module card.util.parse.eof;

import card.util.parse : Result;

import std.array : empty;
import std.range : isInputRange;
import std.typecons : Tuple, tuple;

private
struct Eof
{
    private
    alias O = Tuple!();

    Result!O parse(I)(ref I i) const
        if (isInputRange!I)
    {
        if (i.empty)
            return Result!O(O());
        return Result!O();
    }
}

/// Return a parser that succeeds if and only if the input is empty. The result
/// is the empty tuple.
auto eof()
{
    return Eof();
}

///
nothrow pure @nogc @safe
unittest
{
    const parser = eof;
    auto  input  = ""d;
    const result = parser.parse(input);

    assert (!result.isNull);
}

///
nothrow pure @nogc @safe
unittest
{
    const parser = eof;
    auto  input  = "foo"d;
    const result = parser.parse(input);

    assert (result.isNull);
    assert (input == "foo"d);
}
