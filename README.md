# fiqlex

[FIQL](http://tools.ietf.org/html/draft-nottingham-atompub-fiql-00) (Feed Item Query Language)
is a URI-friendly syntax for expressing filters.

FIQL looks like this:

```
fiql = "author.age=ge=25;author.name==*Doe"
```

Using this module you will be able to parse a FIQL string and to build a query for any
system (SQL, Elasticsearch, etc...) from it.

## Grammar

If you want to know more about FIQL grammar please check the [RFC](http://tools.ietf.org/html/draft-nottingham-atompub-fiql-00), and my [lexer](src/fiql_lexer.xrl) and [parser](src/fiql_lexer.yrl)

## Quick start

First, add this module to your `mix.exs` file:

```elixir
defp deps do
  [
    {:fiqlex, "~> 1.0.0"},
  ]
end
```

Given a FIQL string like:

```
fiql = "author.age=ge=25;author.name==*Doe"
```

Pass it to the `parse/1` or `parse1!/1` functions to retrieve an AST of the FIQL string:

```
{:ok, ast} = FIQLEx.parse(fiql)
```

Then you can use this AST to build you own query for your system or use our built-in
query builders like `FIQLEx.QueryBuilders.SQLQueryBuilder`:

```
{:ok, sql_query} = FIQLEx.build_query(ast, FIQLEx.QueryBuilders.SQLQueryBuilder, table: "author")
```

Here, `sql_query` is `SELECT * FROM author WHERE (author.age >= 25 AND author.name LIKE '%Doe')`.

You can use your own query builder by providing your own module that uses `FIQLEx.QueryBuilder`
as second argument of `build_query/3`.

## Documentation

Documentation can be found in [hexdoc](http://hexdocs.pm/fiqlex)

## Tests

You can run tests with: 

```
mix test
```
