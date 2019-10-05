module card.util.parse;

public import card.util.parse.all;
public import card.util.parse.any;
public import card.util.parse.backtrack;
public import card.util.parse.but;
public import card.util.parse.eof;
public import card.util.parse.fail;
public import card.util.parse.satisfies;
public import card.util.parse.satisfy;
public import card.util.parse.succeed;
public import card.util.parse.token;

import std.traits : lvalueOf, rvalueOf;
import std.typecons : Nullable;

alias Result = Nullable;

alias OutputType(P, I) =
    typeof(rvalueOf!P.parse(lvalueOf!I).get);
