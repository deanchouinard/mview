defmodule Mview.Search do
  @moduledoc """
  Provides text searches via grep

  ## Examples

    iex> Search.search("/docs", "test")

  """
  alias Mview.SearchResult

  @doc """
  Takes a path and search text and returns a list of SearchResults
  """
  def search( path, stext ) do

    case System.cmd("grep", ["-n", "#{stext}" | Path.wildcard("#{path}/*")]) do
      { matches, 0 } -> String.split(matches, "\n", trim: true) |> Enum.map(fn x -> new_search_result(x) end)
      { _, _ } -> ["No matches."]
    end

  end

  defp new_search_result( str ) do
    [file, lnum, stext] = String.split(str, ":")
    fname = file |> Path.split() |> List.last
    %SearchResult{ fname: fname, line: lnum, text: stext }
  end
end
