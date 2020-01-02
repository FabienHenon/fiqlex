defmodule FIQLEx do
  @moduledoc """
  [FIQL](http://tools.ietf.org/html/draft-nottingham-atompub-fiql-00) (Feed Item Query Language)
  is a URI-friendly syntax for expressing filters.

  Using this module you will be able to parse a FIQL string and to build a query for any
  system (SQL, Elasticsearch, etc...) from it.
  """

  @type ast() :: any()

  @doc """
  Parses the FIQL string and returns an AST representation of the query to be built to
  any other query (SQL, Elasticsearch) with the `build_query/3` function.

  Returns `{:ok, ast}` if everything is fine and `{:error, reason}` in case of error in the
  FIQL.
  """
  @spec parse(binary) :: {:ok, ast()} | {:error, any()}
  def parse(str) do
    with {:ok, tokens, _end_line} <- str |> to_charlist() |> :fiql_lexer.string(),
         {:ok, ast} <- :fiql_parser.parse(tokens) do
      {:ok, ast}
    else
      {_, reason, _} ->
        {:error, reason}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Same as `parse/1` but returns the AST or raises an exception.

  """
  @spec parse!(binary) :: ast
  def parse!(str) do
    case parse(str) do
      {:ok, ast} -> ast
      {:error, err} -> throw(err)
    end
  end

  @doc """
  Use an AST to build a query in the way you want. For instance you could create a
  query for Elasticsearch from a FIQL AST, or use the `FIQLEx.SQLQueryBuilder` module
  to build an SQL query from a FIQL AST.

  Parameters are:

  * `ast`: The AST to transform to a query for another system
  * `module`: The module to use for the AST traversal
  * `opts`: Options you want to pass to the `init/2` function of your `module`

  This function returns `{:ok, query}` with your created query if everything is fine, or
  `{:error, reason}` if there is something wrong.

  ```
  query = "author.age=ge=25;author.name==*Doe"
  {:ok, ast} = FIQLEx.parse(query)
  {:ok, query} = FIQLEx.build_query(ast, MyQueryBuilder)
  ```

  See the documentation of the `FIQLEx.QueryBuilder` module to learn more about the AST
  traversal.
  """
  @spec build_query(ast(), atom(), Keyword.t()) :: {:ok, any()} | {:error, any()}
  def build_query(ast, module, opts \\ []) do
    state = apply(module, :init, [ast, opts])

    with {:ok, state} <- run_ast(ast, ast, module, state) do
      apply(module, :build, [ast, state])
    else
      {:error, err} -> {:error, err}
    end
  end

  @doc """
  This function will go deeper in the ast traversal.

  Parameters are:

  * `curr_ast`: The AST we want to go deeper with
  * `ast`: The global AST
  * `module`: The module to use for the traversal
  * `state`: The current state of your query builder

  The function returns `{:ok, state}` if everything is fine, and `{:error, reason}`
  if there is an error
  """
  @spec handle_ast(ast(), ast(), atom(), any()) :: {:ok, any()} | {:error, any()}
  def handle_ast(curr_ast, ast, module, state) do
    run_ast(curr_ast, ast, module, state)
  end

  @doc """
  Same as `handle_ast/4` but returns the `state` or raises an exception.
  """
  @spec handle_ast!(ast(), ast(), atom(), any()) :: any()
  def handle_ast!(curr_ast, ast, module, state) do
    case handle_ast(curr_ast, ast, module, state) do
      {:ok, result} -> result
      {:error, err} -> throw(err)
    end
  end

  defp run_ast({:or_op, exp1, exp2}, ast, module, state) do
    apply(module, :handle_or_expression, [exp1, exp2, ast, state])
  end

  defp run_ast({:and_op, exp1, exp2}, ast, module, state) do
    apply(module, :handle_and_expression, [exp1, exp2, ast, state])
  end

  defp run_ast({:op, exp}, ast, module, state) do
    apply(module, :handle_expression, [exp, ast, state])
  end

  defp run_ast({:selector, selector_name}, ast, module, state) do
    apply(module, :handle_selector, [selector_name, ast, state])
  end

  defp run_ast({:selector_and_value, selector_name, :equal, value}, ast, module, state) do
    apply(module, :handle_selector_and_value, [selector_name, :equal, value, ast, state])
  end

  defp run_ast({:selector_and_value, selector_name, :not_equal, value}, ast, module, state) do
    apply(module, :handle_selector_and_value, [selector_name, :not_equal, value, ast, state])
  end

  defp run_ast(
         {:selector_and_value, selector_name, {:comparison, comparison}, value},
         ast,
         module,
         state
       ) do
    apply(module, :handle_selector_and_value_with_comparison, [
      selector_name,
      comparison,
      value,
      ast,
      state
    ])
  end
end
