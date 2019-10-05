module card.util.parse;

import std.algorithm : map;
import std.array : empty, front, join, popFront, save;
import std.format : format;
import std.functional : unaryFun;
import std.meta : staticMap;
import std.range : ElementType, isForwardRange, iota, isInputRange;
import std.traits : lvalueOf, rvalueOf;
import std.typecons : Nullable, Tuple, tuple;

import ascii = std.ascii;

/+ -------------------------------------------------------------------------- +/

alias Result = Nullable;

alias OutputType(P, I) =
    typeof(rvalueOf!P.parse(lvalueOf!I).get);

/+ -------------------------------------------------------------------------- +/

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

/+ -------------------------------------------------------------------------- +/

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
        alias O = OutputType!(P, I);

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

/+ -------------------------------------------------------------------------- +/

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

/+ -------------------------------------------------------------------------- +/

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
