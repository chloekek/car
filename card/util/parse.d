module card.util.parse;

import std.array : empty, front, popFront;
import std.functional : unaryFun;
import std.range : ElementType, isInputRange;
import std.typecons : Nullable;

/+ -------------------------------------------------------------------------- +/

alias Result = Nullable;

/+ -------------------------------------------------------------------------- +/

private
struct Succeed(O)
{
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

/+ -------------------------------------------------------------------------- +/

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

/+ -------------------------------------------------------------------------- +/

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

/+ -------------------------------------------------------------------------- +/

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
