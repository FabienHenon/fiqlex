Definitions.

SELECTOR                = [0-9a-zA-Z:._]+
ARG_TXT                 = [^\s\t\n\r"';,=!\(\)]+
ARG_DOUBLE_QUOTED_TXT   = "([^"\\]|(\\"))+"
ARG_SINGLE_QUOTED_TXT   = '([^'\\]|(\\'))+'
ARG_INT                 = (\+|-)?[0-9]+
ARG_FLOAT               = (\+|-)?[0-9]+\.[0-9]+((E|e)(\+|-)?[0-9]+)?
ARG_BOOL                = ((t|T)(r|R)(u|U)(e|E))|((f|F)(a|A)(l|L)(s|S)(e|E))
COMPARISON              = =[0-9a-z]+=
WHITESPACE              = [\s\t\n\r]

Rules.

{ARG_FLOAT}             : {token, {arg_float, TokenLine, list_to_float(TokenChars)}}.
{ARG_INT}               : {token, {arg_int, TokenLine, list_to_integer(TokenChars)}}.
{ARG_BOOL}              : {token, {arg_bool, TokenLine, list_to_bool(TokenChars)}}.
{SELECTOR}              : {token, {selector, TokenLine, TokenChars}}.
{ARG_TXT}               : {token, {value, TokenLine, TokenChars}}.
{ARG_DOUBLE_QUOTED_TXT} : {token, {value, TokenLine, from_double_quoted(TokenChars)}}.
{ARG_SINGLE_QUOTED_TXT} : {token, {value, TokenLine, from_single_quoted(TokenChars)}}.
{COMPARISON}            : {token, {comparison,  TokenLine, strip_equals(TokenChars)}}.
\(                      : {token, {'(',  TokenLine}}.
\)                      : {token, {')',  TokenLine}}.
\,                      : {token, {or_op,  TokenLine}}.
\;                      : {token, {and_op,  TokenLine}}.
==                      : {token, {equal,  TokenLine}}.
!=                      : {token, {not_equal,  TokenLine}}.
{WHITESPACE}+           : skip_token.

Erlang code.

to_bool(<<"true">>) ->
  true;
to_bool(<<"false">>) ->
  false.

list_to_bool(Chars) ->
  to_bool(string:lowercase(list_to_binary(Chars))).

from_double_quoted(Chars) ->
  binary_to_list(re:replace(string:slice(list_to_binary(Chars), 1, string:length(list_to_binary(Chars))-2), "\\\\\"", "\"", [global, {return, binary}])).

from_single_quoted(Chars) ->
  binary_to_list(re:replace(string:slice(list_to_binary(Chars), 1, string:length(list_to_binary(Chars))-2), "\\\\'", "'", [global, {return, binary}])).

strip_equals(Chars) ->
  binary_to_list(string:slice(list_to_binary(Chars), 1, string:length(list_to_binary(Chars))-2)).