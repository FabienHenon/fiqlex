defmodule FIQLExLexerTest do
  use ExUnit.Case, async: true

  test "Simple selector" do
    payload = "my_selector"

    assert :fiql_lexer.string(to_charlist(payload)) ==
             {:ok,
              [
                {:selector, 1, 'my_selector'}
              ], 1}
  end

  test "Simple selector and value" do
    payload = "my_selector==value"

    assert :fiql_lexer.string(to_charlist(payload)) ==
             {:ok,
              [
                {:selector, 1, 'my_selector'},
                {:equal, 1},
                {:selector, 1, 'value'}
              ], 1}
  end

  test "Selector with complex value" do
    payload = "my_selector==2019-02-02T18:32:12Z"

    assert :fiql_lexer.string(to_charlist(payload)) ==
             {:ok,
              [
                {:selector, 1, 'my_selector'},
                {:equal, 1},
                {:value, 1, '2019-02-02T18:32:12Z'}
              ], 1}
  end

  test "Selector with list value" do
    payload = "my_selector==(1, value)"

    assert :fiql_lexer.string(to_charlist(payload)) ==
             {:ok,
              [
                {:selector, 1, 'my_selector'},
                {:equal, 1},
                {:"(", 1},
                {:arg_int, 1, 1},
                {:or_op, 1},
                {:selector, 1, 'value'},
                {:")", 1}
              ], 1}
  end

  test "Selector with true value" do
    payload = "my_selector==True"

    assert :fiql_lexer.string(to_charlist(payload)) ==
             {:ok,
              [
                {:selector, 1, 'my_selector'},
                {:equal, 1},
                {:arg_bool, 1, true}
              ], 1}
  end

  test "Selector with false value" do
    payload = "my_selector==false"

    assert :fiql_lexer.string(to_charlist(payload)) ==
             {:ok,
              [
                {:selector, 1, 'my_selector'},
                {:equal, 1},
                {:arg_bool, 1, false}
              ], 1}
  end

  test "Selector with integer value" do
    payload = "my_selector==123"

    assert :fiql_lexer.string(to_charlist(payload)) ==
             {:ok,
              [
                {:selector, 1, 'my_selector'},
                {:equal, 1},
                {:arg_int, 1, 123}
              ], 1}
  end

  test "Selector with positive integer value" do
    payload = "my_selector==+123"

    assert :fiql_lexer.string(to_charlist(payload)) ==
             {:ok,
              [
                {:selector, 1, 'my_selector'},
                {:equal, 1},
                {:arg_int, 1, 123}
              ], 1}
  end

  test "Selector with negative integer value" do
    payload = "my_selector==-123"

    assert :fiql_lexer.string(to_charlist(payload)) ==
             {:ok,
              [
                {:selector, 1, 'my_selector'},
                {:equal, 1},
                {:arg_int, 1, -123}
              ], 1}
  end

  test "Selector with float value" do
    payload = "my_selector==123.5"

    assert :fiql_lexer.string(to_charlist(payload)) ==
             {:ok,
              [
                {:selector, 1, 'my_selector'},
                {:equal, 1},
                {:arg_float, 1, 123.5}
              ], 1}
  end

  test "Selector with positive float value" do
    payload = "my_selector==+123.5"

    assert :fiql_lexer.string(to_charlist(payload)) ==
             {:ok,
              [
                {:selector, 1, 'my_selector'},
                {:equal, 1},
                {:arg_float, 1, 123.5}
              ], 1}
  end

  test "Selector with negative float value" do
    payload = "my_selector==-123.5"

    assert :fiql_lexer.string(to_charlist(payload)) ==
             {:ok,
              [
                {:selector, 1, 'my_selector'},
                {:equal, 1},
                {:arg_float, 1, -123.5}
              ], 1}
  end

  test "Selector with complex float value" do
    payload = "my_selector==-123.5e-10"

    assert :fiql_lexer.string(to_charlist(payload)) ==
             {:ok,
              [
                {:selector, 1, 'my_selector'},
                {:equal, 1},
                {:arg_float, 1, -123.5e-10}
              ], 1}
  end

  test "Selector with double quoted value" do
    payload = "my_selector==\"my value != weird;,\""

    assert :fiql_lexer.string(to_charlist(payload)) ==
             {:ok,
              [
                {:selector, 1, 'my_selector'},
                {:equal, 1},
                {:value, 1, 'my value != weird;,'}
              ], 1}
  end

  test "Selector with complex double quoted value" do
    payload = "my_selector==\"my \\\"value\\\" != 'weird';,\""

    assert :fiql_lexer.string(to_charlist(payload)) ==
             {:ok,
              [
                {:selector, 1, 'my_selector'},
                {:equal, 1},
                {:value, 1, 'my "value" != \'weird\';,'}
              ], 1}
  end

  test "Selector with single quoted value" do
    payload = "my_selector=='my value != weird;,'"

    assert :fiql_lexer.string(to_charlist(payload)) ==
             {:ok,
              [
                {:selector, 1, 'my_selector'},
                {:equal, 1},
                {:value, 1, 'my value != weird;,'}
              ], 1}
  end

  test "Selector with complex single quoted value" do
    payload = "my_selector=='my \"value\" != \\'weird\\';,'"

    assert :fiql_lexer.string(to_charlist(payload)) ==
             {:ok,
              [
                {:selector, 1, 'my_selector'},
                {:equal, 1},
                {:value, 1, 'my "value" != \'weird\';,'}
              ], 1}
  end

  test "Multiple selectors separated by and and or" do
    payload = "my_selector1==value1,my_selector2==value2;my_selector3==value3"

    assert :fiql_lexer.string(to_charlist(payload)) ==
             {:ok,
              [
                {:selector, 1, 'my_selector1'},
                {:equal, 1},
                {:selector, 1, 'value1'},
                {:or_op, 1},
                {:selector, 1, 'my_selector2'},
                {:equal, 1},
                {:selector, 1, 'value2'},
                {:and_op, 1},
                {:selector, 1, 'my_selector3'},
                {:equal, 1},
                {:selector, 1, 'value3'}
              ], 1}
  end

  test "Multiple ORs" do
    payload = "my_selector1==value1,my_selector2==value2,my_selector3==value3"

    assert :fiql_lexer.string(to_charlist(payload)) ==
             {:ok,
              [
                {:selector, 1, 'my_selector1'},
                {:equal, 1},
                {:selector, 1, 'value1'},
                {:or_op, 1},
                {:selector, 1, 'my_selector2'},
                {:equal, 1},
                {:selector, 1, 'value2'},
                {:or_op, 1},
                {:selector, 1, 'my_selector3'},
                {:equal, 1},
                {:selector, 1, 'value3'}
              ], 1}
  end

  test "Multiple ANDs" do
    payload = "my_selector1==value1;my_selector2==value2;my_selector3==value3"

    assert :fiql_lexer.string(to_charlist(payload)) ==
             {:ok,
              [
                {:selector, 1, 'my_selector1'},
                {:equal, 1},
                {:selector, 1, 'value1'},
                {:and_op, 1},
                {:selector, 1, 'my_selector2'},
                {:equal, 1},
                {:selector, 1, 'value2'},
                {:and_op, 1},
                {:selector, 1, 'my_selector3'},
                {:equal, 1},
                {:selector, 1, 'value3'}
              ], 1}
  end

  test "Multiple ORs (4)" do
    payload =
      "my_selector1==value1,my_selector2==value2,my_selector3==value3,my_selector4==value4"

    assert :fiql_lexer.string(to_charlist(payload)) ==
             {:ok,
              [
                {:selector, 1, 'my_selector1'},
                {:equal, 1},
                {:selector, 1, 'value1'},
                {:or_op, 1},
                {:selector, 1, 'my_selector2'},
                {:equal, 1},
                {:selector, 1, 'value2'},
                {:or_op, 1},
                {:selector, 1, 'my_selector3'},
                {:equal, 1},
                {:selector, 1, 'value3'},
                {:or_op, 1},
                {:selector, 1, 'my_selector4'},
                {:equal, 1},
                {:selector, 1, 'value4'}
              ], 1}
  end

  test "Multiple ANDs (4)" do
    payload =
      "my_selector1==value1;my_selector2==value2;my_selector3==value3;my_selector4==value4"

    assert :fiql_lexer.string(to_charlist(payload)) ==
             {:ok,
              [
                {:selector, 1, 'my_selector1'},
                {:equal, 1},
                {:selector, 1, 'value1'},
                {:and_op, 1},
                {:selector, 1, 'my_selector2'},
                {:equal, 1},
                {:selector, 1, 'value2'},
                {:and_op, 1},
                {:selector, 1, 'my_selector3'},
                {:equal, 1},
                {:selector, 1, 'value3'},
                {:and_op, 1},
                {:selector, 1, 'my_selector4'},
                {:equal, 1},
                {:selector, 1, 'value4'}
              ], 1}
  end

  test "Equal comparison" do
    payload = "my_selector1==value1"

    assert :fiql_lexer.string(to_charlist(payload)) ==
             {:ok,
              [
                {:selector, 1, 'my_selector1'},
                {:equal, 1},
                {:selector, 1, 'value1'}
              ], 1}
  end

  test "Not equal comparison" do
    payload = "my_selector1!=value1"

    assert :fiql_lexer.string(to_charlist(payload)) ==
             {:ok,
              [
                {:selector, 1, 'my_selector1'},
                {:not_equal, 1},
                {:selector, 1, 'value1'}
              ], 1}
  end

  test "Custom comparison" do
    payload = "my_selector1=ge=value1"

    assert :fiql_lexer.string(to_charlist(payload)) ==
             {:ok,
              [
                {:selector, 1, 'my_selector1'},
                {:comparison, 1, 'ge'},
                {:selector, 1, 'value1'}
              ], 1}
  end

  test "Parenthesis" do
    payload = "my_selector1==value1,(my_selector2==value2;my_selector3==value3)"

    assert :fiql_lexer.string(to_charlist(payload)) ==
             {:ok,
              [
                {:selector, 1, 'my_selector1'},
                {:equal, 1},
                {:selector, 1, 'value1'},
                {:or_op, 1},
                {:"(", 1},
                {:selector, 1, 'my_selector2'},
                {:equal, 1},
                {:selector, 1, 'value2'},
                {:and_op, 1},
                {:selector, 1, 'my_selector3'},
                {:equal, 1},
                {:selector, 1, 'value3'},
                {:")", 1}
              ], 1}
  end

  test "Complex expression" do
    payload =
      "mon_selector==mavalue;selector.2!='deuxieme;,=\\' \\'v\"alu\\'e',(encore_selector=eq=\"coucou ! 'moi=\\\"toi\\\"\";(select1=ge=true,select2==False);select.encore=le=12;select.encore2=le=23.3443;select.encore3==23.89e-34;select.int==-23;select.pos==+34.5),duration=le=-P1D;time=ge=2019-12-34T18:23:23.234Z"

    assert :fiql_lexer.string(to_charlist(payload)) ==
             {:ok,
              [
                {:selector, 1, 'mon_selector'},
                {:equal, 1},
                {:selector, 1, 'mavalue'},
                {:and_op, 1},
                {:selector, 1, 'selector.2'},
                {:not_equal, 1},
                {:value, 1, 'deuxieme;,=\' \'v"alu\'e'},
                {:or_op, 1},
                {:"(", 1},
                {:selector, 1, 'encore_selector'},
                {:comparison, 1, 'eq'},
                {:value, 1, 'coucou ! \'moi="toi"'},
                {:and_op, 1},
                {:"(", 1},
                {:selector, 1, 'select1'},
                {:comparison, 1, 'ge'},
                {:arg_bool, 1, true},
                {:or_op, 1},
                {:selector, 1, 'select2'},
                {:equal, 1},
                {:arg_bool, 1, false},
                {:")", 1},
                {:and_op, 1},
                {:selector, 1, 'select.encore'},
                {:comparison, 1, 'le'},
                {:arg_int, 1, 12},
                {:and_op, 1},
                {:selector, 1, 'select.encore2'},
                {:comparison, 1, 'le'},
                {:arg_float, 1, 23.3443},
                {:and_op, 1},
                {:selector, 1, 'select.encore3'},
                {:equal, 1},
                {:arg_float, 1, 2.389e-33},
                {:and_op, 1},
                {:selector, 1, 'select.int'},
                {:equal, 1},
                {:arg_int, 1, -23},
                {:and_op, 1},
                {:selector, 1, 'select.pos'},
                {:equal, 1},
                {:arg_float, 1, 34.5},
                {:")", 1},
                {:or_op, 1},
                {:selector, 1, 'duration'},
                {:comparison, 1, 'le'},
                {:value, 1, '-P1D'},
                {:and_op, 1},
                {:selector, 1, 'time'},
                {:comparison, 1, 'ge'},
                {:value, 1, '2019-12-34T18:23:23.234Z'}
              ], 1}
  end
end
