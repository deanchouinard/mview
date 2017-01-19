defmodule Mview.Page do
  

  def index_page(pages_dir, dirs) do
    tabs = build_tabs(dirs)
    page_contents = Enum.map(File.ls!(pages_dir), fn(x) -> 
                make_file_link(x, pages_dir) end)

    page_contents = ["<table class=\"table-condensed\"><thead><tr><th>Filename</th>
                <th>Date</th></thead><tbody>" | page_contents]

    page_contents = page_contents ++ ["</tbody></table>"]

    IO.inspect page_contents
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

  def show_page(pages_dir, page) do
    page_path = Path.join(pages_dir, page)
    #    unless File.exists?(page_path) do
    #      File.write!(page_path, "### #{page} \n")
    # end

    page_contents = File.read!(page_path)
    page_contents = Earmark.to_html(page_contents)
    build_page("templates/show_page.eex", {page_contents, page})

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
  
  def search_results(pages_dir, stext) do
    IO.puts "search_results"
    ##System.cmd("ack", [stext], cd: pages_dir)
    results = Enum.map(File.ls!(pages_dir), fn(x) -> search_file(pages_dir, x,
      stext) end)
    build_page("templates/search_results_page.eex", {results, "Search"})
  end

  defp search_file(pages_dir, file, stext) do
    File.stream!(Path.join(pages_dir, file))
    |> Enum.filter(&(String.contains?(&1, stext)))
    |> Enum.map(&(make_link(&1, file)))
  end

  defp make_link(match, file) do
    "<a href=#{file}>#{match}</a> #{file}</br>"
  end

  defp make_file_link(file, pages_dir) do
    %File.Stat{mtime: {dt, tt}} = File.stat!(Path.join(pages_dir, file), time:
      :local)
    "<tr><td><a href=#{file}>#{file}</a></td><td>#{dtos(dt)}</td></tr>"
  end

  defp dtos(date), do: Date.from_erl!(date) |> Date.to_string

  defp build_tabs(dirs) do
    tabs = ["<ul class=\"nav nav-tabs\">"]
    tabs = tabs ++ Enum.map(dirs, fn(x) -> build_list_item(x) end)
    tabs ++ ["</ul>"]

  end

  defp build_list_item(dir) do
  "<li class=\"active\"><a href=\"#\">#{dir}</a></li>"
  # <li><a href=\"#\">Menu 1</a></li>
  # <li><a href=\"\#\">Menu 2</a></li>
  # <li><a href=\"#\">Menu 3</a></li>
  end
end

