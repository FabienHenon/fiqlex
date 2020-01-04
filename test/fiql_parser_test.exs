defmodule FIQLExParserTest do
  use ExUnit.Case, async: true

  test "Simple selector" do
    payload = "my_selector"
    {:ok, tokens, _} = :fiql_lexer.string(to_charlist(payload))

    assert :fiql_parser.parse(tokens) ==
             {:ok, {:op, {:selector, "my_selector"}}}
  end

  test "Simple selector and value" do
    payload = "my_selector==value"
    {:ok, tokens, _} = :fiql_lexer.string(to_charlist(payload))

    assert :fiql_parser.parse(tokens) ==
             {:ok, {:op, {:selector_and_value, "my_selector", :equal, "value"}}}
  end

  test "Selector with complex value" do
    payload = "my_selector==2019-02-02T18:32:12Z"
    {:ok, tokens, _} = :fiql_lexer.string(to_charlist(payload))

    assert :fiql_parser.parse(tokens) ==
             {:ok, {:op, {:selector_and_value, "my_selector", :equal, "2019-02-02T18:32:12Z"}}}
  end

  test "Selector with true value" do
    payload = "my_selector==True"
    {:ok, tokens, _} = :fiql_lexer.string(to_charlist(payload))

    assert :fiql_parser.parse(tokens) ==
             {:ok, {:op, {:selector_and_value, "my_selector", :equal, true}}}
  end

  test "Selector with false value" do
    payload = "my_selector==false"
    {:ok, tokens, _} = :fiql_lexer.string(to_charlist(payload))

    assert :fiql_parser.parse(tokens) ==
             {:ok, {:op, {:selector_and_value, "my_selector", :equal, false}}}
  end

  test "Selector with integer value" do
    payload = "my_selector==123"
    {:ok, tokens, _} = :fiql_lexer.string(to_charlist(payload))

    assert :fiql_parser.parse(tokens) ==
             {:ok, {:op, {:selector_and_value, "my_selector", :equal, 123}}}
  end

  test "Selector with positive integer value" do
    payload = "my_selector==+123"
    {:ok, tokens, _} = :fiql_lexer.string(to_charlist(payload))

    assert :fiql_parser.parse(tokens) ==
             {:ok, {:op, {:selector_and_value, "my_selector", :equal, 123}}}
  end

  test "Selector with negative integer value" do
    payload = "my_selector==-123"
    {:ok, tokens, _} = :fiql_lexer.string(to_charlist(payload))

    assert :fiql_parser.parse(tokens) ==
             {:ok, {:op, {:selector_and_value, "my_selector", :equal, -123}}}
  end

  test "Selector with float value" do
    payload = "my_selector==123.5"
    {:ok, tokens, _} = :fiql_lexer.string(to_charlist(payload))

    assert :fiql_parser.parse(tokens) ==
             {:ok, {:op, {:selector_and_value, "my_selector", :equal, 123.5}}}
  end

  test "Selector with positive float value" do
    payload = "my_selector==+123.5"
    {:ok, tokens, _} = :fiql_lexer.string(to_charlist(payload))

    assert :fiql_parser.parse(tokens) ==
             {:ok, {:op, {:selector_and_value, "my_selector", :equal, 123.5}}}
  end

  test "Selector with negative float value" do
    payload = "my_selector==-123.5"
    {:ok, tokens, _} = :fiql_lexer.string(to_charlist(payload))

    assert :fiql_parser.parse(tokens) ==
             {:ok, {:op, {:selector_and_value, "my_selector", :equal, -123.5}}}
  end

  test "Selector with complex float value" do
    payload = "my_selector==-123.5e-10"
    {:ok, tokens, _} = :fiql_lexer.string(to_charlist(payload))

    assert :fiql_parser.parse(tokens) ==
             {:ok, {:op, {:selector_and_value, "my_selector", :equal, -123.5e-10}}}
  end

  test "Selector with double quoted value" do
    payload = "my_selector==\"my value != weird;,\""
    {:ok, tokens, _} = :fiql_lexer.string(to_charlist(payload))

    assert :fiql_parser.parse(tokens) ==
             {:ok, {:op, {:selector_and_value, "my_selector", :equal, "my value != weird;,"}}}
  end

  test "Selector with complex double quoted value" do
    payload = "my_selector==\"my \\\"value\\\" != 'weird';,\""
    {:ok, tokens, _} = :fiql_lexer.string(to_charlist(payload))

    assert :fiql_parser.parse(tokens) ==
             {:ok,
              {:op, {:selector_and_value, "my_selector", :equal, "my \"value\" != 'weird';,"}}}
  end

  test "Selector with single quoted value" do
    payload = "my_selector=='my value != weird;,'"
    {:ok, tokens, _} = :fiql_lexer.string(to_charlist(payload))

    assert :fiql_parser.parse(tokens) ==
             {:ok, {:op, {:selector_and_value, "my_selector", :equal, "my value != weird;,"}}}
  end

  test "Selector with complex single quoted value" do
    payload = "my_selector=='my \"value\" != \\'weird\\';,'"
    {:ok, tokens, _} = :fiql_lexer.string(to_charlist(payload))

    assert :fiql_parser.parse(tokens) ==
             {:ok,
              {:op, {:selector_and_value, "my_selector", :equal, "my \"value\" != 'weird';,"}}}
  end

  test "Selector with list value" do
    payload = "my_selector==(1, \"hello world\", (true, false))"
    {:ok, tokens, _} = :fiql_lexer.string(to_charlist(payload))

    assert :fiql_parser.parse(tokens) ==
             {:ok,
              {:op,
               {:selector_and_value, "my_selector", :equal, [1, "hello world", [true, false]]}}}
  end

  test "Equal comparison" do
    payload = "my_selector1==value1"
    {:ok, tokens, _} = :fiql_lexer.string(to_charlist(payload))

    assert :fiql_parser.parse(tokens) ==
             {:ok, {:op, {:selector_and_value, "my_selector1", :equal, "value1"}}}
  end

  test "Not equal comparison" do
    payload = "my_selector1!=value1"
    {:ok, tokens, _} = :fiql_lexer.string(to_charlist(payload))

    assert :fiql_parser.parse(tokens) ==
             {:ok, {:op, {:selector_and_value, "my_selector1", :not_equal, "value1"}}}
  end

  test "Custom comparison" do
    payload = "my_selector1=ge=value1"
    {:ok, tokens, _} = :fiql_lexer.string(to_charlist(payload))

    assert :fiql_parser.parse(tokens) ==
             {:ok, {:op, {:selector_and_value, "my_selector1", {:comparison, "ge"}, "value1"}}}
  end

  test "Multiple selectors separated by or and and" do
    payload = "my_selector1==value1,my_selector2==value2;my_selector3==value3"
    {:ok, tokens, _} = :fiql_lexer.string(to_charlist(payload))

    assert :fiql_parser.parse(tokens) ==
             {:ok,
              {:or_op, {:op, {:selector_and_value, "my_selector1", :equal, "value1"}},
               {:and_op, {:op, {:selector_and_value, "my_selector2", :equal, "value2"}},
                {:op, {:selector_and_value, "my_selector3", :equal, "value3"}}}}}
  end

  test "Multiple ORs" do
    payload = "my_selector1==value1,my_selector2==value2,my_selector3==value3"
    {:ok, tokens, _} = :fiql_lexer.string(to_charlist(payload))

    assert :fiql_parser.parse(tokens) ==
             {:ok,
              {:or_op, {:op, {:selector_and_value, "my_selector1", :equal, "value1"}},
               {:or_op, {:op, {:selector_and_value, "my_selector2", :equal, "value2"}},
                {:op, {:selector_and_value, "my_selector3", :equal, "value3"}}}}}
  end

  test "Multiple ANDs" do
    payload = "my_selector1==value1;my_selector2==value2;my_selector3==value3"
    {:ok, tokens, _} = :fiql_lexer.string(to_charlist(payload))

    assert :fiql_parser.parse(tokens) ==
             {:ok,
              {:and_op, {:op, {:selector_and_value, "my_selector1", :equal, "value1"}},
               {:and_op, {:op, {:selector_and_value, "my_selector2", :equal, "value2"}},
                {:op, {:selector_and_value, "my_selector3", :equal, "value3"}}}}}
  end

  test "Multiple ORs (4)" do
    payload =
      "my_selector1==value1,my_selector2==value2,my_selector3==value3,my_selector4==value4"

    {:ok, tokens, _} = :fiql_lexer.string(to_charlist(payload))

    assert :fiql_parser.parse(tokens) ==
             {:ok,
              {:or_op, {:op, {:selector_and_value, "my_selector1", :equal, "value1"}},
               {:or_op, {:op, {:selector_and_value, "my_selector2", :equal, "value2"}},
                {:or_op, {:op, {:selector_and_value, "my_selector3", :equal, "value3"}},
                 {:op, {:selector_and_value, "my_selector4", :equal, "value4"}}}}}}
  end

  test "Multiple ANDs (4)" do
    payload =
      "my_selector1==value1;my_selector2==value2;my_selector3==value3;my_selector4==value4"

    {:ok, tokens, _} = :fiql_lexer.string(to_charlist(payload))

    assert :fiql_parser.parse(tokens) ==
             {:ok,
              {:and_op, {:op, {:selector_and_value, "my_selector1", :equal, "value1"}},
               {:and_op, {:op, {:selector_and_value, "my_selector2", :equal, "value2"}},
                {:and_op, {:op, {:selector_and_value, "my_selector3", :equal, "value3"}},
                 {:op, {:selector_and_value, "my_selector4", :equal, "value4"}}}}}}
  end

  test "Multiple selectors separated by and and or" do
    payload = "my_selector1==value1,my_selector2==value2;my_selector3==value3"
    {:ok, tokens, _} = :fiql_lexer.string(to_charlist(payload))

    assert :fiql_parser.parse(tokens) ==
             {:ok,
              {:or_op, {:op, {:selector_and_value, "my_selector1", :equal, "value1"}},
               {:and_op, {:op, {:selector_and_value, "my_selector2", :equal, "value2"}},
                {:op, {:selector_and_value, "my_selector3", :equal, "value3"}}}}}
  end

  test "Parenthesis with and, or" do
    payload = "my_selector1==value1;(my_selector2==value2,my_selector3==value3)"
    {:ok, tokens, _} = :fiql_lexer.string(to_charlist(payload))

    assert :fiql_parser.parse(tokens) ==
             {:ok,
              {:and_op, {:op, {:selector_and_value, "my_selector1", :equal, "value1"}},
               {:or_op, {:op, {:selector_and_value, "my_selector2", :equal, "value2"}},
                {:op, {:selector_and_value, "my_selector3", :equal, "value3"}}}}}
  end

  test "Parenthesis with or, and" do
    payload = "my_selector1==value1,(my_selector2==value2;my_selector3==value3)"
    {:ok, tokens, _} = :fiql_lexer.string(to_charlist(payload))

    assert :fiql_parser.parse(tokens) ==
             {:ok,
              {:or_op, {:op, {:selector_and_value, "my_selector1", :equal, "value1"}},
               {:and_op, {:op, {:selector_and_value, "my_selector2", :equal, "value2"}},
                {:op, {:selector_and_value, "my_selector3", :equal, "value3"}}}}}
  end

  test "Missing parenthesis" do
    payload = "(my_selector1==value1,(my_selector2==value2;my_selector3==value3)"
    {:ok, tokens, _} = :fiql_lexer.string(to_charlist(payload))

    assert :fiql_parser.parse(tokens) ==
             {:error, {1, :fiql_parser, ['syntax error before: ', []]}}
  end

  test "Missing parenthesis in list" do
    payload = "my_selector1==(value1, value2, (value3)"
    {:ok, tokens, _} = :fiql_lexer.string(to_charlist(payload))

    assert :fiql_parser.parse(tokens) ==
             {:error, {1, :fiql_parser, ['syntax error before: ', []]}}
  end
end
