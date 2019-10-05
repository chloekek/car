module card.util.parse.fail;

import card.util.parse : Result;

private
struct Fail(O)
{
    inout(Result!O) parse(I)(ref const(I)) inout
    {
        return Result!O();
    }
}

/// Return a parser that does not consume input and fails.
auto fail(O)()
{
    return Fail!O();
}

///
nothrow pure @nogc @safe
unittest
{
    const parser = fail!int;
    const input  = "";
    const result = parser.parse(input);

    assert (result.isNull);
    assert (input == "");
}
