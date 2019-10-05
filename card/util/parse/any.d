module card.util.parse.any;

import card.util.parse : OutputType, Result;

import std.meta : staticMap;
import std.traits : CommonType;
import std.typecons : Tuple, tuple;

private
struct Any(Ps...)
{
    private
    Tuple!Ps parsers;

    template parse(I)
    {
        private
        {
            alias O = CommonType!(staticMap!(OF, Ps));
            alias OF(P) = OutputType!(P, I);
        }

        Result!O parse(ref I i) const
        {
            static foreach (j; 0 .. Ps.length) {{
                auto r = parsers[j].parse(i);
                if (!r.isNull)
                    return Result!O(r.get);
            }}
            return Result!O();
        }
    }
}

/// Return a parser which tries the given parsers one by one until there is one
/// that succeeds.
auto any(Ps...)(Ps parsers)
    if (Ps.length > 0)
{
    return Any!Ps(tuple(parsers));
}
