%%-------------------------------------------------------------------
%% File    : cheat.erl
%% Author  : Michael Mullis <michael@mullistechnologies.com>
%% Description : Interface to the cheat sheats from http://cheat.errtheblog.com/
%% Created : 23 Sep 2008 by Michael Mullis <michael@mullistechnologies.com>
%%-------------------------------------------------------------------

-module(cheat).
-export([sheet/1, recent/0, all/0, sheet_reset/1, remove_sheet/1]).
-compile([export_all]).

-define(CHEAT_URI_BASE, "http://cheat.errtheblog.com/y/").
-define(RECENT_CHEATS_URI_BASE, "http://cheat.errtheblog.com/yr").
-define(ALL_CHEATS_URI_BASE, "http://cheat.errtheblog.com/ya").

file_exists(FileName) ->
  case filelib:is_regular(FileName) of
    true ->
      true;
    %% Even if its not a regular file, it might still exist
    %% /dev/null exhibits this behavior
    false ->
      case filelib:last_modified(FileName) of
        0 ->
          false;
        _ ->
          true
      end
  end.

fetch(Uri, UseCache) ->
  case UseCache of
    reset ->
      remove_sheet(Uri); % remove prior version so we can get the most recent
    _ ->
      ok
  end,

  case cached(Uri) of
    {data, Data} ->
      Data;
    uncached ->
      %% i really dont like having to do this start for inets. why is it not automatic on first http request?
      catch inets:start(),
      NewData = case http:request(Uri) of
                  {ok, {{_Httpver, 200, _Reason}, _Headers, Body}} ->
                    Body;
                  {ok, {{_Httpver, 200, _Reason}, Body}} ->
                    Body;
                  Error ->
                    throw({error, Error})
                end,
      case UseCache of
        skip ->  NewData;
        _    ->  store(Uri, NewData)
      end,
      NewData
  end.

cache_dir() ->
  {ok, [Home1]} = init:get_argument(home),
  hd(Home1) ++ "/.cheat".

cache_filename(?CHEAT_URI_BASE ++ SheetName) when is_list(SheetName) ->
  cache_filename(SheetName);
cache_filename(SheetName) when is_atom(SheetName) ->
  cache_filename(atom_to_list(SheetName));
cache_filename(SheetName) when is_list(SheetName) ->
  case lists:suffix(".yml", SheetName) of
    true ->
      filename:join([cache_dir(), SheetName]);
    _ ->
      filename:join([cache_dir(), SheetName ++ ".yml"])
  end.

cached(Uri) ->
  case file_exists( cache_filename(Uri) ) of
    true ->
      {ok, Data} = file:read_file(cache_filename(Uri)),
      {data, binary_to_list(Data)};
    false -> uncached
  end.

store(Uri, Data) when is_list(Data) ->
  %%io:fwrite(io_lib:format("Storing: ~p~n", [Data])),
  store(Uri, list_to_binary(Data));

store(Uri, Data) when is_binary(Data) ->
  Fname = cache_filename(Uri),
  filelib:ensure_dir(Fname),
  {ok, WriteDescr} = file:open(Fname, [binary, append, write]),
  file:write(WriteDescr, Data),
  file:close(WriteDescr),
  Data.  %% Return data to make fetch easier

sheet_key(SheetName) ->
  case is_atom(SheetName) of
    true ->
      atom_to_list(SheetName);
    false ->
      SheetName
  end.

dump(E) when is_list(E) ->
  io:format("~s~n",[E]);

dump(L) when is_list(L) ->
  lists:foreach(fun(E) ->  io:format("~s~n",[string:strip(E)]) end, L).


sheet(SheetName) ->
  dump(fetch(?CHEAT_URI_BASE ++ sheet_key(SheetName), true)).

sheet_reset(SheetName) ->
  dump(fetch(?CHEAT_URI_BASE ++ sheet_key(SheetName), reset)).

recent() ->
  dump(fetch(?RECENT_CHEATS_URI_BASE, skip)).

all() ->
  dump(fetch(?ALL_CHEATS_URI_BASE, skip)).

remove_sheet(SheetName) ->
  file:delete(cache_filename(?CHEAT_URI_BASE ++ SheetName)).
