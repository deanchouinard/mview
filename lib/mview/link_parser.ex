
# Usage:
# html = "<p>Hello <a href='https://google.com'>world</a></p>"
# IO.puts LinkParser.add_target_blank(html)
# Output: <p>Hello <a target="_blank" rel="noopener noreferrer" href="https://google.com">world</a></p>

defmodule LinkParser do
  @doc """
  Adds target="_blank" and rel="noopener noreferrer" to all <a> tags.
  """
  def add_target_blank(html_string) do
    html_string
    |> Floki.parse_document!()
    |> Floki.traverse_and_update(fn
      {"a", attrs, children} ->
        # Add target and security attributes
        new_attrs = [{"target", "_blank"}, {"rel", "noopener noreferrer"} | Enum.reject(attrs, fn {k, _v} -> k == "target" or k == "rel" end)]
        {"a", new_attrs, children}
      node -> node
    end)
    |> Floki.raw_html()
  end
end


