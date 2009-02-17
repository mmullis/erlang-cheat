%%-------------------------------------------------------------------
%% File    : cheat_test.erl
%% Author  : Michael Mullis <michael@mullistechnologies.com>
%% Description : EUnit tests for Cheat module
%% Created : 23 Sep 2008 by Michael Mullis <michael@mullistechnologies.com>
%%-------------------------------------------------------------------
-module(cheat_basic_test).
-author("michael@mullistechnologies.com").

-include_lib("eunit/include/eunit.hrl").

%% Ok, so there's not much implemented.
basic_test_() ->
    [
     ?_assert(ok==cheat:sheet("cheat"))
    ].
