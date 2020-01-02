defmodule FIQLEx.QueryBuilder do
  @moduledoc """
  `QueryBuilder` module has to be used to build queries from FIQL.

  You have at least to use this module and define the functions `init` and `build`.

  Here is the minimal code:

  ```
  defmodule MyQueryBuilder do
    use FIQLEx.QueryBuilder

    @impl true
    def init(ast, _opts) do
      %{}
    end

    @impl true
    def build(_ast, state) do
      {:ok, state}
    end
  end
  ```

  The you'll want to override functions like `handle_and_expression/4`, etc, ... to
  build your final query. See `SQLQueryBuilder` module for an implementation example.

  To build a new query using your module you have to parse a FIQL query and call `FIQLEx.build_query/3`

  ```
  query = "author.age=ge=25;author.name==*Doe"
  {:ok, ast} = FIQLEx.parse(query)
  {:ok, query} = FIQLEx.build_query(ast, MyQueryBuilder)
  ```
  """

  @doc """
  This callback is invoked as soon as you call the function `FIQLEx.build_query/3`.

  Parameters are:

  * `ast`: The AST returned by `FIQLEx.parse/1`
  * `options`: The options you passed to `FIQLEx.build_query/3`

  This function must return the initial state of your query builder
  """
  @callback init(ast :: FIQLEx.ast(), options :: Keyword.t()) :: state
            when state: any()

  @doc """
  This callback is invoked at the end of the call to the function `FIQLEx.build_query/3`.

  Parameters are:

  * `ast`: The AST returned by `FIQLEx.parse/1`
  * `state`: The current (and final) state of your query builder

  This function returns `{:ok, final_state}` if everything is ok, or `{:error, reason}`
  if there is something wrong
  """
  @callback build(ast :: FIQLEx.ast(), state :: any()) :: {:ok, state} | {:error, any()}
            when state: any()

  @doc """
  This callback is invoked when an OR expression is found in the query.

  Parameters are:

  * `exp1`: left side of the OR expression
  * `exp2`: right side of the OR expression
  * `ast`: The AST returned by `FIQLEx.parse/1`
  * `state`: The current state of your query builder

  This function returns `{:ok, new_state}` if everything is ok, or `{:error, reason}`
  if there is something wrong

  # Example

  ```
  author.age!=25,author.name==*Doe
  ```

  The `exp1` is `author.age!=25`
  The `exp2` is `author.name==*Doe`

  Call `handle_ast(exp, ast, state)` to go deeper in the expressions
  """
  @callback handle_or_expression(
              exp1 :: FIQLEx.ast(),
              exp2 :: FIQLEx.ast(),
              ast :: FIQLEx.ast(),
              state
            ) ::
              {:ok, state} | {:error, any()}
            when state: any()

  @doc """
  This callback is invoked when an AND expression is found in the query.

  Parameters are:

  * `exp1`: left side of the AND expression
  * `exp2`: right side of the AND expression
  * `ast`: The AST returned by `FIQLEx.parse/1`
  * `state`: The current state of your query builder

  This function returns `{:ok, new_state}` if everything is ok, or `{:error, reason}`
  if there is something wrong

  # Example

  ```
  author.age!=25;author.name==*Doe
  ```

  The `exp1` is `author.age!=25`
  The `exp2` is `author.name==*Doe`

  Call `handle_ast(exp, ast, state)` to go deeper in the expressions
  """
  @callback handle_and_expression(
              exp1 :: FIQLEx.ast(),
              exp2 :: FIQLEx.ast(),
              ast :: FIQLEx.ast(),
              state
            ) ::
              {:ok, state} | {:error, any()}
            when state: any()

  @doc """
  This callback is invoked when an expression is found in the query.
  An expression is a selector compared to a value, or just a selector.

  Parameters are:

  * `exp`: the expression
  * `ast`: The AST returned by `FIQLEx.parse/1`
  * `state`: The current state of your query builder

  This function returns `{:ok, new_state}` if everything is ok, or `{:error, reason}`
  if there is something wrong

  # Example

  ```
  author.age!=25
  ```

  This is an expression. Call `handle_ast(exp, ast, state)` to go deeper in the expression
  """
  @callback handle_expression(
              exp :: FIQLEx.ast(),
              ast :: FIQLEx.ast(),
              state
            ) ::
              {:ok, state} | {:error, any()}
            when state: any()

  @doc """
  This callback is invoked when a selector without a value to be compared to is found.

  Parameters are:

  * `selector_name`: the name of the selector
  * `ast`: The AST returned by `FIQLEx.parse/1`
  * `state`: The current state of your query builder

  This function returns `{:ok, new_state}` if everything is ok, or `{:error, reason}`
  if there is something wrong

  # Example

  ```
  author.age
  ```

  The `selector_name` is `author.age`
  """
  @callback handle_selector(
              selector_name :: binary(),
              ast :: FIQLEx.ast(),
              state
            ) ::
              {:ok, state} | {:error, any()}
            when state: any()

  @doc """
  This callback is invoked when a selector is found with a value it is compared to.

  Parameters are:

  * `selector_name`: the name of the selector
  * `op`: the comparison operator. Either `:equal` or `:not_equal`
  * `value`: The value to compare the selector to
  * `ast`: The AST returned by `FIQLEx.parse/1`
  * `state`: The current state of your query builder

  This function returns `{:ok, new_state}` if everything is ok, or `{:error, reason}`
  if there is something wrong

  # Example

  ```
  author.age==25
  ```

  The `selector_name` is `author.age`
  The `op` is `:equal`
  The `value` is `25`
  """
  @callback handle_selector_and_value(
              selector_name :: binary(),
              op :: :equal | :not_equal,
              value :: any(),
              ast :: FIQLEx.ast(),
              state
            ) ::
              {:ok, state} | {:error, any()}
            when state: any()

  @doc """
  This callback is invoked when a selector is found with a value it is compared to.
  Same as `handle_selector_and_value/5` but with a custom comparison operator

  Parameters are:

  * `selector_name`: the name of the selector
  * `op`: the comparison operator as a string
  * `value`: The value to compare the selector to
  * `ast`: The AST returned by `FIQLEx.parse/1`
  * `state`: The current state of your query builder

  This function returns `{:ok, new_state}` if everything is ok, or `{:error, reason}`
  if there is something wrong

  # Example

  ```
  author.age=ge=25
  ```

  The `selector_name` is `author.age`
  The `op` is `ge`
  The `value` is `25`
  """
  @callback handle_selector_and_value_with_comparison(
              selector_name :: binary(),
              op :: binary(),
              value :: any(),
              ast :: FIQLEx.ast(),
              state
            ) ::
              {:ok, state} | {:error, any()}
            when state: any()

  @optional_callbacks init: 2,
                      build: 2,
                      handle_or_expression: 4,
                      handle_and_expression: 4,
                      handle_expression: 3,
                      handle_selector: 3,
                      handle_selector_and_value: 5,
                      handle_selector_and_value_with_comparison: 5

  defmacro __using__(_opts) do
    quote do
      @behaviour FIQLEx.QueryBuilder

      import FIQLEx.QueryBuilder.Helpers

      @doc """
      This function will go deeper in the ast traversal.

      Parameters are:

      * `curr_ast`: The AST we want to go deeper with
      * `ast`: The global AST
      * `state`: The current state of your query builder

      The function returns `{:ok, state}` if everything is fine, and `{:error, reason}`
      if there is an error
      """
      @spec handle_ast(FIQLEx.ast(), FIQLEx.ast(), any()) ::
              {:ok, any()} | {:error, any()}
      def handle_ast(curr_ast, ast, state) do
        do_handle_ast(curr_ast, ast, __MODULE__, state)
      end

      @doc """
      Same as `handle_ast/3` but returns the `state` or raises an exception.
      """
      @spec handle_ast!(FIQLEx.ast(), FIQLEx.ast(), any()) :: any()
      def handle_ast!(curr_ast, ast, state) do
        do_handle_ast!(curr_ast, ast, __MODULE__, state)
      end

      @doc """
      Returns a list of all selectors for a given AST
      """
      @spec get_selectors(ast :: FIQLEx.ast()) :: [binary()]
      def get_selectors(ast) do
        do_get_selectors(ast)
      end

      def handle_or_expression(_exp1, _exp2, _ast, state), do: {:ok, state}
      def handle_and_expression(_exp1, _exp2, _ast, state), do: {:ok, state}
      def handle_expression(_exp, _ast, state), do: {:ok, state}
      def handle_selector(_selector_name, _ast, state), do: {:ok, state}
      def handle_selector_and_value(_selector_name, _op, _value, _ast, state), do: {:ok, state}

      def handle_selector_and_value_with_comparison(_selector_name, _op, _value, _ast, state),
        do: {:ok, state}

      defoverridable handle_or_expression: 4,
                     handle_and_expression: 4,
                     handle_expression: 3,
                     handle_selector: 3,
                     handle_selector_and_value: 5,
                     handle_selector_and_value_with_comparison: 5
    end
  end

  defmodule Helpers do
    @spec do_handle_ast(FIQLEx.ast(), FIQLEx.ast(), atom(), any()) ::
            {:ok, any()} | {:error, any()}
    def do_handle_ast(curr_ast, ast, module, state) do
      FIQLEx.handle_ast(curr_ast, ast, module, state)
    end

    @spec do_handle_ast!(FIQLEx.ast(), FIQLEx.ast(), atom(), any()) :: any()
    def do_handle_ast!(curr_ast, ast, module, state) do
      FIQLEx.handle_ast!(curr_ast, ast, module, state)
    end

    @spec do_get_selectors(ast :: FIQLEx.ast()) :: [binary()]
    def do_get_selectors(ast) do
      {:ok, selectors} = FIQLEx.build_query(ast, FIQLEx.SelectorsGetter)
      selectors
    end
  end
end
