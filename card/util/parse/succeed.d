module card.util.parse.succeed;

import card.util.parse : Result;

private
struct Succeed(O)
{
    private
    O value;

    inout(Result!O) parse(I)(ref const(I)) inout
    {
        return Result!O(value);
    }
}

/// Return a parser that does not consume input and succeeds with the given
/// value.
auto succeed(O)(O value)
{
    return Succeed!O(value);
}

///
nothrow pure @nogc @safe
unittest
{
    const value  = 0;
    const parser = succeed(value);
    const input  = "";
    const result = parser.parse(input);

    assert (!result.isNull);
    assert (result.get == value);
    assert (input == "");
}
