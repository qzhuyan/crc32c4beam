-module(crc32c4beam).
-on_load(init/0).

-export([
    crc32c/1,
    crc32c/2
]).

-define(APPNAME, ?MODULE).
-define(LIBNAME, libcrc32c4beam_nif).
init() ->
    LoadArg = 0,
    SoName =
        case code:priv_dir(?LIBNAME) of
            {error, bad_name} ->
                case filelib:is_dir(filename:join(["..", priv])) of
                    true ->
                        filename:join(["..", priv, ?LIBNAME]);
                    _ ->
                        filename:join([priv, ?LIBNAME])
                end;
            Dir ->
                filename:join(Dir, ?LIBNAME)
        end,
    case load_patch() of
        {true, Patch} ->
            erlang:load_nif(Patch, LoadArg);
        false ->
            erlang:load_nif(SoName, LoadArg)
    end.

load_patch() ->
    {ok, CWD} = file:get_cwd(),
    Patch = filename:join([CWD, patches, ?LIBNAME]),
    case filelib:is_file(Patch ++ ".so") of
        true ->
            {true, Patch};
        false ->
            false
    end.

crc32c(_) ->
    not_loaded(?LINE).

crc32c(_, _) ->
    not_loaded(?LINE).

not_loaded(Line) ->
    erlang:nif_error({not_loaded, [{module, ?MODULE}, {line, Line}]}).

-ifdef(TEST).

-include_lib("eunit/include/eunit.hrl").
nif(Term) ->
    crc32c(Term).
nif(Acc, Term) ->
    crc32c(Acc, Term).

basic_test_() ->
    [
        {"0", fun() -> ?assertEqual(0, nif(<<>>)) end},
        {"1-9", fun() -> ?assertEqual(16#e3069283, nif("123456789")) end},
        {"a", fun() -> ?assertEqual(16#c1d04330, nif("a")) end},
        {"license", fun() -> ?assertEqual(license_crc(), nif(license_txt())) end},
        {"acc", fun() ->
            Bytes = license_txt(),
            Crc = lists:foldl(fun(B, Acc) -> nif(Acc, [B]) end, 0, Bytes),
            ?assertEqual(license_crc(), Crc)
        end}
    ].

perf_test() ->
    Data = binary:copy(list_to_binary(license_txt()), 400),
    {Elapsed, ok} = timer:tc(
        fun() ->
            lists:foreach(fun(_) -> ?MODULE:crc32c(Data) end, lists:seq(1, 1000))
        end,
        millisecond
    ),
    Arch = erlang:system_info(system_architecture),
    case string:find(Arch, "x86_64") of
        nomatch ->
            ?debugFmt("Performance test on non-x86 architecture: ~p ms", [Elapsed]);
        _ ->
            ?debugFmt("Performance test on x86 architecture: ~p ms", [Elapsed]),
            ?assert(Elapsed < 100)
    end.

license_crc() ->
    16#7dcde113.

license_txt() ->
    "  This software is provided 'as-is', without any express or implied\n"
    "  warranty.  In no event will the author be held liable for any damages\n"
    "  arising from the use of this software.\n"
    "\n"
    "  Permission is granted to anyone to use this software for any purpose,\n"
    "  including commercial applications, and to alter it and redistribute it\n"
    "  freely, subject to the following restrictions:\n"
    "\n"
    "  1. The origin of this software must not be misrepresented; you must not\n"
    "     claim that you wrote the original software. If you use this software\n"
    "     in a product, an acknowledgment in the product documentation would be\n"
    "     appreciated but is not required.\n"
    "  2. Altered source versions must be plainly marked as such, and must not be\n"
    "     misrepresented as being the original software.\n"
    "  3. This notice may not be removed or altered from any source distribution.".

% TEST
-endif.
