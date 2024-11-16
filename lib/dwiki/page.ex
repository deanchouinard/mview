defmodule Dwiki.Page do
  

  def edit_page(pages_dir, page) do
    page_path = Path.join(pages_dir, page)
    page_contents = File.read!(page_path)
    build_page("templates/edit_page.eex", {page_contents, page})
  end

  def show_page(pages_dir, page) do
    IO.inspect page
    page_path = Path.join(pages_dir, page)
    IO.inspect page_path
    unless File.exists?(page_path) do
      File.write!(page_path, "### #{page} \n")
    end

    page_contents = File.read!(page_path)
    page_contents = Earmark.to_html(page_contents)
    build_page("templates/show_page.eex", {page_contents, page})

  end

  def bootstrap, do: File.read!("static/css/bootstrap.min.css")

  defp build_page(template, {page_contents, page} = _vars) do
    EEx.eval_file("templates/app.eex", [body:
      EEx.eval_file(template, [page_contents: page_contents, page: page])
    ])
  end
  
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

end

