defmodule Mview.Page do
  
  def tab_page(dirs, [label] = _x) do
    [pages_dir, label] = find_active_tab(dirs, label)
    tabs = build_tabs(dirs, label)
    page_contents = file_list(pages_dir, label)
    build_page("templates/show_page.eex", {page_contents, tabs})
  end

  def index_page(dirs) do
    [pages_dir, label] = List.first(dirs)
    tabs = build_tabs(dirs, label)
    page_contents = file_list(pages_dir, label)
    build_page("templates/show_page.eex", {page_contents, tabs})
  end

  def bootstrap do
    File.read!("static/css/bootstrap.min.css")
  end

  def show_page(dirs, path) do
    [label, file_name] = path
    [pages_dir, _] = find_active_tab(dirs, label)
    page_path = Path.join(pages_dir, file_name)
    page_contents = File.read!(page_path)
    page_contents = Earmark.to_html(page_contents)
    build_page("templates/show_page.eex", {page_contents, file_name})
  end

  defp build_page(template, {page_contents, tabs} = _vars) do
    EEx.eval_file("templates/app.eex", [body:
      EEx.eval_file(template, [page_contents: page_contents, tabs: tabs])
    ])
  end

  def search_results(dirs, stext, [label] = _t) do
    ##System.cmd("ack", [stext], cd: pages_dir)
    [pages_dir, _] = find_active_tab(dirs, label)

    results = Enum.map(File.ls!(pages_dir), fn(x) -> search_file(pages_dir, x,
      stext, label) end)
    build_page("templates/search_results_page.eex", {results, "Search"})
  end

  defp search_file(pages_dir, file, stext, label) do
    File.stream!(Path.join(pages_dir, file))
    |> Enum.filter(&(String.contains?(&1, stext)))
    |> Enum.map(&(make_link(&1, file, label)))
  end

  defp make_link(match, file, label) do
    "<a href=/page/#{label}/#{file}>#{match}</a> #{file}</br>"
  end

  def build_search_form(label) do
"""
    <hr>
    <form action="/search/#{label}" method="post">
      <input type="text" name="stext">
      <input type="submit" value="Search">
    </form>
"""
  end

  defp make_file_link(file, pages_dir, label) do
    %File.Stat{mtime: {dt, _tt}} = File.stat!(Path.join(pages_dir, file), time:
      :local)
    "<tr><td><a href=/page/#{label}/#{file}>#{file}</a></td><td>#{dtos(dt)}</td></tr>"
  end

  defp dtos(date), do: Date.from_erl!(date) |> Date.to_string

  defp build_tabs(dirs, label) do
    tabs = ["<ul class=\"nav nav-tabs\">"]
    tabs = tabs ++ Enum.map(dirs, fn(x) -> build_tab_item(List.last(x), label) end)
    tabs ++ ["</ul>"]
  end

  defp build_tab_item(label, match_label) do
    case label == match_label do
      true -> "<li class=\"active\"><a href=\"/tab/#{label}\">#{label}</a></li>"
      _    -> "<li><a href=\"/tab/#{label}\">#{label}</a></li>"
    end
  end

  defp file_list(pages_dir, label) do
    page_contents = Enum.map(File.ls!(pages_dir), fn(x) -> 
                make_file_link(x, pages_dir, label) end)
    page_contents = ["<table class=\"table-condensed\"><thead><tr><th>Filename</th>
                <th>Date</th></thead><tbody>" | page_contents]
    page_contents = page_contents ++ ["</tbody></table>"]
    page_contents ++ build_search_form(label)
  end

  def find_active_tab(dirs, label), do: Enum.find(dirs, fn([_a, b] = _x) -> b  == label end)
end

