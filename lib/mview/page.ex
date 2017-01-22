defmodule Mview.Page do
  
  def tab_page(dirs, [label] = _x) do
    [pages_dir, label] = Enum.find(dirs, fn([a, b] = x) -> b  == label end)
    # [pages_dir, label] = Enum.find(dirs, fn([a, b] = x) -> b  ==
    # List.to_string(label) end)

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
    page_contents = File.read!("static/css/bootstrap.min.css")
  end


  def edit_page(pages_dir, page) do
    page_path = Path.join(pages_dir, page)
    page_contents = File.read!(page_path)
    build_page("templates/edit_page.eex", {page_contents, page})
  end

  def show_page(dirs, path) do
    [label, file_name] = path
    [pages_dir, _] = Enum.find(dirs, fn([a, b] = x) -> b  == label end)
    page_path = Path.join(pages_dir, file_name)
    #    unless File.exists?(page_path) do
    #      File.write!(page_path, "### #{page} \n")
    # end

    page_contents = File.read!(page_path)
    page_contents = Earmark.to_html(page_contents)
    build_page("templates/show_page.eex", {page_contents, file_name})

  end

  defp build_page(template, {page_contents, tabs} = _vars) do
    EEx.eval_file("templates/app.eex", [body:
      EEx.eval_file(template, [page_contents: page_contents, tabs: tabs])
    ])
  end

  # defp build_page(template, {page_contents, page} = _vars) do
  #   EEx.eval_file("templates/app.eex", [body:
  #     EEx.eval_file(template, [page_contents: page_contents, page: page])
  #   ])
  # end
  
  def search_results(dirs, stext, [label] = _t) do
    IO.puts "search_results"
    ##System.cmd("ack", [stext], cd: pages_dir)
    [pages_dir, _] = Enum.find(dirs, fn([a, b] = x) -> b  == label end)

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

  defp build_tabs(dirs, dir) do
    tabs = ["<ul class=\"nav nav-tabs\">"]
    tabs = tabs ++ Enum.map(dirs, fn(x) -> build_list_item(List.last(x), dir) end)
    tabs ++ ["</ul>"]

  end

  defp build_list_item(dir, match_dir) do
    IO.puts "match begin"
    IO.puts dir
    IO.puts match_dir
    IO.puts "match end"
    case dir == match_dir do
    #"<li><a href=\"/#{dir}\">#{dir}</a></li>"
      true -> "<li class=\"active\"><a href=\"/tab/#{dir}\">#{dir}</a></li>"
      _    -> "<li><a href=\"/tab/#{dir}\">#{dir}</a></li>"
    end

  # <li><a href=\"#\">Menu 1</a></li>
  # <li><a href=\"\#\">Menu 2</a></li>
  # <li><a href=\"#\">Menu 3</a></li>
  end

  defp file_list(pages_dir, label) do
    page_contents = Enum.map(File.ls!(pages_dir), fn(x) -> 
                make_file_link(x, pages_dir, label) end)

    page_contents = ["<table class=\"table-condensed\"><thead><tr><th>Filename</th>
                <th>Date</th></thead><tbody>" | page_contents]

    page_contents = page_contents ++ ["</tbody></table>"]
    
    page_contents = page_contents ++ build_search_form(label)
  end

end

