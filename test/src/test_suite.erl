%%-------------------------------------------------------------------
%% File    : cheat_test.erl
%% Author  : Michael Mullis <michael@mullistechnologies.com>
%% Description : EUnit tests for Cheat module
%% Created : 23 Sep 2008 by Michael Mullis <michael@mullistechnologies.com>
%%-------------------------------------------------------------------
-module(test_suite).
-author("michael@mullistechnologies.com").

-include_lib("eunit/include/eunit.hrl").

all_test_() ->
  [{module, cheat_basic_test}
  ].
