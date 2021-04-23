defmodule FIQLEx.QueryBuilders.SQLQueryBuilder do
  @moduledoc ~S"""
  Builds SQL queries from FIQL AST.

  Possible options for this query builder are:

  * `table`: The table name to use in the `FROM` statement (defaults to `"table"`)
  * `select`: `SELECT` statement to build (_see below_).
  * `ecto`: Tuple containing the ecto repo and the ecto schema to use for the query. This will execute the query and return the result as a list
  * `only`: A list with the only fields to accept in the query (if `only` and `except` are both provided, `only` is used)
  * `except`: A list with the fields to reject in the query (if `only` and `except` are both provided, `only` is used)
  * `order_by`: A string order by to be added to the query
  * `limit`: A limit for the query
  * `offset`: An offset for the query
  * `case_sensitive`: Boolean value (default to true) to set equals case sensitive or not
  * `transformer`: Function that takes a selector and its value as parameter and must return the transformed value


  ### Select option

  Possible values of the `select` option are:

  * `:all`: use `SELECT *` (default value)
  * `:from_selectors`: Searches for all selectors in the FIQL AST and use them as `SELECT` statement.
  For instance, for the following query: `age=ge=25;name==*Doe`, the `SELECT` statement will be `SELECT age, name`
  * `selectors`: You specify a list of items you want to use in the `SELECT` statement.

  ### Ecto option

  You can directly execute the SQL query in an Ecto context by proving in a tuple the repo and the schema to use.

  For instance:

  ```elixir
  FIQLEx.build_query(FIQLEx.parse!("name==John"), FIQLEx.QueryBuilders.SQLQueryBuilder, echo: {Repo, User})
  ```

  May return something like this:

  ```elixir
  {:ok, [%User{name: "John", age: 18}, %User{name: "John", age: 21}]}
  ```

  ## Examples

      iex> FIQLEx.build_query(FIQLEx.parse!("name==John"), FIQLEx.QueryBuilders.SQLQueryBuilder, select: :from_selectors)
      {:ok, "SELECT name FROM table WHERE name = 'John'"}

      iex> FIQLEx.build_query(FIQLEx.parse!("name==cafè"), FIQLEx.QueryBuilders.SQLQueryBuilder, select: :from_selectors)
      {:ok, "SELECT name FROM table WHERE name = 'cafè'"}

      iex> FIQLEx.build_query(FIQLEx.parse!("name==John"), FIQLEx.QueryBuilders.SQLQueryBuilder, select: :from_selectors, table: "author")
      {:ok, "SELECT name FROM author WHERE name = 'John'"}

      iex> FIQLEx.build_query(FIQLEx.parse!("name==John"), FIQLEx.QueryBuilders.SQLQueryBuilder, select: :all)
      {:ok, "SELECT * FROM table WHERE name = 'John'"}

      iex> FIQLEx.build_query(FIQLEx.parse!("name==John"), FIQLEx.QueryBuilders.SQLQueryBuilder, select: ["another", "other"])
      {:ok, "SELECT another, other FROM table WHERE name = 'John'"}

      iex> FIQLEx.build_query(FIQLEx.parse!("name==John;(age=gt=25,age=lt=18)"), FIQLEx.QueryBuilders.SQLQueryBuilder, select: :from_selectors)
      {:ok, "SELECT name, age FROM table WHERE (name = 'John' AND (age > 25 OR age < 18))"}

      iex> FIQLEx.build_query(FIQLEx.parse!("name=ge=John"), FIQLEx.QueryBuilders.SQLQueryBuilder, select: :from_selectors)
      {:error, :invalid_format}

      iex> FIQLEx.build_query(FIQLEx.parse!("name=ge=2019-02-02T18:23:03Z"), FIQLEx.QueryBuilders.SQLQueryBuilder, select: :from_selectors)
      {:ok, "SELECT name FROM table WHERE name >= '2019-02-02T18:23:03Z'"}

      iex> FIQLEx.build_query(FIQLEx.parse!("name!=12.4"), FIQLEx.QueryBuilders.SQLQueryBuilder, select: :from_selectors)
      {:ok, "SELECT name FROM table WHERE name <> 12.4"}

      iex> FIQLEx.build_query(FIQLEx.parse!("name!=true"), FIQLEx.QueryBuilders.SQLQueryBuilder, select: :from_selectors)
      {:ok, "SELECT name FROM table WHERE name <> true"}

      iex> FIQLEx.build_query(FIQLEx.parse!("name!=false"), FIQLEx.QueryBuilders.SQLQueryBuilder, select: :from_selectors)
      {:ok, "SELECT name FROM table WHERE name <> false"}

      iex> FIQLEx.build_query(FIQLEx.parse!("name"), FIQLEx.QueryBuilders.SQLQueryBuilder, select: :from_selectors)
      {:ok, "SELECT name FROM table WHERE name IS NOT NULL"}

      iex> FIQLEx.build_query(FIQLEx.parse!("name!=(1,2,Hello)"), FIQLEx.QueryBuilders.SQLQueryBuilder, select: :from_selectors)
      {:ok, "SELECT name FROM table WHERE name NOT IN (1, 2, 'Hello')"}

      iex> FIQLEx.build_query(FIQLEx.parse!("name!='Hello \\'World'"), FIQLEx.QueryBuilders.SQLQueryBuilder, select: :from_selectors)
      {:ok, "SELECT name FROM table WHERE name <> 'Hello ''World'"}

      iex> FIQLEx.build_query(FIQLEx.parse!("name!=*Hello"), FIQLEx.QueryBuilders.SQLQueryBuilder, select: :from_selectors)
      {:ok, "SELECT name FROM table WHERE name NOT LIKE '%Hello'"}

      iex> FIQLEx.build_query(FIQLEx.parse!("name==Hello*"), FIQLEx.QueryBuilders.SQLQueryBuilder, select: :from_selectors)
      {:ok, "SELECT name FROM table WHERE name LIKE 'Hello%'"}

      iex> FIQLEx.build_query(FIQLEx.parse!("name==Hello;age=ge=10;friend==true"), FIQLEx.QueryBuilders.SQLQueryBuilder, select: :from_selectors)
      {:ok, "SELECT name, age, friend FROM table WHERE (name = 'Hello' AND (age >= 10 AND friend = true))"}

      iex> FIQLEx.build_query(FIQLEx.parse!("name==Hello,age=ge=10,friend==true"), FIQLEx.QueryBuilders.SQLQueryBuilder, select: :from_selectors)
      {:ok, "SELECT name, age, friend FROM table WHERE (name = 'Hello' OR (age >= 10 OR friend = true))"}

      iex> FIQLEx.build_query(FIQLEx.parse!("name==Hello;age=ge=10;friend==true;ok"), FIQLEx.QueryBuilders.SQLQueryBuilder, select: :from_selectors)
      {:ok, "SELECT name, age, friend, ok FROM table WHERE (name = 'Hello' AND (age >= 10 AND (friend = true AND ok IS NOT NULL)))"}

      iex> FIQLEx.build_query(FIQLEx.parse!("name==Hello,age=ge=10,friend==true,ok"), FIQLEx.QueryBuilders.SQLQueryBuilder, select: :from_selectors)
      {:ok, "SELECT name, age, friend, ok FROM table WHERE (name = 'Hello' OR (age >= 10 OR (friend = true OR ok IS NOT NULL)))"}

      iex> FIQLEx.build_query(FIQLEx.parse!("name==John"), FIQLEx.QueryBuilders.SQLQueryBuilder, only: ["bad"])
      {:error, :selector_not_allowed}

      iex> FIQLEx.build_query(FIQLEx.parse!("name==John"), FIQLEx.QueryBuilders.SQLQueryBuilder, only: ["name"])
      {:ok, "SELECT * FROM table WHERE name = 'John'"}

      iex> FIQLEx.build_query(FIQLEx.parse!("name==John"), FIQLEx.QueryBuilders.SQLQueryBuilder, except: ["name"])
      {:error, :selector_not_allowed}

      iex> FIQLEx.build_query(FIQLEx.parse!("name==John"), FIQLEx.QueryBuilders.SQLQueryBuilder, except: ["bad"])
      {:ok, "SELECT * FROM table WHERE name = 'John'"}

      iex> FIQLEx.build_query(FIQLEx.parse!("name==John"), FIQLEx.QueryBuilders.SQLQueryBuilder, order_by: "name DESC")
      {:ok, "SELECT * FROM table WHERE name = 'John' ORDER BY name DESC"}

      iex> FIQLEx.build_query(FIQLEx.parse!("name==John"), FIQLEx.QueryBuilders.SQLQueryBuilder, limit: "10")
      {:ok, "SELECT * FROM table WHERE name = 'John' LIMIT 10"}

      iex> FIQLEx.build_query(FIQLEx.parse!("name==John"), FIQLEx.QueryBuilders.SQLQueryBuilder, offset: "10")
      {:ok, "SELECT * FROM table WHERE name = 'John' OFFSET 10"}

      iex> FIQLEx.build_query(FIQLEx.parse!("name==John"), FIQLEx.QueryBuilders.SQLQueryBuilder, order_by: "name", limit: "5", offset: "10")
      {:ok, "SELECT * FROM table WHERE name = 'John' ORDER BY name LIMIT 5 OFFSET 10"}

      iex> FIQLEx.build_query(FIQLEx.parse!("name==John"), FIQLEx.QueryBuilders.SQLQueryBuilder, select: :from_selectors, case_sensitive: false)
      {:ok, "SELECT name FROM table WHERE LOWER(name) = LOWER('John')"}

      iex> FIQLEx.build_query(FIQLEx.parse!("name!=John"), FIQLEx.QueryBuilders.SQLQueryBuilder, select: :from_selectors, case_sensitive: false)
      {:ok, "SELECT name FROM table WHERE LOWER(name) <> LOWER('John')"}

      iex> FIQLEx.build_query(FIQLEx.parse!("name!=*Hello"), FIQLEx.QueryBuilders.SQLQueryBuilder, select: :from_selectors, case_sensitive: false)
      {:ok, "SELECT name FROM table WHERE name NOT ILIKE '%Hello'"}

      iex> FIQLEx.build_query(FIQLEx.parse!("name==Hello*"), FIQLEx.QueryBuilders.SQLQueryBuilder, select: :from_selectors, case_sensitive: false)
      {:ok, "SELECT name FROM table WHERE name ILIKE 'Hello%'"}

      iex> FIQLEx.build_query(FIQLEx.parse!("name==John;age==18"), FIQLEx.QueryBuilders.SQLQueryBuilder, select: :from_selectors, transformer: fn selector, value -> if(selector == "name", do: "Johny", else: value) end)
      {:ok, "SELECT name, age FROM table WHERE (name = 'Johny' AND age = 18)"}
  """
  use FIQLEx.QueryBuilder

  @impl true
  def init(_ast, opts) do
    {"", opts}
  end

  @impl true
  def build(ast, {query, opts}) do
    query = :binary.bin_to_list(query) |> to_string

    select =
      case Keyword.get(opts, :select, :all) do
        :all ->
          "*"

        :from_selectors ->
          ast
          |> get_selectors()
          |> Enum.join(", ")

        selectors ->
          selectors |> Enum.join(", ")
      end

    table = Keyword.get(opts, :table, "table")
    order_by = Keyword.get(opts, :order_by, "")
    limit = Keyword.get(opts, :limit, "")
    offset = Keyword.get(opts, :offset, "")

    final_query =
      ("SELECT " <> select <> " FROM " <> table <> " WHERE " <> query)
      |> add_to_query("ORDER BY", order_by)
      |> add_to_query("LIMIT", limit)
      |> add_to_query("OFFSET", offset)

    case Keyword.get(opts, :ecto, nil) do
      nil ->
        {:ok, final_query}

      {repo, model} ->
        Ecto.Adapters.SQL.query(repo, final_query, [])
        |> load_into_model(repo, model)
    end
  end

  defp add_to_query(query, _command, ""), do: query
  defp add_to_query(query, command, suffix), do: query <> " " <> command <> " " <> suffix

  defp load_into_model({:ok, %{rows: rows, columns: columns}}, repo, model) do
    {:ok,
     Enum.map(rows, fn row ->
       fields =
         Enum.reduce(Enum.zip(columns, row), %{}, fn {key, value}, map ->
           Map.put(map, key, value)
         end)

       repo.load(model, fields)
     end)}
  end

  defp load_into_model(_response, _repo, _model) do
    {:error, :invalid_response}
  end

  defp is_selector_allowed(selector, opts) do
    case Keyword.get(opts, :only, nil) do
      nil ->
        case Keyword.get(opts, :except, nil) do
          nil ->
            true

          fields ->
            not Enum.member?(fields, selector)
        end

      fields ->
        Enum.member?(fields, selector)
    end
  end

  defp is_case_insensitive(opts) do
    not Keyword.get(opts, :case_sensitive, true)
  end

  def binary_equal(selector_name, value, opts) do
    if is_case_insensitive(opts) do
      "LOWER(" <> selector_name <> ") = LOWER(" <> value <> ")"
    else
      selector_name <> " = " <> value
    end
  end

  def binary_like(selector_name, value, opts) do
    if is_case_insensitive(opts) do
      selector_name <> " ILIKE " <> String.replace(escape_string(value), "*", "%", global: true)
    else
      selector_name <> " LIKE " <> String.replace(escape_string(value), "*", "%", global: true)
    end
  end

  def binary_not_equal(selector_name, value, opts) do
    if is_case_insensitive(opts) do
      "LOWER(" <> selector_name <> ") <> LOWER(" <> value <> ")"
    else
      selector_name <> " <> " <> value
    end
  end

  def binary_not_like(selector_name, value, opts) do
    if is_case_insensitive(opts) do
      selector_name <>
        " NOT ILIKE " <> String.replace(escape_string(value), "*", "%", global: true)
    else
      selector_name <>
        " NOT LIKE " <> String.replace(escape_string(value), "*", "%", global: true)
    end
  end

  def identity_transformer(_selector, value), do: value

  @impl true
  def handle_or_expression(exp1, exp2, ast, {query, opts}) do
    with {:ok, {left, _opts}} <- handle_ast(exp1, ast, {query, opts}),
         {:ok, {right, _opts}} <- handle_ast(exp2, ast, {query, opts}) do
      {:ok, {"(" <> left <> " OR " <> right <> ")", opts}}
    else
      {:error, err} -> {:error, err}
    end
  end

  @impl true
  def handle_and_expression(exp1, exp2, ast, {query, opts}) do
    with {:ok, {left, _opts}} <- handle_ast(exp1, ast, {query, opts}),
         {:ok, {right, _opts}} <- handle_ast(exp2, ast, {query, opts}) do
      {:ok, {"(" <> left <> " AND " <> right <> ")", opts}}
    else
      {:error, err} -> {:error, err}
    end
  end

  @impl true
  def handle_expression(exp, ast, {query, opts}) do
    with {:ok, {constraint, _opts}} <- handle_ast(exp, ast, {query, opts}) do
      {:ok, {constraint, opts}}
    else
      {:error, err} -> {:error, err}
    end
  end

  @impl true
  def handle_selector(selector_name, _ast, {_query, opts}) do
    if is_selector_allowed(selector_name, opts) do
      {:ok, {selector_name <> " IS NOT NULL", opts}}
    else
      {:error, :selector_not_allowed}
    end
  end

  @impl true
  def handle_selector_and_value(selector_name, op, value, ast, {query, opts}) do
    new_value = Keyword.get(opts, :transformer, &identity_transformer/2).(selector_name, value)

    do_handle_selector_and_value(selector_name, op, new_value, ast, {query, opts})
  end

  defp do_handle_selector_and_value(selector_name, :equal, value, _ast, {_query, opts})
       when is_binary(value) do
    if is_selector_allowed(selector_name, opts) do
      if String.starts_with?(value, "*") || String.ends_with?(value, "*") do
        {:ok, {binary_like(selector_name, value, opts), opts}}
      else
        {:ok, {binary_equal(selector_name, escape_string(value), opts), opts}}
      end
    else
      {:error, :selector_not_allowed}
    end
  end

  defp do_handle_selector_and_value(selector_name, :equal, value, _ast, {_query, opts})
       when is_list(value) do
    if is_selector_allowed(selector_name, opts) do
      values = value |> escape_list() |> Enum.join(", ")
      {:ok, {selector_name <> " IN (" <> values <> ")", opts}}
    else
      {:error, :selector_not_allowed}
    end
  end

  defp do_handle_selector_and_value(selector_name, :equal, true, _ast, {_query, opts}) do
    if is_selector_allowed(selector_name, opts) do
      {:ok, {selector_name <> " = true", opts}}
    else
      {:error, :selector_not_allowed}
    end
  end

  defp do_handle_selector_and_value(selector_name, :equal, false, _ast, {_query, opts}) do
    if is_selector_allowed(selector_name, opts) do
      {:ok, {selector_name <> " = false", opts}}
    else
      {:error, :selector_not_allowed}
    end
  end

  defp do_handle_selector_and_value(selector_name, :equal, value, _ast, {_query, opts}) do
    if is_selector_allowed(selector_name, opts) do
      {:ok, {binary_equal(selector_name, to_string(value), opts), opts}}
    else
      {:error, :selector_not_allowed}
    end
  end

  defp do_handle_selector_and_value(selector_name, :not_equal, value, _ast, {_query, opts})
       when is_binary(value) do
    if is_selector_allowed(selector_name, opts) do
      if String.starts_with?(value, "*") || String.ends_with?(value, "*") do
        {:ok, {binary_not_like(selector_name, value, opts), opts}}
      else
        {:ok, {binary_not_equal(selector_name, escape_string(value), opts), opts}}
      end
    else
      {:error, :selector_not_allowed}
    end
  end

  defp do_handle_selector_and_value(selector_name, :not_equal, value, _ast, {_query, opts})
       when is_list(value) do
    if is_selector_allowed(selector_name, opts) do
      values = value |> escape_list() |> Enum.join(", ")
      {:ok, {selector_name <> " NOT IN (" <> values <> ")", opts}}
    else
      {:error, :selector_not_allowed}
    end
  end

  defp do_handle_selector_and_value(selector_name, :not_equal, true, _ast, {_query, opts}) do
    if is_selector_allowed(selector_name, opts) do
      {:ok, {selector_name <> " <> true", opts}}
    else
      {:error, :selector_not_allowed}
    end
  end

  defp do_handle_selector_and_value(selector_name, :not_equal, false, _ast, {_query, opts}) do
    if is_selector_allowed(selector_name, opts) do
      {:ok, {selector_name <> " <> false", opts}}
    else
      {:error, :selector_not_allowed}
    end
  end

  defp do_handle_selector_and_value(selector_name, :not_equal, value, _ast, {_query, opts}) do
    if is_selector_allowed(selector_name, opts) do
      {:ok, {binary_not_equal(selector_name, to_string(value), opts), opts}}
    else
      {:error, :selector_not_allowed}
    end
  end

  @impl true
  def handle_selector_and_value_with_comparison(selector_name, op, value, ast, {query, opts}) do
    new_value = Keyword.get(opts, :transformer, &identity_transformer/2).(selector_name, value)

    do_handle_selector_and_value_with_comparison(selector_name, op, new_value, ast, {query, opts})
  end

  defp do_handle_selector_and_value_with_comparison(
         selector_name,
         "ge",
         value,
         _ast,
         {_query, opts}
       )
       when is_number(value) do
    if is_selector_allowed(selector_name, opts) do
      {:ok, {selector_name <> " >= " <> to_string(value), opts}}
    else
      {:error, :selector_not_allowed}
    end
  end

  defp do_handle_selector_and_value_with_comparison(
         selector_name,
         "gt",
         value,
         _ast,
         {_query, opts}
       )
       when is_number(value) do
    if is_selector_allowed(selector_name, opts) do
      {:ok, {selector_name <> " > " <> to_string(value), opts}}
    else
      {:error, :selector_not_allowed}
    end
  end

  defp do_handle_selector_and_value_with_comparison(
         selector_name,
         "le",
         value,
         _ast,
         {_query, opts}
       )
       when is_number(value) do
    if is_selector_allowed(selector_name, opts) do
      {:ok, {selector_name <> " <= " <> to_string(value), opts}}
    else
      {:error, :selector_not_allowed}
    end
  end

  defp do_handle_selector_and_value_with_comparison(
         selector_name,
         "lt",
         value,
         _ast,
         {_query, opts}
       )
       when is_number(value) do
    if is_selector_allowed(selector_name, opts) do
      {:ok, {selector_name <> " < " <> to_string(value), opts}}
    else
      {:error, :selector_not_allowed}
    end
  end

  defp do_handle_selector_and_value_with_comparison(
         selector_name,
         "ge",
         value,
         _ast,
         {_query, opts}
       )
       when is_binary(value) do
    if is_selector_allowed(selector_name, opts) do
      case DateTime.from_iso8601(value) do
        {:ok, _date, _} -> {:ok, {selector_name <> " >= '" <> value <> "'", opts}}
        {:error, err} -> {:error, err}
      end
    else
      {:error, :selector_not_allowed}
    end
  end

  defp do_handle_selector_and_value_with_comparison(
         selector_name,
         "gt",
         value,
         _ast,
         {_query, opts}
       )
       when is_binary(value) do
    if is_selector_allowed(selector_name, opts) do
      case DateTime.from_iso8601(value) do
        {:ok, _date, _} -> {:ok, {selector_name <> " > '" <> value <> "'", opts}}
        {:error, err} -> {:error, err}
      end
    else
      {:error, :selector_not_allowed}
    end
  end

  defp do_handle_selector_and_value_with_comparison(
         selector_name,
         "le",
         value,
         _ast,
         {_query, opts}
       )
       when is_binary(value) do
    if is_selector_allowed(selector_name, opts) do
      case DateTime.from_iso8601(value) do
        {:ok, _date, _} -> {:ok, {selector_name <> " <= '" <> value <> "'", opts}}
        {:error, err} -> {:error, err}
      end
    else
      {:error, :selector_not_allowed}
    end
  end

  defp do_handle_selector_and_value_with_comparison(
         selector_name,
         "lt",
         value,
         _ast,
         {_query, opts}
       )
       when is_binary(value) do
    if is_selector_allowed(selector_name, opts) do
      case DateTime.from_iso8601(value) do
        {:ok, _date, _} -> {:ok, {selector_name <> " < '" <> value <> "'", opts}}
        {:error, err} -> {:error, err}
      end
    else
      {:error, :selector_not_allowed}
    end
  end

  defp do_handle_selector_and_value_with_comparison(_selector_name, op, value, _ast, _state)
       when is_number(value) do
    {:error, "Unsupported " <> op <> " operator"}
  end

  defp do_handle_selector_and_value_with_comparison(_selector_name, _op, value, _ast, _state) do
    {:error,
     "Comparisons must be done against number or date values (got: " <> to_string(value) <> ")"}
  end

  defp escape_string(str) when is_binary(str),
    do: "'" <> String.replace(str, "'", "''", global: true) <> "'"

  defp escape_string(str), do: to_string(str)

  defp escape_list(list), do: Enum.map(list, &escape_string/1)
end
