Nonterminals or_expression and_expression constraint group arguments list_arguments list_argument_items.
Terminals '(' ')' or_op and_op selector arg_float arg_int arg_bool value comparison equal not_equal.
Rootsymbol or_expression.

or_expression -> and_expression                       : '$1'.
or_expression -> and_expression or_op and_expression  : {or_op, '$1', '$3'}.

and_expression -> constraint                    : '$1'.
and_expression -> constraint and_op constraint  : {and_op, '$1', '$3'}.

constraint -> group                           : '$1'.
constraint -> selector                        : {op, {selector, list_to_binary(extract_token('$1'))}}.
constraint -> selector comparison arguments   : {op, {selector_and_value, list_to_binary(extract_token('$1')), {comparison, list_to_binary(extract_token('$2'))}, '$3'}}.
constraint -> selector equal arguments        : {op, {selector_and_value, list_to_binary(extract_token('$1')), equal, '$3'}}.
constraint -> selector not_equal arguments    : {op, {selector_and_value, list_to_binary(extract_token('$1')), not_equal, '$3'}}.

group -> '(' or_expression ')'  : '$2'.

arguments -> value          : list_to_binary(extract_token('$1')).
arguments -> selector       : list_to_binary(extract_token('$1')).
arguments -> arg_float      : extract_token('$1').
arguments -> arg_int        : extract_token('$1').
arguments -> arg_bool       : extract_token('$1').
arguments -> list_arguments : '$1'.

list_arguments -> '(' ')'                       : [].
list_arguments -> '(' list_argument_items ')'   : '$2'.

list_argument_items -> arguments                            : ['$1'].
list_argument_items -> arguments or_op list_argument_items  : ['$1' | '$3'].

Erlang code.

extract_token({_Token, _Line, Value}) -> Value.
