-module(actions_app).
-behaviour(application).

-export([start/2]).
-export([stop/1]).

start(_Type, _Args) ->
	CtlState = sockjs_handler:init_state(<<"/a">>, fun events/3, state, []),
	Dispatch = [
		{'_', [
			{[<<"a">>, '...'], sockjs_cowboy_handler, CtlState},
			{['...'], cowboy_http_static, [
                                {directory, <<"./priv/www">>},
                                {mimetypes, {fun mimetypes:path_to_mimes/2, default}}
                        ]}
		]}
	],
	cowboy:start_listener(ecs_http_listener, 100,
		cowboy_tcp_transport, [{port, 8080}],
		cowboy_http_protocol, [{dispatch, Dispatch}]
	),
	actions_sup:start_link().

stop(_State) ->
	ok.

events(Con, init, state) -> {ok, state};
events(Con, {recv, Msg}, state) -> {ok, state};
events(Con, closed, state) -> {ok, state}.