module card.util.parse.token;

import card.util.parse.satisfy : satisfy;

/// Return a parser which succeeds iff the input is non-empty. If it succeeds, it
/// does so with the first token, consuming it.
auto token()
{
    return satisfy!`true`;
}

///
nothrow pure @nogc @safe
unittest
{
    const parser = token;
    auto  input  = ""d;
    const result = parser.parse(input);

    assert (result.isNull);
    assert (input == ""d);
}

///
nothrow pure @nogc @safe
unittest
{
    const parser = token;
    auto  input  = "foo"d;
    const result = parser.parse(input);

    assert (!result.isNull);
    assert (result.get == 'f');
    assert (input == "oo"d);
}
