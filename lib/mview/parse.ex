defmodule Mview.Parse do
  @moduledoc """
  Take a string from a file, break it into lines, then parse
  each line looking for internal links. Internal links are
  defined as [[page]].

  Transform the link definition to an http link.
  """

  def run() do
    test_str = "Hello this is [[test]] string, with two [[links]] in it."
    parsed_line = parse_line(test_str)

    IO.inspect List.to_string(parsed_line), label: "new_str"

    test_str = "Another line with no links."
    parsed_line = parse_line(test_str)

    IO.inspect List.to_string(parsed_line), label: "new_str"


  end

  # Receive a string and break into lines. Process each line.
  def parse_page(page) do
    String.split(page, "\n") |> Enum.reduce(fn x, acc -> [acc | "#{parse_line(x)}\n"] end) |> List.to_string

  end

  # If the line contains a link open ("[["), split the line in two and
  # process as a possible link.
  def parse_line(line) do
    split_list = String.split(line, "[[")
    case (length(split_list) > 1) do
      true -> possible_link(split_list)
      false -> split_list
    end
        
  end

  # receive a list of two strings
  # if one of them has a link closure ("]]"), process as a link
  # else append the link open ("[[") and return
  #
  def possible_link(line_parts) do
    case Enum.any?(line_parts, fn x -> String.contains?(x, "]]") end) do
      true ->
        Enum.map(line_parts, &detect_links/1)
      false ->
        List.replace_at(line_parts, 0, Enum.at(line_parts, 0) <> "[[")
    end

  end

  # If the string has a link close ("]]"), we have an internal link.
  def detect_links(str) do
    case String.contains?(str, "]]") do
      true ->
        expand_link(str)
      false ->
        str
    end
  end

  # make the internal link
  def expand_link(str) do
    length = String.length(str)
    {pos, len} = :binary.match(str, "]]")
    doc = :binary.part(str, 0, pos)
    rest = :binary.part(str, pos + len, length - (pos + len))
    "<a href=\"/page/#{doc}/\"> #{doc} </a> #{rest}"
  end

  def link(line) do
    IO.puts "hello"
    file = "one
    two
    three"

    IO.puts file

    Enum.reduce(String.graphemes(file), "", fn letter, str -> _str = str <> letter end)
    
    Enum.reduce(String.graphemes(line), {"", ""}, &expand/2 )

  end

  def expand(letter, str) do
    {acc, _ss} = str
    case letter do
      "[" ->
        _str = {acc <> "*", "["}
      _ ->
        _str = {acc <> letter, ""}
    end
  end

end


