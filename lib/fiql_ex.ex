defmodule FIQLEx do
  @moduledoc """
  Documentation for FIQLEx.
  """

  @doc """
  Hello world.

  ## Examples

      iex> FIQLEx.hello()
      :world

  """
  @spec parse(binary) :: list
  def parse(str) do
    {:ok, tokens, o} = str |> to_charlist() |> IO.inspect() |> :fiql_lexer.string()
    IO.inspect({tokens, o}, label: "LEXER")
    {:ok, list} = :fiql_parser.parse(tokens)
    list
  end
end
