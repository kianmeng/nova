-module(nova_rest_plugin).

-behaviour(nova_plugin).

-export([pre_request/2]).

pre_request(#{headers := Headers} = Req, Options) ->
    case accept(Headers, Options) of
        true ->
            case content_type(Headers, Options) of
                true -> 
                    {ok, Req};
                false ->
                    {stop, cowboy_req:reply(415, Req)}
            end;
        false ->
            {stop, cowboy_req:reply(406, Req)}
    end.

    

accept(#{<<"accept">> := Accept}, #{accept := AcceptList}) ->
    validate(Accept, AcceptList);
accept(_, _) ->
    true.

content_type(#{<<"content-type">> := <<"application/json", _/binary>>}, #{content_type := ContentTypeList}) ->
    validate(<<"application/json">>, ContentTypeList);
content_type(#{<<"content-type">> := <<"application/x-www-form-urlencoded", _/binary>>},
             #{content_type := ContentTypeList}) ->
    validate(<<"application/json">>, ContentTypeList);
content_type(#{<<"content-type">> := ContentType}, #{content_type := ContentTypeList}) ->
    validate(ContentType, ContentTypeList);
content_type(_, _) ->
    true.

content_header(json) -> <<"application/json">>;
content_header(x_web_form) -> <<"application/x-www-form-urlencoded">>.

validate(ContentType, ContentTypeList) ->
    Converted = [content_header(X) || X <- ContentTypeList],
    lists:member(ContentType, Converted).