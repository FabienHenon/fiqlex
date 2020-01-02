defmodule FIQLEx.SelectorsGetter do
  use FIQLEx.QueryBuilder

  @impl true
  def init(_ast, _opts), do: []

  @impl true
  def build(_ast, selectors), do: {:ok, Enum.uniq(selectors)}

  @impl true
  def handle_or_expression(exp1, exp2, ast, state) do
    {:ok, handle_ast!(exp1, ast, state) ++ handle_ast!(exp2, ast, state)}
  end

  @impl true
  def handle_and_expression(exp1, exp2, ast, state) do
    {:ok, handle_ast!(exp1, ast, state) ++ handle_ast!(exp2, ast, state)}
  end

  @impl true
  def handle_expression(exp, ast, state), do: {:ok, handle_ast!(exp, ast, state)}

  @impl true
  def handle_selector(selector, _ast, selectors), do: {:ok, [selector | selectors]}

  @impl true
  def handle_selector_and_value(selector, _op, _value, _ast, selectors),
    do: {:ok, [selector | selectors]}

  @impl true
  def handle_selector_and_value_with_comparison(selector, _op, _value, _ast, selectors),
    do: {:ok, [selector | selectors]}
end
